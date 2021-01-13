//
//  Dancer+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//
//

import Foundation
import CoreData


extension ADancer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dancer> {
        return NSFetchRequest<Dancer>(entityName: "Dancer")
    }

    @NSManaged public var color: String
    @NSManaged public var dancerOwner: String
    @NSManaged public var id: String
    @NSManaged public var label: String?
    @NSManaged public var xPos: Float
    @NSManaged public var yPos: Float
}

extension ADancer : Identifiable {

}
