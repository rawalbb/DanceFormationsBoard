
import Foundation
import UIKit
import SpriteKit
import CoreData


protocol FormUpdatesDelegate{
    
    func formUpdated(formArray: [Formation])
    
}

class FormationViewModel{
    
    var currentIndex: Int? //Initially nil
    var formationArray = [Formation]()
    var danceVM = DancerViewModel()
    var currentBoard: Board!
    var delegate: FormUpdatesDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Saves Formation
    func saveFormation(){
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    //Creates New Formation - if no image data given, create default, else create with image data
    func createNewFormation(imageData: Data? = nil){
        
        let newFormation = Formation(context: context)
        if let dataStr = imageData{
                newFormation.image = dataStr
            }
            else{
                newFormation.image = ImageDataManager.imageToData(image: UIImage(named: "defaultFormImage")!)
            }

            
        if formationArray.count > 0 && currentIndex != nil
        {
            let dancerObjects = getFormation(type: FormationType.current)?.dancers as! Set<Dancer>
            
            for dancer in dancerObjects{
                danceVM.addDancer(dancer: dancer, selectedFormation: newFormation)
            }
            if let currIndex = getCurrentIndex(){
                newFormation.position = Int16(currIndex + 1)
            }
            
        }
        else{
            newFormation.dancers = nil
            newFormation.position = 0
        }
        newFormation.waitTime = 3
        newFormation.songTime = -1.0
        newFormation.uniqueId = UUID().uuidString
        newFormation.formationOwner = currentBoard
    }
    
    func getFormation(type: FormationType) -> Formation?{
        var returnVal: Formation? = nil
        switch type{
        
        case .current:
            if let current = self.getCurrentIndex()
            {
                returnVal = formationArray[current]
            }
            else{
                print("Getting Current Formation Error")
                returnVal = nil
            }
    
        case .previous:
            if let current = self.getCurrentIndex(){
                if current > 0{
                    returnVal = formationArray[current - 1]
                }
                else{
                    returnVal = nil
                }
            }

        case .next:
                
            if let current = self.getCurrentIndex(){
                if current < formationArray.count - 1{
                    returnVal = formationArray[current + 1]
                }
            }
            else{
                returnVal = nil
            }
        
        case .atLocation(let index):
            if index < formationArray.count{
                returnVal = formationArray[index]
            }
            else{
                return nil
            }
            
    }
        return returnVal
    }
    
    func getCurrentIndex() -> Int?{
        
        return currentIndex
    }
    
    func setCurrentSelection(index: Int){
        currentIndex = index
    }
    
    func updateFormImage(imageData: Data?){
        
        if let curr = getFormation(type: FormationType.current){
            if let dataStr = imageData{
                    curr.image = dataStr
                }
                else{
                    curr.image = ImageDataManager.imageToData(image: UIImage(named: "defaultFormImage")!)
                }
        }
    }
    
    func updateFormLabel(label: String?){
        
        if let curr = getFormation(type: FormationType.current){
            if label != nil && label != ""{
            curr.name = label
            }
            else{
                curr.name = "Enter Name:"
            }
        }
    }
    
    func updateFormWaitTime(time: Int){
        if let curr = getFormation(type: FormationType.current){
            
            curr.waitTime = Int16(time)
            

        }
    }
    
    
    func removeFormation(form: Formation){
        
        context.delete(form)
        
    }
    
    func loadFormations() -> [Formation]{

        let request : NSFetchRequest<Formation> = Formation.fetchRequest()

        let predicate = NSPredicate(format: "formationOwner.uniqueId == %@", currentBoard.uniqueId)
        request.predicate = predicate
        do{
            
            let tempArray = try context.fetch(request)
            formationArray = tempArray.sorted(by: {
                $0.position < $1.position
            })
        
        }
        catch{
            print("Error Fetching Data from Context in Formation ViewModel \(error)")
        }
        self.delegate?.formUpdated(formArray: formationArray)

        return formationArray
    }
    
    
    func updatePosition(type: PositionType){
        if let curr = getCurrentIndex(){
            let updateStart = curr + 1
        switch type{
        
        case .add:
            for i in updateStart..<formationArray.count{
                
                formationArray[i].position += 1
            }
            //For each formation greater than "current formation", increase position count
        case .remove:
            for i in updateStart..<formationArray.count{
                
                formationArray[i].position -= 1
            }
        }
        
    }
    }
    
    func setSongTime(time: Float){
        
        if let curr = getFormation(type: FormationType.current){
           
            curr.songTime = time

        }
    }
    
    func getFollowingForms() -> [Formation]?{
        let filtered = formationArray.filter{ forms in
            guard let index = currentIndex else { return false}
                return forms.position > index
        }
        return filtered
    }
    
    
}

enum FormationType{
    
    case current, previous, next, atLocation(Int)
}

enum PositionType{
    
    case add, remove
}
