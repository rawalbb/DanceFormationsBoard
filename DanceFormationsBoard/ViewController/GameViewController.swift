
import UIKit
import SpriteKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: UIViewController{
    
    
    @IBOutlet weak var formsTableView: UITableView!

    @IBOutlet weak var squareView: SKView!
    
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var nodeColorButton: UIButton!
    
    
    var boardVM: FormationBoardViewModel!
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    var currIndexPath: IndexPath?
    var enableText: Bool = false
    var selectedColor = UIColor.yellow
    //let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    

    var scene1: GameScene!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Game View ", boardVM.currentBoardIndex) //ASSERT 0
        formationVM.currentBoard = boardVM.getCurrentBoard()
        scene1 = GameScene(size: squareView.bounds.size)
        scene1.scaleMode = .fill
        
        
        
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        formsTableView.dataSource = self
        formsTableView.delegate = self
        scene1.myDelegate = self
        labelTextField.delegate = self
        nodeColorButton.backgroundColor =  UIColor.yellow
        scene1.selectedNodeColor = selectedColor
        formationVM.delegate = self
        
        squareView.presentScene(scene1)
        //squareView.backgroundColor = .blue
        
        formationArray = formationVM.loadFormations()
               if formationArray.count == 0{
                formationVM.createNewFormation(formData: nil)
                allFormUpdates()
               }
               else{
                formationVM.setCurrentSelection(index: 0)
                var curr = formationVM.getCurrentFormation()
                var dancers = dancerVM.loadDancers(selectedFormation: curr)
                scene1.initial = dancers
//                scene1.formationSelected(dancers: dancers)
                //Set CELL SELECTION
               }
        
        ////            //if Count is 0, create a new formation, with random image, when next is pressed, save current and create new
        //                let image = dancerVM.imageToData(view: squareView)
        //                formationVM.createNewFormation(formData: image)
        //                formationArray = formationVM.loadFormations()
        //            formationVM.setCurrentSelection(index: formationVM.currentIndex)
        //                //var curr = formationVM.getCurrentFormation()
        //                //dancerVM.loadDancers(selectedFormation: curr)
        //            currIndexPath = IndexPath(row: 0, section: 0)
        //            self.formsTableView.selectRow(at: currIndexPath, animated: true, scrollPosition: .top)
        //        }
        //        else{
        //            formationVM.setCurrentSelection(index: 0)
        //            dancerVM.loadDancers(selectedFormation: formationVM.getCurrentFormation())
        //            currIndexPath = IndexPath(row: 0, section: 0)
        //            self.formsTableView.selectRow(at: currIndexPath, animated: true, scrollPosition: .top)
        //        }
        
        
        
        
        
        

        
        }
    
//    deinit {
//         NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
//         NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
//         NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
//     }
    
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
        //dancerVM.saveDancer()
        //formationVM.saveFormation()
        formationArray = formationVM.loadFormations()//Trying this out:
        formationVM.createNewFormation(formData: imageData)
        allFormUpdates()
        
        //formationArray = formationVM.loadFormations()
        //print("After Creation is pressed after Load , this is the #dancers there are ", formationVM.formationArray[formationVM.currentIndex-1].dancers?.count)
        //var curr = formationVM.getCurrentFormation()
        //dancerVM.loadDancers(selectedFormation: curr)
        
//        if let currentPath = currIndexPath{
//        self.formsTableView.deselectRow(at: currentPath, animated: true)
//        var nextIndexPath = IndexPath(row: currentPath.row + 1, section: 0)
//            self.formsTableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .top)
//
            
            
            
            //        var imageData = dancerVM.imageToData(view: squareView)
            //        formationVM.getCurrentFormation().image = imageData
            //
            //        //print("When Next is pressed, this is the #dancers there are ", formationVM.getCurrentFormation().dancers?.count)
            //        dancerVM.saveDancer()
            //        formationVM.saveFormation()
            //        formationArray = formationVM.loadFormations()//Trying this out:
            //        //print("When Next is pressed after Load , this is the #dancers there are ", formationVM.getCurrentFormation().dancers?.count)
            //        formationVM.createNewFormation(formData: imageData)
            //
            //        formationArray = formationVM.loadFormations()
            //        //print("After Creation is pressed after Load , this is the #dancers there are ", formationVM.formationArray[formationVM.currentIndex-1].dancers?.count)
            //        //var curr = formationVM.getCurrentFormation()
            //        //dancerVM.loadDancers(selectedFormation: curr)
            //        self.formsTableView.reloadData()
            //        if let currentPath = currIndexPath{
            //        self.formsTableView.deselectRow(at: currentPath, animated: true)
            //        var nextIndexPath = IndexPath(row: currentPath.row + 1, section: 0)
            //            self.formsTableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .top)
            //        }
        }
    
    
    
    
    @IBAction func playFormationsPressed(_ sender: Any) {
        var waitT = 0.0
        //player.play()
        //musicPlayer.play()
        
        ///The action is indeed cancelled(it actually finished when you start playing) but it will not stop the audio. Use SKAudioNode if you need to suddenly stop sounds
        self.scene1.playSong()

        
                for i in formationVM.currentIndex..<formationVM.formationArray.count{
                    
                    if let currentPath = self.currIndexPath{

                    print(formationVM.currentFormation?.name)
                    if let nextFormation = formationVM.getNextFormation(){
                    let nextDancerForms = dancerVM.loadNextDancers(nextFormation: nextFormation)
                        formationVM.currentFormation = nextFormation
                        
                        
                        //print("New Current Path ", currentPath.row)

                
                        self.scene1.playThroughFormations(dancers: nextDancerForms, waitTime: waitT, transitionTime: 2.0, formIndex: formationVM.currentIndex, totalForms: formationArray.count)
                    
                        waitT = 4.0
                
                //for i in currentPath.row..<self.formationArray.count{
                //self?.playFormations

                        
                }
                    
                    formationVM.currentIndex += 1
       
    }
                    //currIndexPath = IndexPath(row: formationVM.currentIndex, section: 0)
                    
                    
                    //self.scene1.endSong()

                self.scene1.run(SKAction.sequence(self.scene1.arrayOfActions))
                    
                    let currNext = IndexPath(row: formationVM.currentIndex, section: 0)
                    //self.scene1.arrayOfActions = []

               
    }
        //player.stop()
    }
    

    @IBAction func labelTextFieldChanged(_ sender: UITextField) {
        print("Label changed")
        if let text = labelTextField.text{
            print(text)
            self.scene1.updateDancerLabel(label: text)
            if let nodeId = self.scene1.currentNode?.nodeId{
            dancerVM.updateDancerLabel(id: nodeId, label: text)
            var imageData = dancerVM.imageToData(view: squareView)
            formationVM.getCurrentFormation().image = imageData
            formationVM.saveFormation()
            //formationArray = formationVM.loadFormations()
            formsTableView.reloadData()
            }
            
        }
    }
    
    
    @IBAction func colorPickerButton(_ sender: UIButton) {
        print("Pick Color")
    }
    
    
    
    func allFormUpdates(){
        
        formationVM.saveFormation()
        formationVM.loadFormations()

    }
    

}

extension GameViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return formationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.formsTableView.dequeueReusableCell(withIdentifier: "ReusableCell") as! FormationSnapshotCell
        //cell.formationName.delegate = self
        let index = formationVM.currentIndex
        if indexPath.row == index {
            //cell.backgroundColor = UIColor.blue
            //cell.setSelected(true, animated: true)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        let item = formationArray[indexPath.row]
        if let formationData = item.image{
            let cellImage = UIImage(data: formationData)
            cell.formationImage?.image = cellImage
        }
        
        cell.formationName?.text = item.name
        print("Item Nem", item.name)
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

//MARK: - KEYBOARD EXTENSIONS
extension GameViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("In Return")
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      return enableText
    }
    
//    @objc func keyboardWillChange(notification: Notification) {
//        view.frame.origin.y = -100
//    }
    
}

//MARK: - GAMESCENE Delegate/Protocols
extension GameViewController: GameSceneUpdatesDelegate{
    
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String) {
        
        let curr = formationVM.getCurrentFormation()

        dancerVM.addDancer(xPosition: xPosition, yPosition: yPosition, label: label, id: id, color: color, selectedFormation: curr)
        dancerVM.saveDancer()

        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        formationVM.saveFormation()
        //formationArray = formationVM.loadFormations()
        formsTableView.reloadData()
    }
    
    func dancerMoved(id: String, xPosition: Float, yPosition: Float) {
        dancerVM.updateDancerPosition(id: id, xPosition: xPosition, yPosition: yPosition)
        dancerVM.saveDancer()
        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        formationVM.saveFormation()
        //formationArray = formationVM.loadFormations()
        formsTableView.reloadData()
    }
    
    func updateCellSelect() {
        let curr = IndexPath(row: self.formationVM.currentIndex, section: 0)
        
        DispatchQueue.main.async {
            self.formsTableView.selectRow(at: curr, animated: true, scrollPosition: .top)
        }
    }
    
    func updateCellDeselect(){
        
        DispatchQueue.main.async {
            let curr = IndexPath(row: self.formationVM.currentIndex, section: 0)
            self.formsTableView.deselectRow(at: curr, animated: true)
        }
    }
    
    func enableTextField(enable: Bool) {
        enableText = enable
        //print(enableText)
    }
    
    func updateNodeColor(color: UIColor) {
        selectedColor = color
        nodeColorButton.backgroundColor = selectedColor
    }
    
    func removedDancer(id: String) {
        dancerVM.removeDancer(dancerId: id)
        dancerVM.saveDancer()
        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        formationVM.saveFormation()
        //formationArray = formationVM.loadFormations()
        formsTableView.reloadData()
    }
 
}

extension GameViewController: FormUpdatesDelegate{
    
    func formUpdated(formArray: [Formation]) {
        //self.boardVMArray = boardArray
        formationArray = formArray
        print("In Form Updated, Game Controller ", formationArray.count)
        DispatchQueue.main.async {
            self.formsTableView.reloadData()
        }
    }
}




