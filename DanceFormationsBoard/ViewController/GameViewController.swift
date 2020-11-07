
import UIKit
import SpriteKit
import CoreData

class GameViewController: UIViewController{
    
    
    @IBOutlet weak var formsTableView: UITableView!
    @IBOutlet weak var squareView: SKView!
    
    //var formimage: [UIImage] = [] //Don't need
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var formationArray: [Formation] = []
    var scene1: GameScene!
    var newFormation: Formation!
    
    //Need Array of Formations
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene1 = GameScene(size: squareView.bounds.size)
        squareView.ignoresSiblingOrder = true
        scene1.scaleMode = .fill
        
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        formsTableView.dataSource = self
        formsTableView.delegate = self
        squareView.presentScene(scene1)
        
        loadFormations()

            newFormation = Formation(context: self.context)
            scene1.newForm = newFormation
        
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func saveFormation(){
        
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }

    
    @IBAction func formationCreate(_ sender: Any) {
        
        let renderer = UIGraphicsImageRenderer(size: squareView.frame.size)
        let image = renderer.image { ctx in
            squareView.drawHierarchy(in: squareView.bounds, afterScreenUpdates: true)
        }
        //var formarray = scene1.formationArray
        //print("formarray", formarray)
        //^^Getting array of dancers
        //formimage.append(image)
        if let data = image.jpegData(compressionQuality: 1.0){
            newFormation.image = data
            saveFormation()
        }
        else{
            print("ERROR in formation image saving")
        }
        scene1.formationImage = image
        scene1.createFormationPressed = true
        loadFormations()
        self.formsTableView.reloadData()
          
    }


}

extension GameViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return formimage.count
        return formationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.formsTableView.dequeueReusableCell(withIdentifier: "ReusableCell") as! FormationSnapshotCell
        cell.formationName.delegate = self
        
        let item = formationArray[indexPath.row]
        if let formationImage = item.image{
            let cellImage = UIImage(data: formationImage)
            cell.formationImage?.image = cellImage
        }
        
        
        //cell.formationImage?.image = formimage[indexPath.row]
        
        cell.formationName?.text = "Formation "
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! FormationSnapshotCell
            
        scene1.formationSelected(formationNum: indexPath.row)
    }
    
    
}

extension GameViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



//MARK-: Load Formations
/*
 1. Get First formation and add those dancers as nodes on SpriteKit
 2. and load up tableview with formation images
 3. Later do transition things
 
 
 
 
 */
extension GameViewController{ 
    
    func loadFormations(){
        let request : NSFetchRequest<Formation> = Formation.fetchRequest()
        let requestDancer : NSFetchRequest<Dancer> = Dancer.fetchRequest()
        do{
            let dancersArray = try context.fetch(requestDancer)
            formationArray = try context.fetch(request)
            scene1.formationArray = formationArray
            print(formationArray.count, "Printing Num Formations")
        }
        catch{
            print("Error Fetching Data from Context \(error)")
        }

}
}
