//
//  BoardViewModel.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/29/20.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

protocol BoardUpdatesDelegate{
    func boardUpdated(boardArray: [Board])
}


class BoardViewModel{
    
    var boardsArray : [Board] = []{
        didSet{
            return boardsArray.sort { $0.lastEdited < $1.lastEdited
            }
            

        }
    }
   
    
    var currentBoardIndex: Int?
    var delegate: BoardUpdatesDelegate?
    static let shared = BoardViewModel()
    
    let collection = Firestore.firestore().collection("danceboards")
    
    func createNewBoard(){
        
        var newImage: Data? = nil
        if let dataStr = ImageDataManager.imageToData(image: #imageLiteral(resourceName: "defaultFormImage")){
            newImage = dataStr
        }
        let name = "Board \(boardsArray.count)"
        let uniqueId = UUID().uuidString
        
        let newBoard = Board(
            image: newImage,
            lastEdited: Date(),
            boardName: name,
            notes: nil,
            song: nil,
            uniqueId: uniqueId
        )
        
        collection.document("\(uniqueId)").setData(newBoard.dictionary)
            //addDocument(data: newBoard.dictionary)
        
    }
    

    
    
    func loadAllBoards(){
        //What if save users to share it with as an array, array can also just hold one person. Load users, check to see if
        //guard let query = query else { return }
        //stopObserving()
        collection.getDocuments { [self] (snapshot, error) in
          if let error = error {
            print(error)
          } else if let snapshot = snapshot {
            let developers: [Board] = snapshot.documents.compactMap {
              return try? $0.data(as: Board.self)
            }
            //print("Developers ", developers)
            self.boardsArray = developers
            print("Boards in model", self.boardsArray.count)
            
            self.delegate?.boardUpdated(boardArray: self.boardsArray)
          }
        }
                
  

        // Display data from Firestore, part one
        

    }

    
    func getCurrentBoard() -> Board?{
        if let index = currentBoardIndex
        {
            return boardsArray[index]
        }
        else{
            print("Getting Current Board Error")
            return nil
        }
    }
    
    func getAllBoards() -> [Board]{
        return boardsArray
    }
    
    //Function: Get current Board Index
    func getCurrentBoardIndex() -> Int?{
        
        if let index = currentBoardIndex
        {
            return index
        }
        else{
            print("Getting Current Board Error")
            return nil
        }
    }
    
    //Function: Set current Board
    func setCurrentBoard(index: Int){
        currentBoardIndex = index
    }
    
    
    //Update things individually or update array then update, updates for curr board
    func updateBoardNotes(notes: String?){
        if let index = currentBoardIndex
        {
            boardsArray[index].notes = notes
            boardsArray[index].lastEdited = Date()
        }
        else{
            print("Error updating board notes")
        }
    }
    
    func updateBoardImage(imageData: Data?){
        if let index = currentBoardIndex
        {
            boardsArray[index].image = imageData
        }
        else{
            print("Error updating board notes")

        }
        
    }
    
    func updateBoardName(name: String?){
        if let index = currentBoardIndex
        {
            boardsArray[index].boardName = name
            boardsArray[index].lastEdited = Date()
        }
        else{
            print("Error updating board name")
    
        }
    }
    
    func updateBoardDate(date: Date){
        
        if let index = currentBoardIndex
        {
            boardsArray[index].lastEdited = date
        }
        else{
            print("Error updating board date")
     
        }
    }
    
    func updateBoardSong(songUrl: String?){
        
        if let index = currentBoardIndex
        {
            boardsArray[index].song = songUrl
        }
        else{
            print("Error updating board song")
       
        }
    }
    
    func removeBoard(){
        
        
    }
    
    func saveToFirebase(){
        
        for boards in boardsArray{
        collection.document("\(boards.uniqueId)").setData([
            "image" : (boards.image),
            "lastEdited": boards.lastEdited,
            "boardName": boards.boardName,
            "notes": boards.notes,
            "song": boards.song,
            "uniqueId": boards.uniqueId

        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        }

        
    }
    
    func removeFromFirebase(){
        if let curr = getCurrentBoard()?.uniqueId{
        collection.document(curr).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    }
        
    }






