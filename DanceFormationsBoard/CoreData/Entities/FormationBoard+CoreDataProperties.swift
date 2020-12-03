//
//  FormationBoard+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/29/20.
//
//

import Foundation
import CoreData


extension FormationBoard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FormationBoard> {
        return NSFetchRequest<FormationBoard>(entityName: "FormationBoard")
    }

    @NSManaged public var image: Data?
    @NSManaged public var lastEdited: Date
    @NSManaged public var name: String?
    @NSManaged public var uniqueId: String
    @NSManaged public var subFormations: NSSet?
    @NSManaged public var notes: String

}

// MARK: Generated accessors for subFormations
extension FormationBoard {

    @objc(addSubFormationsObject:)
    @NSManaged public func addToSubFormations(_ value: Formation)

    @objc(removeSubFormationsObject:)
    @NSManaged public func removeFromSubFormations(_ value: Formation)

    @objc(addSubFormations:)
    @NSManaged public func addToSubFormations(_ values: NSSet)

    @objc(removeSubFormations:)
    @NSManaged public func removeFromSubFormations(_ values: NSSet)

}

extension FormationBoard : Identifiable {

}
