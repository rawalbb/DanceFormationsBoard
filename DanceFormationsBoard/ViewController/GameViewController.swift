
import UIKit
import SpriteKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: KeyUIViewController{
    
    
    @IBOutlet var hieracrchyView: UIView!
    @IBOutlet weak var formsTableView: UITableView!
    
    @IBOutlet weak var stageView: SKView!
    @IBOutlet weak var formOptionsView: UIView!
    
    @IBOutlet weak var nodeLabelTextField: UITextField!
    @IBOutlet weak var nodeColorButton: UIButton!
    @IBOutlet weak var labelToggleButton: UIButton!
    
    @IBOutlet weak var musicToggleButton: UIButton!
    

    
    
    
    var boardVM: BoardViewModel!
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    var enableText: Bool = false
    var selectedColor = #colorLiteral(red: 1, green: 0.9019607902, blue: 0.3450980484, alpha: 1)
    var colorPicker = UIColorPickerViewController()
    var musicUrl: URL? = nil
    var stage: GameScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Formation Options Properties
        formOptionsView.layer.cornerRadius = 20
        formOptionsView.backgroundColor = #colorLiteral(red: 0.1478704014, green: 0.1637916303, blue: 0.1738279326, alpha: 1)
        formOptionsView.layer.borderWidth = 2
        formOptionsView.layer.borderColor = #colorLiteral(red: 0.1478704014, green: 0.1637916303, blue: 0.1738279326, alpha: 1).cgColor
        nodeColorButton.layer.cornerRadius = 10
        
       //Gets the board
        formationVM.currentBoard = boardVM.getCurrentBoard()
        
        
        //Define Stage properties
        stage = GameScene(size: stageView.bounds.size)
        stage.scaleMode = .fill
        stage.myDelegate = self
        stage.selectedColor = selectedColor
        stageView.presentScene(stage) // TODO - have in viewdidload or viewdidappear
        
        //Define labelToggle properties
        labelToggleButton.setImage(UIImage(systemName: "person.fill.checkmark"),
                                   for: [.highlighted, .selected])
        labelToggleButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: [.highlighted, .selected])
        
        
        musicToggleButton.isEnabled = false
        musicToggleButton.setImage(#imageLiteral(resourceName: "musicDeselectionIcon"),
                                   for: [.highlighted, .selected])
        musicToggleButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: [.highlighted, .selected])
        
        //Define Tableview properties
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        formsTableView.dataSource = self
        formsTableView.delegate = self
        
        nodeLabelTextField.delegate = self
        nodeColorButton.backgroundColor =  UIColor.yellow
        
        colorPicker.delegate = self
        formationVM.delegate = self
        
        
        formationArray = formationVM.loadFormations()
        if formationArray.count == 0{
            formationVM.createNewFormation()
            formationVM.setCurrentSelection(index: 0)
        }
        else{
            formationVM.setCurrentSelection(index: 0)
            if let curr = formationVM.getFormation(type: FormationType.current){
                let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
                stage.formationSelected(dancers: dancers)
            }
        }
        
        allFormUpdates()
        
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        //Don't need to update boards
        //don't need to update label
        //don't need to update board properties
        boardVM.updateBoardDate(date: Date())
        
        //Board image should be udpated as well when back pressed
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    @IBAction func addFormationPressed(_ sender: Any) {
        //TODO - sometimes the image is not updated, so update here? by calling load
        formationArray = formationVM.loadFormations() //TODO - is this needed

        if let imageData = dancerVM.imageToData(view: stageView){
            formationVM.updateFormImage(data: imageData)
            
            if let curr = formationVM.getCurrentIndex(){
                if curr + 1 != formationArray.count{
                    formationVM.updatePosition(type: PositionType.add)
                }
            }
            
            formationVM.createNewFormation(formData: imageData)
            
            if let curr = formationVM.getCurrentIndex(){
                    formationVM.setCurrentSelection(index: curr + 1)
            }
             //TODO *** check to see where/when all form updates is called b/c everytime its called selection is set
            allFormUpdates()
            if let currForm = formationVM.getFormation(type: FormationType.current){
                dancerVM.loadDancers(selectedFormation: currForm, current: true)
            }
            else{
                print("Error finding current formation in load dancers")
            }
            
            }
        else{
            
            print("Error in setting imageData when formation is added")
        }
        
        
    }
    
    
    @IBAction func addMusicPressed(_ sender: UIButton) {
        let nextVC = storyboard?.instantiateViewController(identifier: "MusicViewController") as! MusicViewController
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    @IBAction func formTimingPressed(_ sender: UIButton) {
        let nextVC = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
        //nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
        
        
        
    }
    
    
    @IBAction func playFormationsPressed(_ sender: Any) {
        self.stage.arrayOfActions = []
        formationVM.setCurrentSelection(index: 0)
        if let curr = formationVM.getFormation(type: FormationType.current){
            let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
            stage.formationSelected(dancers: dancers)
        }
        else{
            print("Error loading in play formations pressed ")
        }
        var waitT = 0.0
        
        ///The action is indeed cancelled(it actually finished when you start playing) but it will not stop the audio. Use SKAudioNode if you need to suddenly stop sounds
        if let music = musicUrl{
            if !musicToggleButton.isSelected{
            self.stage.playSong(musicLink: music)
            }
            else{
                print("Music Toggle Not Selected", musicToggleButton.isSelected)
            }
        }
        
        //formationVM.setCurrentSelection(index: 0)
        
        for _ in 0..<formationVM.formationArray.count{

                
               // print(formationVM.currentFormation?.name)
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                    let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    let time = Double(nextFormation.waitTime)
                    self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: time, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                
                    waitT = 3.0

                    formationVM.setCurrentSelection(index: index + 1)
            
            

        }

    }
        
            self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
        }
        
    }
    
    @IBAction func labelTextFieldChanged(_ sender: UITextField) {
        //print("Label changed")
                if let text = nodeLabelTextField.text{
                    self.stage.updateDancerLabel(label: text)
                    if let nodeId = self.stage.currentNode?.nodeId{
                        dancerVM.updateDancerLabel(id: nodeId, label: text)
                        if let imageData = dancerVM.imageToData(view: stageView){
                        
                        formationVM.updateFormImage(data: imageData)
                        allFormUpdates()
                    }
        
                }

    }
    }
    
    
    @IBAction func colorPickerButton(_ sender: UIButton) {
        colorPicker.supportsAlpha = true
        present(colorPicker, animated: true)
        selectedColor = colorPicker.selectedColor
    }
    
    @IBAction func removeFormation(_ sender: UIButton) {
        
        if let toRemove = formationVM.getFormation(type: FormationType.current){
            formationVM.updatePosition(type: PositionType.remove)

        
            if let currIndex = formationVM.getCurrentIndex(){
                if currIndex - 1 == -1{
                    formationVM.createNewFormation(formData: nil)
                }
                else if currIndex - 1 != -1 && currIndex + 2 != formationArray.count{
                    formationVM.setCurrentSelection(index: currIndex)
                }
                else if currIndex - 1 != -1 && currIndex + 2 == formationArray.count{
                    formationVM.setCurrentSelection(index: currIndex)
                }
                else{
                    formationVM.setCurrentSelection(index: currIndex - 1)
                }
                
            }
            
            formationVM.removeFormation(form: toRemove)
            allFormUpdates()
            
            
            if let curr = formationVM.getFormation(type: FormationType.current){
                let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
                stage.formationSelected(dancers: dancers)
            }
            else{
                print("Error loading in didSelect")
            }
            
            allFormUpdates()
            
    }
    }
    
    @IBAction func nextFormationPlay(_ sender: UIButton) {
        
        self.stage.arrayOfActions = []
        
        if let nextFormation = formationVM.getFormation(type: FormationType.next){
            
                let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
            if let nextIndex = formationVM.getCurrentIndex(){
                formationVM.setCurrentSelection(index: nextIndex + 1)
            }
            if let index = formationVM.getCurrentIndex(){
                self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: index, totalForms: formationArray.count)
            }
        }
        
        self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
        
    }
    
    
    @IBAction func prevFormationPlay(_ sender: UIButton) {
        self.stage.arrayOfActions = []

        if let nextFormation = formationVM.getFormation(type: FormationType.previous){
                let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
            if let nextIndex = formationVM.getCurrentIndex(){
                formationVM.setCurrentSelection(index: nextIndex + 1)
            }
            if let index = formationVM.getCurrentIndex(){
                self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: index, totalForms: formationArray.count)
            }
        }
        
        
        self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
    }
    
    
    @IBAction func labelTogglePressed(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        stage.showLabel = sender.isSelected
        stage.nodeLabelHelper()
    }
    
    
    @IBAction func musicTogglePressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        print("Music Selection, ", sender.isSelected)
        stage.musicEnabled = !sender.isSelected
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
        cell.formNameTextfield.delegate = self
        cell.formNameTextfield.text = ""
        if let item = formationVM.getFormation(type: FormationType.atLocation(indexPath.row)){
            if let formationData = item.image{
                let cellImage = UIImage(data: formationData)
                cell.formationImage?.image = cellImage
            }
            if let name = item.name{
                if name != ""{
                    print("Index Path Name", indexPath.row, item.name)
                    cell.formNameTextfield?.text = item.name
                }
            }
        }

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! FormationSnapshotCell
        //currentCell.se
        formationVM.setCurrentSelection(index: indexPath.row)
        if let curr = formationVM.getFormation(type: FormationType.current){
            let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
            stage.formationSelected(dancers: dancers, index: indexPath)

        }
        else{
            print("Error loading in didSelect")
        }
        
    }
    
    
    
}

//MARK: - KEYBOARD EXTENSIONS
extension GameViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("In Return")
        switch textField {
        case nodeLabelTextField:
            print()
        default:
            formationVM.updateFormLabel(label: textField.text)
        }
        
        textField.resignFirstResponder()
        view.frame.origin.y = 0
        allFormUpdates()

        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
            case nodeLabelTextField:
                self.backgroundSV = hieracrchyView
                return enableText

            default:
                let cell: UITableViewCell = textField.superview?.superview as! FormationSnapshotCell //TODO: REFACTOR
                let table: UITableView = cell.superview as! UITableView
                let path = table.indexPath(for: cell)
                var retVal = false
                if let currIndex = formationVM.getCurrentIndex(){
                    if currIndex == path?.row{
                        retVal = true
                    }
                    else{
                        retVal = false
                    }
                }
                return retVal
        }
        //return enableText
    }
    
}

//MARK: - GAMESCENE Delegate/Protocols
extension GameViewController: GameSceneUpdatesDelegate{

    
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String) {
        
        if let curr = formationVM.getFormation(type: FormationType.current){
            print("Current Index", formationVM.getCurrentIndex()!)
        
        dancerVM.addDancer(xPosition: xPosition, yPosition: yPosition, label: label, id: id, color: color, selectedFormation: curr)
        }
        dancerVM.saveDancer()
        
        if let imageData = dancerVM.imageToData(view: stageView) {
        formationVM.updateFormImage(data: imageData)
        }
        allFormUpdates()
    }
    
    func dancerMoved(id: String, xPosition: Float, yPosition: Float) {
        if let curr = formationVM.getFormation(type: FormationType.current){
            dancerVM.updateDancerPosition(id: id, xPosition: xPosition, yPosition: yPosition, owner: curr)
        }
        else{
            print("Cannot Find Curr Formation")
        }
        
        
        dancerVM.saveDancer()
        if let imageData = dancerVM.imageToData(view: stageView) {
        formationVM.updateFormImage(data: imageData)
        }
        allFormUpdates()
    }
    
    func enableTextField(enable: Bool, id: String) {
        enableText = enable
        if enableText{
            nodeLabelTextField.text = dancerVM.getDancer(id: id)?.label ?? ""
        }
        else{
            nodeLabelTextField.text = ""
        }
        //print(enableText)
    }
    
    func updateNodeColor(color: UIColor) {
        stage.selectedColor = color
        selectedColor = color
        nodeColorButton.backgroundColor = selectedColor
    }
    
    func removedDancer(id: String) {
        dancerVM.removeDancer(dancerId: id)
        dancerVM.saveDancer()
        if let imageData = dancerVM.imageToData(view: stageView){
            formationVM.updateFormImage(data: imageData)
        }
        allFormUpdates()
    }
    
    func updateFormationSelected(index: IndexPath) {
        DispatchQueue.main.async {
            self.formsTableView.selectRow(at: index, animated: true, scrollPosition: .top)
            self.enableText = false
            self.nodeLabelTextField.text = ""

        
        }
        
    }
    
}
  
extension GameViewController: FormUpdatesDelegate{
    //Called everytime Formation data is loaded
    func formUpdated(formArray: [Formation]) {

        formationArray = formArray
        
        DispatchQueue.main.async {
            self.formsTableView.reloadData()
            if let currIndex = self.formationVM.getCurrentIndex(){
            let newPath = IndexPath(row: currIndex, section: 0)
            self.formsTableView.selectRow(at: newPath, animated: true, scrollPosition: .top)
        }
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
        stage.selectedColor = selectedColor
        self.stage.updateDancerColor(color: colorString)

        if let nodeId = self.stage.currentNode?.nodeId{
            dancerVM.updateDancerColor(id: nodeId, color: colorString)
            dancerVM.saveDancer()
            if let imageData = dancerVM.imageToData(view: stageView){
                formationVM.updateFormImage(data: imageData)
            }
        allFormUpdates()
        }

}
}

extension GameViewController: MusicChosenDelegate{
    
    func musicChosen(url: URL) {
        self.musicUrl = url
        self.musicToggleButton.isEnabled = true
        //set button to enabled
        //there should be a property in stage music, when play is pressed, parameter music? = nil
        //based on music toggle, music should be nil or not
        boardVM.updateBoardSong(songUrl: "\(url)")
    }
}

extension GameViewController{
    
    func updateWaitTime(time: Float64){
        //Calculate time - formation before wait time
        //if cannot load music - default all to 3.0
        if let prev = formationVM.getFormation(type: FormationType.previous){
            let currWait = 3 - 2
            //Timing of previous - timing of current selected - meaning save song times
            
            
        }
        //formationVM.updateFormWaitTime(time: <#T##Int#>)
        
    }
}


//TODO: - Next Formation Pressed - DONE

//TODO: - Previous Formation Pressed - DONE

//TODO: - Play Formations all way

//TODO: - Undo

//TODO: - if there's a dancer already at that location, can't put it there

//TODO: - when making changes to a dancer in one formation - make sure you're making those changes to the same dancers in ALL formations. Ex: in F1 - color blue, F2 - color yellow - should BE SAME
