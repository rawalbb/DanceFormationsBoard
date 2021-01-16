//
//  Dancer+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/13/21.
//
//

import Foundation
import CoreData


extension Dancer {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dancer> {
        return NSFetchRequest<Dancer>(entityName: "Dancer")
    }
    
    @NSManaged public var color: String
    @NSManaged public var uniqueId: String
    @NSManaged public var label: String?
    @NSManaged public var xPos: Float
    @NSManaged public var yPos: Float
    
}

extension Dancer : Identifiable {
    
}
