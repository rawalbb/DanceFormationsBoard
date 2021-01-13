//
//  Board+CoreDataClass.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//
//

import Foundation
import CoreData


//public class Board: NSManagedObject {
//
//}

public class Board: NSManagedObject, Codable {
  enum CodingKeys: CodingKey {
    case image, lastEdited, name, notes, song, uniqueId, subFormations
  }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
          throw DecoderConfigurationError.missingManagedObjectContext
        }

    
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        do{
            
        self.image = try container.decode(Data?.self, forKey: .image)
        self.lastEdited = Date()
        self.name = try container.decode(String?.self, forKey: .name)
        self.notes = try container.decode(String?.self, forKey: .notes)
        self.song = nil
        self.uniqueId = UUID().uuidString
            self.subFormations = try container.decode(Set<Formation>.self, forKey: .subFormations)
        
        }
        catch{
            print("Error Decoding Board")
        }
        

}
    
    
     public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        
        try container.encode(image, forKey: .image)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
       try container.encode(song, forKey: .song)
        try container.encode(uniqueId, forKey: .uniqueId)
        try container.encode(subFormations, forKey: .subFormations)
        //try container.encode(subFormations, forKey: .subFormations)

        
      }
    
    
    func exportToURL(name: String) -> URL? {
      // 1
        
      guard let encoded = try? JSONEncoder().encode(self) else { return nil }
      //print("Enocded   ", encode)
      // 2
      let documents = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
      ).first
        
      guard let path = documents?.appendingPathComponent("/\(name).board") else {
        return nil
      }
      
      // 3
      do {
        try encoded.write(to: path, options: .atomicWrite)
        return path
      } catch {
        print(error.localizedDescription)
        return nil
      }
    }
}

public extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "context")!
}

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}



