
import UIKit
import SpriteKit
import CoreData

class GameViewController: UIViewController{
    
    
    @IBOutlet weak var formsTableView: UITableView!

    @IBOutlet weak var squareView: SKView!
    
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    var sceneGridFinished = false
    var currIndexPath: IndexPath?
    
    //var formimage: [UIImage] = [] //Don't need
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //var formationArray: [Formation] = []
    var scene1: GameScene!
    //var newFormation: Formation!
    
    //Need Array of Formations
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene1 = GameScene(size: squareView.bounds.size)
        //squareView.ignoresSiblingOrder = true
        scene1.scaleMode = .fill
        
        
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        formsTableView.dataSource = self
        formsTableView.delegate = self
        scene1.myDelegate = self
        
        //squareView.presentScene(scene1)
        //squareView.backgroundColor = .blue
        
        formationArray = formationVM.loadFormations()


        if formationArray.count == 0{
//            //if Count is 0, create a new formation, with random image, when next is pressed, save current and create new
                let image = dancerVM.imageToData(view: squareView)
                formationVM.createNewFormation(formData: image)
                formationArray = formationVM.loadFormations()
            formationVM.setCurrentSelection(index: formationVM.currentIndex)
                //var curr = formationVM.getCurrentFormation()
                //dancerVM.loadDancers(selectedFormation: curr)
            currIndexPath = IndexPath(row: 0, section: 0)
            self.formsTableView.selectRow(at: currIndexPath, animated: true, scrollPosition: .top)
        }
        else{
            formationVM.setCurrentSelection(index: 0)
            dancerVM.loadDancers(selectedFormation: formationVM.getCurrentFormation())
            currIndexPath = IndexPath(row: 0, section: 0)
            self.formsTableView.selectRow(at: currIndexPath, animated: true, scrollPosition: .top)
        }
        

        
        
        for formation in formationArray{
            var a = formation.dancers?.allObjects as! [Dancer]
            print("Formation INFO \(formation.name) ", a.count)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        squareView.presentScene(scene1)
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    @IBAction func nextFormationPressed(_ sender: Any) {
        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        
        print("When Next is pressed, this is the #dancers there are ", formationVM.getCurrentFormation().dancers?.count)
        dancerVM.saveDancer()
        formationVM.saveFormation()
        formationArray = formationVM.loadFormations()//Trying this out:
        print("When Next is pressed after Load , this is the #dancers there are ", formationVM.getCurrentFormation().dancers?.count)
        formationVM.createNewFormation(formData: imageData)
        
        formationArray = formationVM.loadFormations()
        print("After Creation is pressed after Load , this is the #dancers there are ", formationVM.formationArray[formationVM.currentIndex-1].dancers?.count)
        //var curr = formationVM.getCurrentFormation()
        //dancerVM.loadDancers(selectedFormation: curr)
        self.formsTableView.reloadData()
        if let currentPath = currIndexPath{
        self.formsTableView.deselectRow(at: currentPath, animated: true)
        var nextIndexPath = IndexPath(row: currentPath.row + 1, section: 0)
            self.formsTableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .top)
        }
    }
    
    
    
    @IBAction func playFormationsPressed(_ sender: Any) {
        

            if let currentPath = self.currIndexPath{
                
                    self.scene1.playThroughFormations()

                
                //for i in currentPath.row..<self.formationArray.count{
                //self?.playFormations


                
    }
    }
    
    
    //Call Game Scene method
    
    func playFormationsHelper() -> [Dancer]?{
        
        if let nextFormation = formationVM.getNextFormation(){
            let nextDancerForms = dancerVM.loadNextDancers(nextFormation: nextFormation)
            return nextDancerForms
//            if let currentPath = self.currIndexPath{
//                print("Current Index", formationVM.currentIndex)
//                    self.scene1.playThroughFormations(nextDancerPositions: nextDancerForms)
////                if (currentPath.row + 1 < formationArray.count){
////                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { timer in
////
////                    let nextIndexPath = IndexPath(row: currentPath.row + 1, section: 0)
////                    self.formsTableView.deselectRow(at: currentPath, animated: true)
////                    //self.currIndexPath = nextIndexPath
////                    print(self.currIndexPath?.row)
////                        self.formsTableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .top)
////
////            })
////                    self.currIndexPath = IndexPath(row: currentPath.row + 1, section: 0)
////                }
//
                print(currIndexPath?.row)
                
                formationVM.currentIndex += 1
            
            }
            else{
                print("Error in Playing Formations")
                return nil
            }
            
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
        currIndexPath = indexPath
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
        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        formationVM.saveFormation()
        formationArray = formationVM.loadFormations()
        formsTableView.reloadData()
    }
    
    
    func gridFinished(finished: Bool) {
        sceneGridFinished = true
    }
    
    func dancerMoved(id: String, xPosition: Float, yPosition: Float) {
        dancerVM.updateDancerPosition(id: id, xPosition: xPosition, yPosition: yPosition)
        print("In View Controller Updating", xPosition, yPosition)
        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        formationVM.saveFormation()
        formationArray = formationVM.loadFormations()
        formsTableView.reloadData()
    }
 
}





