import Foundation
import UIKit
import SpriteKit
import CoreData

class DancerViewModel{
  
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dancerArray = [Dancer]()
    var nextDancerArray = [Dancer]()
    
    func saveDancer(){
        
            do{
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
    }
    
    func loadDancers(selectedFormation: Formation) -> [Dancer]{
        
        let request : NSFetchRequest<Dancer> = Dancer.fetchRequest()
        
        print("In Load Dancers", selectedFormation.name!)
        
        let predicate = NSPredicate(format: "owner.name = %@", selectedFormation.name!)
        request.predicate = predicate
        do{
            
            dancerArray = try context.fetch(request)
            print(dancerArray.count)
        }
        catch{
            print("Error Fetching Data from Context in Dancer ViewModel \(error)")
        }
        
        return dancerArray
    }
    
    func removeDancer(dancer: Dancer){
        
        context.delete(dancer)
        
        context.delete(dancer) //removes all Dancers associated with it
        if let deletedDancer = dancerArray.firstIndex(where: {$0.id == dancer.id}){
            dancerArray.remove(at: deletedDancer)
        } else{
            print("Error in Deleting Dancer in DancerViewModel")
        }
       
        //Make sure to call save after
        
    }
    
    func addDancer(xPosition: Float, yPosition: Float, label: String, id: String, color: String, selectedFormation: Formation){
        
        
        let newDancer = Dancer(context: context)
        newDancer.xPos = xPosition
        newDancer.yPos = yPosition
        newDancer.label = label
        newDancer.color = "Black"
        newDancer.id = id
        //selectedFormation.addToDancers(newDancer)
        newDancer.owner = selectedFormation
        //self.dancerArray.append(newDancer)
        self.saveDancer()
        
        //Call Save everytime this is called
    }
    
    func addDancer(dancer: Dancer, selectedFormation: Formation){
        
        
        let newDancer = Dancer(context: context)
        newDancer.xPos = dancer.xPos
        newDancer.yPos = dancer.yPos
        newDancer.label = dancer.label
        newDancer.color = dancer.color
        newDancer.id = dancer.id
        newDancer.owner = selectedFormation
        //self.dancerArray.append(newDancer)
        self.saveDancer()
        
        //Call Save everytime this is called
    }
    
    func updateDancerPosition( id: String, xPosition: Float, yPosition: Float){
        //var toUpdate = [Dancer]()
        if let toUpdateIndex = dancerArray.firstIndex(where: { $0.id == id }) {
            print("TO UPDATE in dancerVM", xPosition, yPosition)
            
            dancerArray[toUpdateIndex].xPos = xPosition
            dancerArray[toUpdateIndex].yPos = yPosition
        }
        
        self.saveDancer()
        
        
    }
    
    func imageToData(view formationView: SKView) -> Data?{
        
        let renderer = UIGraphicsImageRenderer(size: formationView.frame.size)
        let image = renderer.image { ctx in
            formationView.drawHierarchy(in: formationView.bounds, afterScreenUpdates: true)
        }
        
        if let data = image.jpegData(compressionQuality: 1.0){
           return data
        }
        else{
            return nil
        }
    }
    
    
    func loadNextDancers(nextFormation: Formation) -> [Dancer]{
        
        let request : NSFetchRequest<Dancer> = Dancer.fetchRequest()
        
        print("In Load Dancers", nextFormation.name!)
        
        let predicate = NSPredicate(format: "owner.name = %@", nextFormation.name!)
        request.predicate = predicate
        do{
            
            nextDancerArray = try context.fetch(request)
            print(nextDancerArray.count)
        }
        catch{
            print("Error Fetching Data from Context in Dancer ViewModel \(error)")
        }
        
        return nextDancerArray
    }
 
}
