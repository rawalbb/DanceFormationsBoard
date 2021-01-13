//
//  Formation+CoreDataClass.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/13/21.
//
//

import Foundation
import CoreData


public class Formation: NSManagedObject, NSCoding, Codable {
    
    enum CodingKeys: CodingKey {
      case image, name, position, songTime, uniqueId, waitTime, dancers
    }
      

    required convenience init(from decoder: Decoder) throws {
      guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
        throw DecoderConfigurationError.missingManagedObjectContext
      }

      self.init(context: context)

      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.image = try container.decode(Data.self, forKey: .image)
      self.name = try container.decode(String.self, forKey: .name)
      self.position = try container.decode(Int16.self, forKey: .position)
      self.songTime = -1.0
      self.uniqueId = UUID().uuidString
      self.waitTime = try container.decode(Double.self, forKey: .waitTime)
      self.dancers = try container.decode([Dancer].self, forKey: .dancers)

    }
      
      public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(image, forKey: .image)
          try container.encode(name, forKey: .name)
          try container.encode(position, forKey: .position)
          try container.encode(songTime, forKey: .songTime)
         try container.encode(uniqueId, forKey: .uniqueId)
          try container.encode(waitTime, forKey: .waitTime)
          try container.encode(dancers, forKey: .dancers)

        }

}
