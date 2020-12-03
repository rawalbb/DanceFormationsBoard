//
//  FormationBoardViewModel.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/29/20.
//

import Foundation
import UIKit
import CoreData

protocol BoardUpdatesDelegate{
    func boardUpdated(boardArray: [FormationBoard])
}
class FormationBoardViewModel{
    
    var boardsArray = [FormationBoard]()
    var currentBoardIndex: Int?
    var delegate: BoardUpdatesDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Function: Load all Formation Dance Boards for Home Screen
    func loadBoards() -> [FormationBoard]{
        
        let request : NSFetchRequest<FormationBoard> = FormationBoard.fetchRequest()
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
        return boardsArray
    }
    
    //Function: Save the Board
    func saveBoard(){
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        //loadBoards()
        //self.delegate.boardUpdated(boardArray: boardsArray)
    }
    
    //Function: Remove Board
    func removeBoard(board: FormationBoard){
        
        do{
            try context.delete(board)
        } catch {
            print("Error deleting Board \(error)")
        }
        //self.saveBoard()
        
    }
    
    func createNewBoard(){
        
        // When button on View Controller is placed, user is taken to the formations screen but when they hit back on Navigation (main boards are presented), which is where the image is updated.
        //When + button is selected -> popup (enter formation name), cannot be nil, dismiss popupVC, default image = image not available
        //when the initial formation is created, call this method
        
        let newBoard = FormationBoard(context: context)
        newBoard.name = "Board \(boardsArray.count)"
        newBoard.lastEdited = Date()
        let newImage = #imageLiteral(resourceName: "defaultFormImage")
        
        if let dataImage = imageToData(image: newImage){
            newBoard.image = dataImage
        }
        newBoard.notes = ""
        newBoard.uniqueId = UUID().uuidString
        self.boardsArray.append(newBoard)
       // self.saveBoard()
        
        
    }
    
    //Function: Get current Board
    func getCurrentBoard() -> FormationBoard?{
        if let index = currentBoardIndex
        {
            print("Board id", boardsArray[index].uniqueId)
        return boardsArray[index]
        }
        else{
            print("Getting Current Board Error")
            return nil
        }
        
    }
    
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
    
    
    func getBoardArray() -> [FormationBoard]{
        return boardsArray
    }
    
    //Function: Set current Board
    func setCurrentBoard(index: Int){
        currentBoardIndex = index
    }
    
    
    //Update Board Image
    func updateBoardImage(imageData: Data){
        
        getCurrentBoard()?.image = imageData
        //self.saveBoard()
        
    }
    
    func updateBoardNotes(notes: String){
        
        getCurrentBoard()?.notes = notes
       // self.saveBoard()
        
    }
    
    
    //Update Board Name
    func updateBoardName(boardName: String){
        
        getCurrentBoard()?.name = boardName
       // self.saveBoard()
    }
    
    func imageToData(image: UIImage) -> Data?{
        
        if let data = image.jpegData(compressionQuality: 1.0){
           return data
        }
        else{
            return nil
        }
    }
    
    
}
