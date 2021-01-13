//
//  Formation+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//
//

import Foundation
import CoreData


extension Formation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Formation> {
        return NSFetchRequest<Formation>(entityName: "Formation")
    }

    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var position: Int16
    @NSManaged public var songTime: Float
    @NSManaged public var uniqueId: String
    @NSManaged public var waitTime: Int16
    @NSManaged public var formationOwner: Board

}

// MARK: Generated accessors for dancers
extension Formation {

    @objc(addDancersObject:)
    @NSManaged public func addToDancers(_ value: Dancer)

    @objc(removeDancersObject:)
    @NSManaged public func removeFromDancers(_ value: Dancer)

    @objc(addDancers:)
    @NSManaged public func addToDancers(_ values: NSSet)

    @objc(removeDancers:)
    @NSManaged public func removeFromDancers(_ values: NSSet)

}

extension Formation : Identifiable {

}
