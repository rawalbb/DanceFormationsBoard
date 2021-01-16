//
//  Dancer+CoreDataClass.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//
//

import Foundation
import CoreData

class Dancer: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case color, uniqueId, label, xPos, yPos
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "Dancer", in: context) else {
            throw DecoderConfigurationError.missingManagedObjectContext }
        
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.color = try container.decode(String.self, forKey: .color)
        self.uniqueId = UUID().uuidString
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.xPos = try container.decode(Float.self, forKey: .xPos)
        self.yPos = try container.decode(Float.self, forKey: .yPos)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(color, forKey: .color)
        try container.encode(uniqueId, forKey: .uniqueId)
        try container.encode(label, forKey: .label)
        try container.encode(xPos, forKey: .xPos)
        try container.encode(yPos, forKey: .yPos)
    }
    
}

