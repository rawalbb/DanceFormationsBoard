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
    case image, name, position, songTime, uniqueId, waitTime, dancers
  }
    

  required convenience init(from decoder: Decoder) throws {
    guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
      throw DecoderConfigurationError.missingManagedObjectContext
    }
    guard let entity = NSEntityDescription.entity(forEntityName: "Formation", in: context) else { /* ... */ throw DecoderConfigurationError.missingManagedObjectContext }
    

        self.init(entity: entity, insertInto: context)
    //self.init(context: context)

    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    //self.image = ImageDataManager.imageToData(image: UIImage(named: "defaultFormImage")!)
    let stringImage = try container.decodeIfPresent(String.self, forKey: .image)
    self.image = Data(base64Encoded: stringImage!)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.position = try container.decode(Int16.self, forKey: .position)
    self.songTime = -1.0
    self.uniqueId = UUID().uuidString
    self.waitTime = try container.decode(Int16.self, forKey: .waitTime)
    let dancersArray = try container.decode([Dancer].self, forKey: .dancers)
    self.dancers = NSSet(array: dancersArray)
    print("PRINTING ", self.name, self.position, self.uniqueId, self.waitTime, self.dancers)
    //self.formationOwner = try container.decode(Board.self, forKey: .formationOwner)
    
    //self.formationOwner = try container.decode(Board.self, forKey: .formationOwner)
  }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let stringImage = image?.base64EncodedString()
        try container.encode(stringImage, forKey: .image)
        try container.encode(name, forKey: .name)
        try container.encode(position, forKey: .position)
        try container.encode(songTime, forKey: .songTime)
       try container.encode(uniqueId, forKey: .uniqueId)
        try container.encode(waitTime, forKey: .waitTime)
        let encodeArray = dancers?.allObjects as? [Dancer]
        try container.encode(encodeArray, forKey: .dancers)

        //let dancerArary = self.dancers?.allObjects as? [Dancer]

        //try container.encode(dancers as! Set<Dancer>, forKey: .dancers)
        //try container.encode(dancers, forKey: .dancers)
        //try container.encode(formationOwner as Board, forKey: .formationOwner)

      }
    

}

