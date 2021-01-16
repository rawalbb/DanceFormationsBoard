//
//  BoardViewModel.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/29/20.
//

import Foundation
import UIKit
import CoreData

protocol BoardUpdatesDelegate{
    func boardUpdated(boardArray: [Board])
}


class BoardViewModel{
    
    var boardsArray = [Board]()
    var currentBoardIndex: Int?
    var delegate: BoardUpdatesDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Function: Load all Formation Dance Boards for Home Screen
    func loadBoards(){
        
        let request : NSFetchRequest<Board> = Board.fetchRequest()
        do{
            
            let tempBoardsArray = try context.fetch(request)
            boardsArray = tempBoardsArray.sorted(by: {
                $0.lastEdited.compare($1.lastEdited) == .orderedDescending
            })
        }
        catch{
            print("Error Fetching Data from Context in Formation ViewModel \(error)")
        }
        
        self.delegate?.boardUpdated(boardArray: boardsArray)
    }
    
    //Function: Save the Board
    func saveBoard(){
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    //Function: Remove Board
    func removeBoard(board: Board){
        do{
            context.delete(board)
        }
    }
    
    func createNewBoard(){
        
        let newBoard = Board(context: context)
        newBoard.name = "Board \(boardsArray.count)"
        newBoard.lastEdited = Date()
        
        if let dataStr = ImageDataManager.imageToData(image: #imageLiteral(resourceName: "defaultFormImage")){
            newBoard.image = dataStr
        }
        newBoard.notes = nil
        newBoard.uniqueId = UUID().uuidString
        newBoard.song = nil
        
    }
    
    
    //Function: Get current Board
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
    
    //Function: Get array of boards
    func getBoardArray() -> [Board]{
        return boardsArray
    }
    
    //Function: Set current Board
    func setCurrentBoard(index: Int){
        currentBoardIndex = index
    }
    
    
    //Update Board Image
    func updateBoardImage(imageData: Data?){
        
        getCurrentBoard()?.image = imageData
    }
    
    func updateBoardNotes(notes: String){
        
        getCurrentBoard()?.notes = notes
        
    }
    
    
    //Update Board Name
    func updateBoardName(boardName: String){
        
        getCurrentBoard()?.name = boardName
    }
    
    func updateBoardDate(date: Date){
        
        getCurrentBoard()?.lastEdited = date
    }
    
    func updateBoardSong(songUrl: String){
        getCurrentBoard()?.song = songUrl
        print("Setting Board Song URL ", songUrl)
    }
    

    
    
}
