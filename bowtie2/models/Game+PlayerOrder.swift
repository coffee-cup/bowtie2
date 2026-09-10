import CoreData

enum PlayerOrder: Int16, CaseIterable {
    case byScore = 0
    case manual = 1

    var title: String {
        self == .byScore ? "By Score" : "Manual"
    }
}

extension Game {
    var playerOrder: PlayerOrder {
        get { PlayerOrder(rawValue: playerOrderValue) ?? .byScore }
        set { playerOrderValue = newValue.rawValue }
    }

    var hasManualPlayerOrder: Bool {
        playerOrder == .manual || activePlayerScores.contains { $0.manualPosition != nil }
    }

    var activePlayerScores: [PlayerScore] {
        (playerScores as? Set<PlayerScore> ?? []).filter { !$0.isDeleted && $0.player != nil }
    }

    var manualScoresArray: [PlayerScore] {
        activePlayerScores.sorted(by: PlayerScore.manualOrderPrecedes)
    }

    var displayScoresArray: [PlayerScore] {
        displayScores(from: activePlayerScores)
    }

    func displayScores(from scores: [PlayerScore]) -> [PlayerScore] {
        let active = scores.filter { !$0.isDeleted && $0.player != nil }
        switch playerOrder {
        case .byScore: return rankedScores(from: active)
        case .manual: return active.sorted(by: PlayerScore.manualOrderPrecedes)
        }
    }

    var initialPlayerOrder: [PlayerScore] {
        hasManualPlayerOrder ? manualScoresArray : scoresArray
    }

    // A draft can outlive membership changes imported from another device.
    func reconciledPlayerOrder(_ draft: [NSManagedObjectID]) -> [PlayerScore] {
        let current = initialPlayerOrder
        let lookup = Dictionary(uniqueKeysWithValues: current.map { ($0.objectID, $0) })
        var included = Set<NSManagedObjectID>()
        let retained = draft.compactMap { id -> PlayerScore? in
            guard included.insert(id).inserted else { return nil }
            return lookup[id]
        }
        return retained + current.filter { !included.contains($0.objectID) }
    }

    func assignManualPlayerOrder(_ scores: [PlayerScore]) {
        for (index, score) in scores.enumerated() {
            score.manualPosition = NSNumber(value: index)
            if score.orderingID == nil {
                score.orderingID = UUID()
            }
        }
    }

    func savePlayerOrder(_ order: PlayerOrder, draft: [NSManagedObjectID]? = nil) throws {
        guard let context = managedObjectContext, !isDeleted else {
            throw CocoaError(.validationMissingMandatoryProperty)
        }
        let previousMode = playerOrderValue
        let previousValues = activePlayerScores.map { ($0, $0.manualPosition, $0.orderingID) }

        if order == .manual {
            assignManualPlayerOrder(reconciledPlayerOrder(draft ?? initialPlayerOrder.map(\.objectID)))
        }
        playerOrder = order

        do {
            try context.save()
        } catch {
            playerOrderValue = previousMode
            for (score, position, id) in previousValues where !score.isDeleted {
                score.manualPosition = position
                score.orderingID = id
            }
            throw error
        }
    }
}

extension PlayerScore {
    static func manualOrderPrecedes(_ lhs: PlayerScore, _ rhs: PlayerScore) -> Bool {
        switch (lhs.manualPosition?.int64Value, rhs.manualPosition?.int64Value) {
        case let (left?, right?) where left != right: return left < right
        case (_?, nil): return true
        case (nil, _?): return false
        default: break
        }

        if lhs.manualPosition != nil, rhs.manualPosition != nil {
            switch (lhs.orderingID, rhs.orderingID) {
            case let (left?, right?) where left != right: return left.uuidString < right.uuidString
            case (_?, nil): return true
            case (nil, _?): return false
            default: break
            }
        }

        if let left = lhs.player, let right = rhs.player, left != right {
            return Player.playerOrderPrecedes(left, right)
        }
        return lhs.objectID.uriRepresentation().absoluteString < rhs.objectID.uriRepresentation().absoluteString
    }
}

extension Player {
    static func playerOrderPrecedes(_ lhs: Player, _ rhs: Player) -> Bool {
        let comparison = lhs.wrappedName.compare(rhs.wrappedName, options: [.caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
        if comparison != .orderedSame { return comparison == .orderedAscending }
        let leftDate = lhs.created ?? .distantPast
        let rightDate = rhs.created ?? .distantPast
        if leftDate != rightDate { return leftDate < rightDate }
        return lhs.objectID.uriRepresentation().absoluteString < rhs.objectID.uriRepresentation().absoluteString
    }
}
