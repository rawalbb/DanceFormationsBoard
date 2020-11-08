
import UIKit
import SpriteKit
import CoreData

class GameViewController: UIViewController{
    
    
    @IBOutlet weak var formsTableView: UITableView!
    @IBOutlet weak var squareView: SKView!
    
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    
    //var formimage: [UIImage] = [] //Don't need
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //var formationArray: [Formation] = []
    var scene1: GameScene!
    //var newFormation: Formation!
    
    //Need Array of Formations
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene1 = GameScene(size: squareView.bounds.size)
        squareView.ignoresSiblingOrder = true
        scene1.scaleMode = .fill
        
        formationArray = formationVM.loadFormations()
        if formationArray.count == 0{
            formationVM.createNewFormation()
            formationArray = formationVM.loadFormations()
            var curr = formationVM.getCurrentFormation()
            dancerVM.loadDancers(selectedFormation: curr)
        }
        formationVM.setCurrentSelection(index: 0)
        
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        formsTableView.dataSource = self
        formsTableView.delegate = self
        scene1.myDelegate = self
        squareView.presentScene(scene1)
        

    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    @IBAction func formationCreate(_ sender: Any) {
        
        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.createNewFormation(formData: imageData)
        formationArray = formationVM.loadFormations()
        var curr = formationVM.getCurrentFormation()
        dancerVM.loadDancers(selectedFormation: curr)
        self.formsTableView.reloadData()
    }


}

extension GameViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return formationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.formsTableView.dequeueReusableCell(withIdentifier: "ReusableCell") as! FormationSnapshotCell
        //cell.formationName.delegate = self
        
        let item = formationArray[indexPath.row]
        if let formationData = item.image{
            let cellImage = UIImage(data: formationData)
            cell.formationImage?.image = cellImage
        }
        
        cell.formationName?.text = item.name
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! FormationSnapshotCell
        formationVM.setCurrentSelection(index: indexPath.row)
        var curr = formationVM.getCurrentFormation()
        var dancers = dancerVM.loadDancers(selectedFormation: curr)
        scene1.formationSelected(dancers: dancers)

    }
    
    
}

extension GameViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension GameViewController: GameSceneUpdatesDelegate{
    
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String) {
        
        let curr = formationVM.getCurrentFormation()
        dancerVM.addDancer(xPosition: xPosition, yPosition: yPosition, label: "Label", id: id, color: color, selectedFormation: curr)
    }
    
    
}



//MARK-: Load Formations
/*
 1. Get First formation and add those dancers as nodes on SpriteKit
 2. and load up tableview with formation images
 3. Later do transition things
 
 
 
 
 */

