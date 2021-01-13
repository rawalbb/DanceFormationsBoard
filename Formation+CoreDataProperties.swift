//
//  Formation+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/13/21.
//
//

import Foundation
import CoreData


extension Formation{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Formation> {
        return NSFetchRequest<Formation>(entityName: "Formation")
    }

    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var position: Int16
    @NSManaged public var songTime: Float
    @NSManaged public var uniqueId: String?
    @NSManaged public var waitTime: Double
    @NSManaged public var dancers: [Dancer]?

}

extension Formation : Identifiable {

}
