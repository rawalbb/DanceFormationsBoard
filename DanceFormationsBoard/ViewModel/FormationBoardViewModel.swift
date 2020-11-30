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
    var currentBoardIndex: Int = -1
    var delegate: BoardUpdatesDelegate!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Function: Load all Formation Dance Boards for Home Screen
    func loadBoards() -> [FormationBoard]{
        
        let request : NSFetchRequest<FormationBoard> = FormationBoard.fetchRequest()
        do{
            
            boardsArray = try context.fetch(request)
        }
        catch{
            print("Error Fetching Data from Context in Formation ViewModel \(error)")
        }
        //self.delegate.boardUpdated(boardArray: boardsArray)
        return boardsArray
    }
    
    //Function: Save the Board
    func saveBoard(){
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.delegate.boardUpdated(boardArray: boardsArray)
    }
    
    //Function: Remove Board
    func removeBoard(){
        
        do{
            try context.delete(getCurrentBoard())
        } catch {
            print("Error deleting Board \(error)")
        }
        self.saveBoard()
        
    }
    
    func createNewBoard(){
        
        // When button on View Controller is placed, user is taken to the formations screen but when they hit back on Navigation (main boards are presented), which is where the image is updated.
        //When + button is selected -> popup (enter formation name), cannot be nil, dismiss popupVC, default image = image not available
        //when the initial formation is created, call this method
        
        let newBoard = FormationBoard(context: context)
        newBoard.name = "Board 1"
        newBoard.lastEdited = Date()
        let newImage = UIImage(systemName: "camera.metering.unknown") ?? #imageLiteral(resourceName: "Rx_Logo_M.png")
        
        if let dataImage = imageToData(image: newImage){
            newBoard.image = dataImage
        }
        self.boardsArray.append(newBoard)
        self.saveBoard()
        
        
    }
    
    //Function: Get current Board
    func getCurrentBoard() -> FormationBoard{
        return boardsArray[currentBoardIndex]
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
        
        getCurrentBoard().image = imageData
        self.saveBoard()
        
    }
    
    
    //Update Board Name
    func updateBoardName(boardName: String){
        
        getCurrentBoard().name = boardName
        self.saveBoard()
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
