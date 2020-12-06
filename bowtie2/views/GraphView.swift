//
//  GraphView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-12-05.
//

import SwiftUI

struct Line: Hashable {
    var colour: String
    var points: [CGFloat]
    
    var min: CGFloat {
        points.min() ?? 0
    }
    
    var max: CGFloat {
        points.max() ?? 0
    }
    
    func normalizedPoints(withMin min: CGFloat, withMax max: CGFloat) -> [CGFloat] {
        return points.map{ p in
            (p - min) / (max - min)
        }
    }
}

struct Graph {
    var lines: [Line]
    
    var min: CGFloat {
        lines.map({ l in l.min }).min() ?? 0
    }
    
    var max: CGFloat {
        lines.map({ l in l.max }).max() ?? 0
    }
}

fileprivate struct LineGraph: Shape {
    var dataPoints: [CGFloat]

    func path(in rect: CGRect) -> Path {
        func point(at ix: Int) -> CGPoint {
            let point = dataPoints[ix]
            let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
            let y = (1-point) * rect.height
            return CGPoint(x: x, y: y)
        }

        return Path { p in
            guard dataPoints.count > 1 else { return }
            let start = dataPoints[0]
            p.move(to: CGPoint(x: 0, y: (1-start) * rect.height))
            for idx in dataPoints.indices {
                p.addLine(to: point(at: idx))
            }
        }
    }
}


struct GraphView: View {
    var graph: Graph
    
    var body: some View {
        ZStack {
            ForEach(graph.lines, id: \.self) { line in
                LineGraph(dataPoints: line.normalizedPoints(withMin: graph.min, withMax: graph.max))
                    .trim(to: 1)
                    .stroke(Color(hex: line.colour), lineWidth: 2)
            }
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(graph: Graph(lines: [
            Line(colour: "00CED1", points: [1, 2, 2.5, 3, 4]),
            Line(colour: "4169E1", points: [2, 0, 1, 6])
        ]))
        .aspectRatio(16/9, contentMode: .fit)
    }
}
