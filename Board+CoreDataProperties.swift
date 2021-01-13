//
//  Board+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/13/21.
//
//

import Foundation
import CoreData


extension Board {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Board> {
        return NSFetchRequest<Board>(entityName: "Board")
    }

    @NSManaged public var image: Data?
    @NSManaged public var lastEdited: Date?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var song: String?
    @NSManaged public var uniqueId: String?
    @NSManaged public var forms: [Formation]?

}

extension Board : Identifiable {

}
