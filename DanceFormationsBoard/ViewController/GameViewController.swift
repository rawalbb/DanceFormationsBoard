
import UIKit
import SpriteKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: KeyUIViewController{
    
    
    @IBOutlet var hieracrchyView: UIView!
    
    
    @IBOutlet weak var formsTableView: UITableView!
    
    @IBOutlet weak var squareView: SKView!
    @IBOutlet weak var formOptionsView: UIView!
    
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var nodeColorButton: UIButton!
    
    @IBOutlet weak var labelToggleButton: UIButton!
    
    var boardVM: BoardViewModel!
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    var currIndexPath: IndexPath?
    var enableText: Bool = false
    var selectedColor = UIColor.yellow
    var colorPicker = UIColorPickerViewController()
    //let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    
    var scene1: GameScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundSV = hieracrchyView
        
        formOptionsView.layer.cornerRadius = 20
        formOptionsView.backgroundColor = #colorLiteral(red: 0.1478704014, green: 0.1637916303, blue: 0.1738279326, alpha: 1)
        formOptionsView.layer.borderWidth = 2
        formOptionsView.layer.borderColor = #colorLiteral(red: 0.1478704014, green: 0.1637916303, blue: 0.1738279326, alpha: 1).cgColor
        nodeColorButton.layer.cornerRadius = 10
        
       // print("Game View ", boardVM.currentBoardIndex as Any) //ASSERT 0
        formationVM.currentBoard = boardVM.getCurrentBoard()
        scene1 = GameScene(size: squareView.bounds.size)
        scene1.scaleMode = .fill
        
        let config = UIImage.SymbolConfiguration(scale: .large)
        
        labelToggleButton.setImage(UIImage(systemName: "person.fill.checkmark"),
                                   for: [.highlighted, .selected])
        labelToggleButton.setPreferredSymbolConfiguration(config, forImageIn: [.highlighted, .selected])
        
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        formsTableView.dataSource = self
        formsTableView.delegate = self
        scene1.myDelegate = self
        labelTextField.delegate = self
        nodeColorButton.backgroundColor =  UIColor.yellow
        scene1.selectedNodeColor = selectedColor
        colorPicker.delegate = self
        formationVM.delegate = self
        
        squareView.presentScene(scene1)
        //squareView.backgroundColor = .blue
        
        formationArray = formationVM.loadFormations()
        if formationArray.count == 0{
            formationVM.createNewFormation(formData: nil)
            formationVM.setCurrentSelection(index: 0)
        }
        else{
            formationVM.setCurrentSelection(index: 0)
            let curr = formationVM.getCurrentFormation()
            let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
            scene1.initial = dancers
            //                scene1.formationSelected(dancers: dancers)
            //Set CELL SELECTION
        }
        
        allFormUpdates()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        squareView.presentScene(scene1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        //Don't need to update boards
        //don't need to update label
        //don't need to update board properties
        boardVM.updateBoardDate(date: Date())
    }
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func nextFormationPressed(_ sender: Any) {
        
        let imageData = dancerVM.imageToData(view: squareView)
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
    
    
    @IBAction func addMusicPressed(_ sender: UIButton) {
        
        let nextVC = storyboard?.instantiateViewController(identifier: "MusicViewController") as! MusicViewController
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
        
        
    }
    
    
    
    @IBAction func playFormationsPressed(_ sender: Any) {
        
        self.scene1.removeAllActions()
        var waitT = 0.0
        
        //player.play()
        //musicPlayer.play()
        
        ///The action is indeed cancelled(it actually finished when you start playing) but it will not stop the audio. Use SKAudioNode if you need to suddenly stop sounds
        self.scene1.playSong()
        formationVM.setCurrentSelection(index: 0)
        
        for _ in 0..<formationVM.formationArray.count{
            
           
                
               // print(formationVM.currentFormation?.name)
                if let nextFormation = formationVM.getNextFormation(){
                    let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                    formationVM.currentFormation = nextFormation
                    
                    
                    //print("New Current Path ", currentPath.row)
                    
                    
                    self.scene1.playThroughFormations(dancers: nextDancerForms, waitTime: waitT, transitionTime: 2.0, formIndex: formationVM.currentIndex, totalForms: formationArray.count)
                    
                    waitT = 4.0
                    
                    //for i in currentPath.row..<self.formationArray.count{
                    //self?.playFormations
                    
                    
                }
                
                formationVM.currentIndex += 1
                
            
            //currIndexPath = IndexPath(row: formationVM.currentIndex, section: 0)
            
            
            //self.scene1.endSong()
            
            self.scene1.run(SKAction.sequence(self.scene1.arrayOfActions))
            
            //let currNext = IndexPath(row: formationVM.currentIndex, section: 0)
            //self.scene1.arrayOfActions = []
            
            
        }
        //player.stop()
    }
    
    
    @IBAction func labelTextFieldChanged(_ sender: UITextField) {
        //print("Label changed")
                if let text = labelTextField.text{
                    //print(text)
                    self.scene1.updateDancerLabel(label: text)
                    if let nodeId = self.scene1.currentNode?.nodeId{
                        dancerVM.updateDancerLabel(id: nodeId, label: text)
                        let imageData = dancerVM.imageToData(view: squareView)
                        formationVM.getCurrentFormation().image = imageData!
                        //allFormUpdates()
                    }
        
                }

    }
    
    
    @IBAction func colorPickerButton(_ sender: UIButton) {
        //print("Pick Color")
        colorPicker.supportsAlpha = true
        //colorPicker.selectedColor = selectedColor
        present(colorPicker, animated: true)
        selectedColor = colorPicker.selectedColor
    }
    
    @IBAction func removeFormation(_ sender: UIButton) {
        
        let toRemove = formationVM.getCurrentFormation()
        
            formationVM.removeFormation(form: toRemove)
        formationVM.setCurrentSelection(index: formationVM.currentIndex - 1) //WHAT HAPPENS HERE?
        //WHEN DELETED, formation on gamescene stays
        if formationVM.currentIndex == -1{
            formationVM.createNewFormation(formData: nil)
        }
            allFormUpdates()
        
        
    }
    
    @IBAction func nextFormationPlay(_ sender: UIButton) {
        self.scene1.arrayOfActions = []
        if let nextFormation = formationVM.getNextFormation(){
            let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
            formationVM.currentFormation = nextFormation
            
            self.scene1.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: formationVM.currentIndex, totalForms: formationArray.count)
        }
        
        
        self.scene1.run(SKAction.sequence(self.scene1.arrayOfActions))
        
    }
    
    
    @IBAction func prevFormationPlay(_ sender: UIButton) {
     
        self.scene1.arrayOfActions = []
        if let nextFormation = formationVM.getPrevFormation(){
            let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
            formationVM.currentFormation = nextFormation
            
            self.scene1.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: formationVM.currentIndex, totalForms: formationArray.count)
        }
        
        
        self.scene1.run(SKAction.sequence(self.scene1.arrayOfActions))
    }
    
    
    @IBAction func labelTogglePressed(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        //print(sender.isSelected)
        scene1.showLabel = sender.isSelected
        scene1.nodeLabelHelper()
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
       // print("Current Index, ", index, "Current Path ", indexPath.row)
        //cell.setSelected(index == indexPath.row, animated: true)
        //cell.setSelected(true, animated: true)
        
        let item = formationArray[indexPath.row]
        if let formationData = item.image{
            let cellImage = UIImage(data: formationData)
            cell.formationImage?.image = cellImage
        }
        
        cell.formationName?.text = item.name
        //print("Item Nem", item.name)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let currentCell = tableView.cellForRow(at: indexPath) as! FormationSnapshotCell
        formationVM.setCurrentSelection(index: indexPath.row)
        let curr = formationVM.getCurrentFormation()
        let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
        scene1.formationSelected(dancers: dancers)
        currIndexPath = indexPath
    }
    
    
    
}

//MARK: - KEYBOARD EXTENSIONS
extension GameViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("In Return")
        
        textField.resignFirstResponder()
        view.frame.origin.y = 0
    

        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        return enableText
    }
    
}

//MARK: - GAMESCENE Delegate/Protocols
extension GameViewController: GameSceneUpdatesDelegate{
    
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String) {
        
        let curr = formationVM.getCurrentFormation()
        
        dancerVM.addDancer(xPosition: xPosition, yPosition: yPosition, label: label, id: id, color: color, selectedFormation: curr)
        dancerVM.saveDancer()
        
        let imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        formationVM.saveFormation()
        //formationArray = formationVM.loadFormations()
        formsTableView.reloadData()
    }
    
    func dancerMoved(id: String, xPosition: Float, yPosition: Float) {
        dancerVM.updateDancerPosition(id: id, xPosition: xPosition, yPosition: yPosition)
        dancerVM.saveDancer()
        let imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        allFormUpdates()
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
    
    func enableTextField(enable: Bool, id: String) {
        enableText = enable
        if enableText{
            labelTextField.text = dancerVM.getDancer(id: id)?.label ?? ""
        }
        else{
            labelTextField.text = ""
        }
        //print(enableText)
    }
    
    func updateNodeColor(color: UIColor) {
        scene1.selectedNodeColor = color
        selectedColor = color
        nodeColorButton.backgroundColor = selectedColor
    }
    
    func removedDancer(id: String) {
        dancerVM.removeDancer(dancerId: id)
        dancerVM.saveDancer()
        let imageData = dancerVM.imageToData(view: squareView)
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
            let currIndex = self.formationVM.currentIndex
            let newPath = IndexPath(row: currIndex, section: 0)
            self.formsTableView.selectRow(at: newPath, animated: true, scrollPosition: .top)
        }
    }
}


extension GameViewController: UIColorPickerViewControllerDelegate{

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print("Did Dismiss Controller")
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        nodeColorButton.backgroundColor = selectedColor

        let colorString = selectedColor.toHexString()
        scene1.selectedNodeColor = selectedColor
        self.scene1.updateDancerColor(color: colorString)

        if let nodeId = self.scene1.currentNode?.nodeId{
            dancerVM.updateDancerColor(id: nodeId, color: colorString)
            dancerVM.saveDancer()
            let imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        allFormUpdates()
        }

}
}

extension GameViewController: MusicChosenDelegate{
    
    func musicChosen(url: URL) {
        scene1.musicUrl = url
    }
}



//TODO: - Next Formation Pressed - DONE

//TODO: - Previous Formation Pressed - DONE

//TODO: - Play Formations all way

//TODO: - Undo

//TODO: - if there's a dancer already at that location, can't put it there

//TODO: - when making changes to a dancer in one formation - make sure you're making those changes to the same dancers in ALL formations. Ex: in F1 - color blue, F2 - color yellow - should BE SAME
