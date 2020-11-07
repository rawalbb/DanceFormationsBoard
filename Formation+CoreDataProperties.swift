//
//  Formation+CoreDataProperties.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/6/20.
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
    @NSManaged public var dancers: NSSet?

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
