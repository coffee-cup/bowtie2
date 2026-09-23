#!/usr/bin/env python3
"""Run Bowtie XCTest verification on a disposable simulator and retain evidence."""

import argparse
from contextlib import suppress
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_TEST = "bowtie2UITests/bowtie2UITests/testScoreCalculatorReturnsResultToScoreEntry"


def run(args, *, log=None, timeout=120, check=True):
    args = [str(arg) for arg in args]
    output = log.open("w") if log else subprocess.PIPE
    try:
        with subprocess.Popen(args, cwd=ROOT, stdout=output, stderr=subprocess.STDOUT,
                              text=True, start_new_session=True) as process:
            try:
                stdout, _ = process.communicate(timeout=timeout)
            except BaseException:
                with suppress(ProcessLookupError):
                    os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                raise
            result = subprocess.CompletedProcess(args, process.returncode, stdout)
    finally:
        if log:
            output.close()
    if check and result.returncode:
        detail = f"See {log}" if log else result.stdout
        raise RuntimeError(f"Command exited {result.returncode}: {' '.join(args)}\n{detail}")
    return result


def doctor(device_id=None):
    report = {"xcode": run(["xcodebuild", "-version"]).stdout.strip()}
    report["runtimes"] = json.loads(run(["xcrun", "simctl", "list", "runtimes", "-j"]).stdout)["runtimes"]
    if device_id:
        devices = json.loads(run(["xcrun", "simctl", "list", "devices", "-j"]).stdout)["devices"]
        matches = [d for group in devices.values() for d in group if d["udid"] == device_id]
        if not matches or not matches[0]["isAvailable"] or matches[0]["state"] != "Booted":
            raise RuntimeError(f"Verification simulator is not available and booted: {device_id}")
        report["device"] = matches[0]
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["doctor", "run"])
    parser.add_argument("--device-id", help="Read-only doctor check for a running verification simulator")
    parser.add_argument("--test", action="append", help="XCTest target/class/method; repeat to select several")
    parser.add_argument("--runtime", help="Installed simctl runtime identifier; defaults to latest available iOS")
    parser.add_argument("--device-type", default="com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro")
    args = parser.parse_args()
    if args.command == "doctor":
        print(json.dumps(doctor(args.device_id), indent=2))
        return
    if args.device_id:
        parser.error("run creates its own simulator; --device-id is only for doctor")

    tests = args.test or [DEFAULT_TEST]
    if any(t.split("/")[0] not in {"bowtie2Tests", "bowtie2UITests"} for t in tests):
        parser.error("--test must select bowtie2Tests or bowtie2UITests")
    evidence_root = ROOT / "build/verification"
    evidence_root.mkdir(parents=True, exist_ok=True)
    evidence = Path(tempfile.mkdtemp(prefix="run-", dir=evidence_root))
    print(f"Evidence: {evidence}", flush=True)
    metadata = {"tests": tests, "status": "running", "simulatorDeleted": False}
    manifest = evidence / "run.json"
    device_id = None
    failed = False
    result = evidence / "tests.xcresult"
    try:
        metadata["revision"] = run(["git", "rev-parse", "HEAD"]).stdout.strip()
        metadata["workingTreeStatus"] = run(["git", "status", "--porcelain"]).stdout
        run(["git", "diff", "--binary", "HEAD"], log=evidence / "working-tree.patch")
        report = doctor()
        (evidence / "environment.json").write_text(json.dumps(report, indent=2) + "\n")
        runtimes = [r for r in report["runtimes"] if r["isAvailable"]
                    and ".iOS-" in r["identifier"] and int(r["version"].split(".")[0]) >= 26]
        if args.runtime:
            runtimes = [r for r in runtimes if r["identifier"] == args.runtime]
        if not runtimes:
            raise RuntimeError("No matching iOS 26+ runtime. Check Xcode Settings > Components.")
        runtime = max(runtimes, key=lambda r: tuple(int(v) for v in r["version"].split(".")))["identifier"]
        metadata["runtime"] = runtime
        metadata["deviceType"] = args.device_type
        manifest.write_text(json.dumps(metadata, indent=2) + "\n")
        with tempfile.TemporaryDirectory(prefix="bowtie-verify-build-") as derived:
            print("Building app and tests…", flush=True)
            run(["xcodebuild", "build-for-testing", "-quiet", "-scheme", "bowtie2",
                 "-destination", "generic/platform=iOS Simulator", "-derivedDataPath", derived,
                 "CODE_SIGNING_ALLOWED=NO", "COMPILER_INDEX_STORE_ENABLE=NO"],
                log=evidence / "build.log", timeout=900)
            device_name = f"Bowtie Verification {evidence.name}"
            device_id = run(["xcrun", "simctl", "create", device_name, args.device_type, runtime]).stdout.strip()
            metadata.update(simulatorID=device_id, simulatorName=device_name)
            manifest.write_text(json.dumps(metadata, indent=2) + "\n")
            run(["xcrun", "simctl", "boot", device_id])
            run(["xcrun", "simctl", "bootstatus", device_id, "-b"], log=evidence / "boot.log", timeout=300)
            (evidence / "doctor.json").write_text(json.dumps(doctor(device_id), indent=2) + "\n")
            command = ["xcodebuild", "test-without-building", "-quiet", "-scheme", "bowtie2",
                       "-destination", f"platform=iOS Simulator,id={device_id}",
                       "-derivedDataPath", derived, "-resultBundlePath", result,
                       "-parallel-testing-enabled", "NO", "-test-timeouts-enabled", "YES",
                       "-collect-test-diagnostics", "never",
                       "-default-test-execution-time-allowance", "240",
                       "CODE_SIGNING_ALLOWED=NO", "COMPILER_INDEX_STORE_ENABLE=NO"]
            command += [f"-only-testing:{test}" for test in tests]
            metadata["testCommand"] = [str(arg) for arg in command]
            manifest.write_text(json.dumps(metadata, indent=2) + "\n")
            print(f"Driving {len(tests)} test selection(s) on {device_id}…", flush=True)
            outcome = run(command, log=evidence / "test.log", timeout=1200, check=False)
            metadata["testExitCode"] = outcome.returncode
            if outcome.returncode:
                raise RuntimeError(f"Tests failed. See {evidence / 'test.log'}")
            run(["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", result],
                log=evidence / "summary.json")
            summary = json.loads((evidence / "summary.json").read_text())
            if summary.get("passedTests", 0) == 0 or summary.get("failedTests", 0):
                raise RuntimeError("Result has no passing tests or contains failures; inspect summary.json")
            metadata["status"] = "passed"
    except (RuntimeError, OSError, subprocess.SubprocessError, KeyboardInterrupt) as error:
        failed = True
        metadata.update(status="failed", error=str(error))
        print(f"Verification stopped: {error}", file=sys.stderr)
    finally:
        # Export failed-test evidence too, before removing only our simulator.
        try:
            if result.exists():
                exported = run(["xcrun", "xcresulttool", "export", "attachments", "--path", result,
                                "--output-path", evidence / "attachments"],
                               log=evidence / "export.log", check=False)
                metadata["attachmentsExported"] = exported.returncode == 0
                if exported.returncode:
                    failed = True
                    metadata["status"] = "evidence-export-failed"
        except (RuntimeError, OSError, subprocess.SubprocessError, KeyboardInterrupt) as error:
            failed = True
            metadata.update(status="evidence-export-failed", exportError=str(error))
        finally:
            try:
                if device_id:
                    try:
                        run(["xcrun", "simctl", "shutdown", device_id], check=False)
                    except (OSError, subprocess.SubprocessError) as error:
                        metadata["shutdownError"] = str(error)
                    deleted = run(["xcrun", "simctl", "delete", device_id], check=False)
                    metadata["simulatorDeleted"] = deleted.returncode == 0
                    if deleted.returncode:
                        failed = True
                        metadata["status"] = "cleanup-failed"
                        print(f"Could not delete owned simulator {device_id}: {deleted.stdout}", file=sys.stderr)
            except (OSError, subprocess.SubprocessError, KeyboardInterrupt) as error:
                failed = True
                metadata.update(status="cleanup-failed", cleanupError=str(error))
            finally:
                manifest.write_text(json.dumps(metadata, indent=2) + "\n")
                print(f"Evidence retained: {evidence}", flush=True)
    if failed:
        sys.exit(1)


def interrupted(signum, frame):
    raise KeyboardInterrupt


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, interrupted)
    main()
