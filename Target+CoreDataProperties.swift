//
//  Target+CoreDataProperties.swift
//  Target
//
//  Created by Fadey Notchenko on 26.08.2022.
//
//

import Foundation
import CoreData


extension Target {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Target> {
        return NSFetchRequest<Target>(entityName: "Target")
    }

    @NSManaged public var colorIndex: Int16
    @NSManaged public var current: Int64
    @NSManaged public var date: Date?
    @NSManaged public var dateNext: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isFinished: Bool
    @NSManaged public var name: String?
    @NSManaged public var price: Int64
    @NSManaged public var replenishment: Int64
    @NSManaged public var timeIndex: Int16
    @NSManaged public var valueIndex: Int16
    @NSManaged public var action: NSSet?

    public var actionArrayByMaxValue: [Action] {
        let set = action as? Set<Action> ?? []
        return set.sorted {
            $0.value > $1.value
        }
    }
    
    public var actionArrayByMinValue: [Action] {
        let set = action as? Set<Action> ?? []
        return set.sorted {
            $0.value < $1.value
        }
    }
    
    public var actionArrayByComment: [Action] {
        let set = action as? Set<Action> ?? []
        return set.sorted {
            ($0.comment ?? "").count > ($1.comment ?? "").count
        }
    }
    
    public var actionArrayByDate: [Action] {
        let set = action as? Set<Action> ?? []
        return set.sorted {
            $0.date ?? Date() > $1.date ?? Date()
        }
    }
}

// MARK: Generated accessors for action
extension Target {

    @objc(addActionObject:)
    @NSManaged public func addToAction(_ value: Action)

    @objc(removeActionObject:)
    @NSManaged public func removeFromAction(_ value: Action)

    @objc(addAction:)
    @NSManaged public func addToAction(_ values: NSSet)

    @objc(removeAction:)
    @NSManaged public func removeFromAction(_ values: NSSet)

}

extension Target : Identifiable {

}
