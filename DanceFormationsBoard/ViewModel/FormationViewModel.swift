
import Foundation
import UIKit
import SpriteKit
import CoreData


class FormationViewModel{
    
    
    var currentIndex = -1
    var formationArray = [Formation]()
    var currentFormation: Formation?
    var nextFormation: Formation?
    var danceVM = DancerViewModel()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func saveFormation(){
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    func createNewFormation(formData: Data? = nil) -> Formation{
        var numFormation = formationArray.count
        let newFormation = Formation(context: context)
        newFormation.name = "Formation \(numFormation)"
        if formData == nil{
            newFormation.image = UIImage(named: "circle")?.jpegData(compressionQuality: 1.0)
        } else{
            newFormation.image = formData
        }
        if currentIndex != -1{
            print(currentIndex, "CURR INDEX")
            var dancerObjects = getCurrentFormation().dancers as! Set<Dancer>
            print("When creating new, checking dancer count of old ", dancerObjects.count)
            for dancer in dancerObjects{
                danceVM.addDancer(dancer: dancer, selectedFormation: newFormation)
            }
        }
        else{
            newFormation.dancers = nil
        }
        numFormation += 1
        self.formationArray.append(newFormation)
        currentIndex += 1
        self.saveFormation()
        return newFormation
    }
    
    func getCurrentFormation() -> Formation{
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
    
    func removeFormation(row: Int){
        
        context.delete(formationArray[row]) //removes all Dancers associated with it
        formationArray.remove(at: row)
        //Make sure to call save after
        
    }
    
    func loadFormations() -> [Formation]{
        //Should be called in viewDidLoad
        
        let request : NSFetchRequest<Formation> = Formation.fetchRequest()
        do{
            
            formationArray = try context.fetch(request)
        }
        catch{
            print("Error Fetching Data from Context in Formation ViewModel \(error)")
        }
        
        return formationArray
    }
}
