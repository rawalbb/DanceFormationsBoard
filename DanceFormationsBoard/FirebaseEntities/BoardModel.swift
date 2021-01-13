//
//  BoardModel.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/13/21.
//

import Foundation

struct BoardModel{
    
    let image: Data?
    let lastEdited: Date
    let boardName: String?
    let notes: String?
    let song: String?
    let uniqueId: String
    let formations: [Formation]
}

struct FormationModel{
    
    let image: Data?
    let formName: String?
    let position: Int
    let songTime: Float?
    let uniqueId: String
    let waitTime: Double
    let dancers: [Dancer]
    let owner: String
}

struct DancerModel{
    
    let color: String
    let uniqueId: String
    let label: String?
    let xPos: Float
    let yPos: Float
    let owner: String
    
}
