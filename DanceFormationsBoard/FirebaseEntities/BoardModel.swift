//
//  BoardModel.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/13/21.
//

import Foundation
import FirebaseFirestore

struct Board{

    var image: Data?
    var lastEdited: Date
    var boardName: String?
    var notes: String?
    var song: String?
    var uniqueId: String

      var dictionary: [String: Any] {
        return [
          "image": image,
          "lastEdited": lastEdited,
          "boardName": boardName,
          "notes": notes,
          "song": song,
          "uniqueId": uniqueId
        ]
      }

    }

extension Board: DocumentSerializable, Codable{


  init?(dictionary: [String : Any]) {
    guard let image = dictionary["image"] as? Data,
        let lastEdited = dictionary["lastEdited"] as? Date,
        let boardName = dictionary["boardName"] as? String,
        let notes = dictionary["notes"] as? String,
        let song = dictionary["song"] as? String,
        let uniqueId = dictionary["uniqueId"] as? String
    else { return nil }
  

    self.init(image: image,
              lastEdited: lastEdited,
              boardName: boardName,
              notes: notes,
              song: song,
              uniqueId: uniqueId)
  }
}




struct Formation{
    
    var image: Data?
    var formName: String?
    var position: Int
    var songTime: Float?
    var uniqueId: String
    var formOwner: String
    
    var dictionary: [String: Any] {
      return [
        "image": image,
        "formName": formName,
        "position": position,
        "songTime": songTime,
        "uniqueId": uniqueId,
        "formOwner": formOwner
      ]
    }
}

extension Formation: DocumentSerializable, Codable{


  init?(dictionary: [String : Any]) {
    guard let image = dictionary["image"] as? Data,
        let formName = dictionary["formName"] as? String,
        let position = dictionary["position"] as? Int,
        let songTime = dictionary["songTime"] as? Float,
        let uniqueId = dictionary["uniqueId"] as? String,
        let formOwner = dictionary["formations"] as? String
        else { return nil }
  

    self.init(image: image,
              formName: formName,
              position: position,
              songTime: songTime,
              uniqueId: uniqueId,
              formOwner: formOwner)
  }
}


struct Dancer{
    
    var color: String
    var uniqueId: String
    var label: String?
    var xPos: Float
    var yPos: Float
    var dancerOwner: String
    
    
    var dictionary: [String: Any] {
      return [
        "color": color,
        "uniqueId": uniqueId,
        "label": label,
        "xPos": xPos,
        "yPos": yPos,
        "dancerOwner": dancerOwner
      ]
    }

}

extension Dancer: DocumentSerializable, Codable {

  init?(dictionary: [String : Any]) {
    guard let color = dictionary["color"] as? String,
        let uniqueId = dictionary["uniqueId"] as? String,
        let label = dictionary["label"] as? String,
        let xPos = dictionary["xPos"] as? Float,
        let yPos = dictionary["yPos"] as? Float,
        let dancerOwner = dictionary["dancerOwner"] as? String
    else { return nil }
    
    self.init(color: color, uniqueId: uniqueId, label: label, xPos: xPos, yPos: yPos, dancerOwner: dancerOwner)
  }

}

