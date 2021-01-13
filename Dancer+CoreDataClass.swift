//
//  Dancer+CoreDataClass.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//
//

import Foundation
import CoreData


//public class Dancer: NSManagedObject {
//
//}

class Dancer: NSManagedObject, Codable {
  enum CodingKeys: CodingKey {
    case color, dancerOwner, id, label, xPos, yPos
  }

  required convenience init(from decoder: Decoder) throws {
    guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
      throw DecoderConfigurationError.missingManagedObjectContext
    }

    
    self.init(context: context)

    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.color = try container.decode(String.self, forKey: .color)
    self.dancerOwner = try container.decode(String.self, forKey: .dancerOwner)
    self.id = UUID().uuidString
    self.label = try container.decode(String.self, forKey: .label)
    self.xPos = try container.decode(Float.self, forKey: .xPos)
    self.yPos = try container.decode(Float.self, forKey: .yPos)

  }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(color, forKey: .color)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(xPos, forKey: .xPos)
       try container.encode(yPos, forKey: .yPos)
        //try container.encode(owner, forKey: .owner)
      }

    }
    
