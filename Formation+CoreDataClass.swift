//
//  Formation+CoreDataClass.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/13/21.
//
//

import Foundation
import CoreData
import UIKit

class Formation: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case image, name, position, songTime, uniqueId, dancers
    }
    
    
    required convenience init(from decoder: Decoder) throws {
        
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "Formation", in: context) else {  throw
            NSEntityMigrationPolicyError }
        
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let stringImage = try container.decodeIfPresent(String.self, forKey: .image)
        self.image = Data(base64Encoded: stringImage!)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.position = try container.decode(Int16.self, forKey: .position)
        self.songTime = -1.0
        self.uniqueId = try container.decode(String.self, forKey: .uniqueId)
        let dancersArray = try container.decode([Dancer].self, forKey: .dancers)
        self.dancers = NSSet(array: dancersArray)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let stringImage = image?.base64EncodedString()
        try container.encode(stringImage, forKey: .image)
        try container.encode(name, forKey: .name)
        try container.encode(position, forKey: .position)
        try container.encode(songTime, forKey: .songTime)
        try container.encode(uniqueId, forKey: .uniqueId)
        let encodeArray = dancers?.allObjects as? [Dancer]
        try container.encode(encodeArray, forKey: .dancers)
    }
    
    
}

