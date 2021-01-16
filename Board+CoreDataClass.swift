//
//  Board+CoreDataClass.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//
//

import Foundation
import CoreData
import UIKit

public class Board: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case image, lastEdited, name, notes, song, uniqueId, subFormations
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "Board", in: context) else { throw
            DecoderConfigurationError.missingManagedObjectContext }
       
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do{

            let stringImage = try container.decodeIfPresent(String.self, forKey: .image)
            self.image = Data(base64Encoded: stringImage!)
            self.lastEdited = Date()
            self.name = try container.decode(String?.self, forKey: .name)
            self.notes = try container.decode(String?.self, forKey: .notes)
            self.song = nil
            self.uniqueId = UUID().uuidString
            let formsArray = try container.decode([Formation].self, forKey: .subFormations)
            self.subFormations = NSSet(array: formsArray)
            try context.save()
        }
        catch{
            print("Error Decoding Board")
        }
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let stringImage = image?.base64EncodedString()
        try container.encode(stringImage, forKey: .image)
        try container.encode(lastEdited, forKey: .lastEdited)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
        try container.encode(song, forKey: .song)
        try container.encode(uniqueId, forKey: .uniqueId)
        let encodeArray = subFormations?.allObjects as? [Formation]
        try container.encode(encodeArray, forKey: .subFormations)
    }
    
    
    func exportToURL(name: String) -> URL? {

        guard let encodedBoard = try? JSONEncoder().encode(self) else { return nil }

        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        
        guard let path = documents?.appendingPathComponent("/\(name).board") else {
            return nil
        }

        do {
            try encodedBoard.write(to: path, options: .atomicWrite)
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




