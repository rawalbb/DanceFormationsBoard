//
//  Formation+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/4/20.
//
//

import Foundation
import CoreData


extension Formation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Formation> {
        return NSFetchRequest<Formation>(entityName: "Formation")
    }

    @NSManaged public var dancer: [Dancer]?

}

extension Formation : Identifiable {

}
