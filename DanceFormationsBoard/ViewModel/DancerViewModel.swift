import Foundation
import UIKit
import SpriteKit
import CoreData

class DancerViewModel{
  
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currDancerArray = [Dancer]()
    
    func saveDancer(){
        
            do{
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
    }
    
    func loadDancers(selectedFormation: Formation, current: Bool) -> [Dancer]{
        
        let request : NSFetchRequest<Dancer> = Dancer.fetchRequest()
        var dancerArray : [Dancer] = []
        
        let predicate = NSPredicate(format: "owner.uniqueId = %@", selectedFormation.uniqueId)
        request.predicate = predicate
        do{
            dancerArray = try context.fetch(request)
        }
        catch{
            print("Error Fetching Data from Context in Dancer ViewModel \(error)")
        }
        
        if current{
            currDancerArray = dancerArray
        }
       
        return dancerArray
    }
    
    func removeDancer(dancerId: String){
        print("In remove dancer ", currDancerArray.count)
        if let deletedDancer = currDancerArray.firstIndex(where: {$0.id == dancerId}){
           
            //currDancerArray.remove(at: deletedDancer)
            let dancerToRemove = currDancerArray[deletedDancer]
            context.delete(dancerToRemove)
        } else{
            print("Error in Deleting Dancer in DancerViewModel")
        }
        print("In remove dancer ", currDancerArray.count)
        
    }
    
    func addDancer(xPosition: Float, yPosition: Float, label: String, id: String, color: String, selectedFormation: Formation){
        
        
        let newDancer = Dancer(context: context)
        newDancer.xPos = xPosition
        newDancer.yPos = yPosition
        newDancer.label = label
        newDancer.color = color
        newDancer.id = id
        //selectedFormation.addToDancers(newDancer)
        newDancer.owner = selectedFormation
        //self.currDancerArray.append(newDancer)
        
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
        //self.currDancerArray.append(newDancer)
        
        //Call Save everytime this is called
    }
    
    func updateDancerPosition( id: String, xPosition: Float, yPosition: Float){
        //var toUpdate = [Dancer]()
        if let toUpdateIndex = currDancerArray.firstIndex(where: { $0.id == id }) {
            print("TO UPDATE in dancerVM", xPosition, yPosition)
            
            currDancerArray[toUpdateIndex].xPos = xPosition
            currDancerArray[toUpdateIndex].yPos = yPosition
        }
        
        
    }
    
    
    func updateDancerLabel( id: String, label: String){

        if let toUpdateIndex = currDancerArray.firstIndex(where: { $0.id == id }) {

            currDancerArray[toUpdateIndex].label = label
        }
    }
    
    
    func updateDancerColor( id: String, color: String){

        if let toUpdateIndex = currDancerArray.firstIndex(where: { $0.id == id }) {

            currDancerArray[toUpdateIndex].color = color
        }
        
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
    
 
}
