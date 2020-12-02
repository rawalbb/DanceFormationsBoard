
import Foundation
import UIKit
import SpriteKit
import CoreData


protocol FormUpdatesDelegate{
    
    func formUpdated(formArray: [Formation])
    
}

class FormationViewModel{
    
    
    var currentIndex = -1
    var formationArray = [Formation]()
    var currentFormation: Formation?
    var nextFormation: Formation?
    var danceVM = DancerViewModel()
    var currentBoard: FormationBoard!
    var delegate: FormUpdatesDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func saveFormation(){
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    func createNewFormation(formData: Data? = nil) -> Formation{
        //var numFormation = formationArray.count
        let newFormation = Formation(context: context)
        newFormation.name = "Formation \(formationArray.count)"
        if formData == nil{
            newFormation.image = UIImage(named: "defaultFormImage")?.jpegData(compressionQuality: 1.0)
        } else{
            newFormation.image = formData
        }
        if currentIndex != -1{
            print(currentIndex, "Current Formation Index")
            var dancerObjects = getCurrentFormation().dancers as! Set<Dancer>
            print("When creating new, checking dancer count of old ", dancerObjects.count)
            for dancer in dancerObjects{
                danceVM.addDancer(dancer: dancer, selectedFormation: newFormation)
            }
            
        }
        else{
            newFormation.dancers = nil
        }
        newFormation.formationOwner = currentBoard
        //TODO
        //numFormation += 1
        //self.formationArray.append(newFormation)
        
        //self.saveFormation() //**CALL FROM Controller
        currentIndex += 1
        print("In Create ", currentIndex)
        return newFormation
    }
    
    func getCurrentFormation() -> Formation{
        print("Current Index", currentIndex)
        print("Formation Array Count", formationArray.count)
        currentFormation = formationArray[currentIndex]
        
        //print("Current Index", currentIndex)
        return formationArray[currentIndex]
        
    }
    
    func setCurrentSelection(index: Int){
        currentIndex = index
    }
    
    func getNextFormation() -> Formation?{
        //print(currentIndex)
        //print(formationArray.count)
        if currentIndex < formationArray.count - 1{
            return formationArray[currentIndex + 1]
        }
        else{
            return nil
        }
    }
    
    func updateSelected(name: String, formArray: [Formation]){
        //Called in tableview didSelectRow
        //and Initially
        currentFormation = formArray.filter({ $0.name == name }).first
    }
    
    func updateFormImage(){
        
    }
    
    func updateFormLabel(){
        
    }
    
    func updateDancerInFormation(dancer: Dancer){
        

    }
    
    func drawInitialGrid(width: CGFloat, height: CGFloat){
        
    }
    
    func removeFormation(form: Formation){
        
        context.delete(form) //removes all Dancers associated with it
        //formationArray.remove(at: row)
        //Make sure to call save after
        
    }
    
    func loadFormations() -> [Formation]{
        //Should be called in viewDidLoad
        //print(boardVM.currentBoardIndex)
        //let currentBoard = boardVM.getCurrentBoard()!
        let request : NSFetchRequest<Formation> = Formation.fetchRequest()
        let predicate = NSPredicate(format: "formationOwner.uniqueId = %@", currentBoard.uniqueId)
        request.predicate = predicate
        do{
            
            formationArray = try context.fetch(request)
        }
        catch{
            print("Error Fetching Data from Context in Formation ViewModel \(error)")
        }
        self.delegate?.formUpdated(formArray: formationArray)
        return formationArray
    }
    
    
}
