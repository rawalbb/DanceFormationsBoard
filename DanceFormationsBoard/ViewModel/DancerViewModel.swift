import Foundation
import UIKit
import SpriteKit
import CoreData

class DancerViewModel{
  
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dancerArray = [Dancer]()
    
    func saveDancer(){
        
            do{
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
    }
    
    func loadDancers(selectedFormation: Formation) -> [Dancer]{
        
        let request : NSFetchRequest<Dancer> = Dancer.fetchRequest()
        
        let predicate = NSPredicate(format: "owner.name MATCHES %@", selectedFormation.name!)
        do{
            
            dancerArray = try context.fetch(request)
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
        newDancer.owner = selectedFormation
        self.dancerArray.append(newDancer)
        
        self.saveDancer()
        
        //Call Save everytime this is called
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
