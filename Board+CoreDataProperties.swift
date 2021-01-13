//
//  Board+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//
//

import Foundation
import CoreData


extension Board {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Board> {
        return NSFetchRequest<Board>(entityName: "Board")
    }

    @NSManaged public var image: Data?
    @NSManaged public var lastEdited: Date
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var song: String?
    @NSManaged public var uniqueId: String

    //@NSManaged var photos: Set<Photo>

}

// MARK: Generated accessors for subFormations
extension Board {

    @objc(addSubFormationsObject:)
    @NSManaged func addToSubFormations(_ value: Formation)

    @objc(removeSubFormationsObject:)
    @NSManaged func removeFromSubFormations(_ value: Formation)

    @objc(addSubFormations:)
    @NSManaged public func addToSubFormations(_ values: NSSet)

    @objc(removeSubFormations:)
    @NSManaged public func removeFromSubFormations(_ values: NSSet)

}

extension Board : Identifiable {

}
