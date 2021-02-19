
import UIKit
import SpriteKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: KeyUIViewController{
    
    //navigation
    @IBOutlet var hieracrchyView: UIView!
    @IBOutlet weak var formsTableView: UITableView!
    
    @IBOutlet weak var stageView: SKView!
    @IBOutlet weak var formOptionsView: UIView!
    
    @IBOutlet weak var nodeLabelTextField: UITextField!
    @IBOutlet weak var nodeColorButton: UIButton!
    @IBOutlet weak var nodeLabelButton: UIButton!
    
    @IBOutlet weak var addNodeButton: UIButton!
    
    @IBOutlet weak var playMusicButton: UIButton!
    @IBOutlet weak var musicScrubberButton: UIButton!
    @IBOutlet weak var addMusicButton: UIButton!
    
    @IBOutlet weak var deleteFormsButton: UIButton!
    @IBOutlet weak var addFormsButton: UIButton!
    
    @IBOutlet weak var playFormsButton: UIButton!
    @IBOutlet weak var prevFormsButton: UIButton!
    @IBOutlet weak var nextFormsButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    
    var boardVM = BoardViewModel.shared
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    
    var selectedColor = #colorLiteral(red: 0.7844313979, green: 0.8708675504, blue: 0.9458972812, alpha: 1)
    var colorPicker = UIColorPickerViewController()
    
    var musicUrl: URL? = nil
    var stage: StageScene!
    
    var enableText: Bool = false
    var enableMusic: Bool = false{
        didSet{
            self.playMusicButton.isHidden = !enableMusic
            self.musicScrubberButton.isHidden = !enableMusic
            self.stage.musicEnabled = enableMusic
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gets the board
        formationVM.currentBoard = boardVM.getCurrentBoard()
        
        //Define Stage properties
        stage = StageScene(size: stageView.frame.size)
        stage.scaleMode = .fill
        stage.myDelegate = self
        stage.selectedColor = selectedColor
        stageView.presentScene(stage)
        
        self.title = boardVM.getCurrentBoard()?.name ?? "Formations"
        
        nodeColorButton.layer.masksToBounds = true
        nodeColorButton.layer.cornerRadius = nodeColorButton.frame.width/2
        
        //Define labelToggle properties
        nodeLabelButton.setImage(UIImage(systemName: "person.fill.checkmark"),
                                 for: [.highlighted, .selected])
        nodeLabelButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: [.highlighted, .selected])
        
        nodeLabelTextField.isHidden = true
        nodeLabelTextField.layer.borderWidth = 1
        nodeLabelTextField.layer.borderColor = #colorLiteral(red: 0.0120000001, green: 0.9689999819, blue: 0.9219999909, alpha: 1)
        nodeLabelTextField.layer.cornerRadius = 2
        nodeColorButton.backgroundColor =  UIColor.yellow
        
        stopButton.isHidden = true
        
        //Define Tableview properties
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        nodeLabelTextField.delegate = self
        formsTableView.dataSource = self
        formsTableView.delegate = self
        colorPicker.delegate = self
        formationVM.delegate = self
        
        formationArray = formationVM.loadFormations()
        if formationArray.count == 0{
            formationVM.createNewFormation()
            formationVM.setCurrentSelection(index: 0)
        }
        else{
            presentFormation(first: true)
        }
        allFormUpdates()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentFormation()
        allFormUpdates()
        
        do{
            if let boardSong = boardVM.getCurrentBoard()?.song{
                guard let music = URL(string: boardSong) else { print("GVC: Music -> URL error");  return}
                _ = try AVAudioPlayer(contentsOf: music)
                musicUrl = music
                enableMusic = true
            }
            else{
                print("No song")
                enableMusic = false
            }
            
        }
        catch{
            print("GVC: Music setup error")
            playMusicButton.isEnabled = false
            musicScrubberButton.isEnabled = false
            stage.musicEnabled = false
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        boardVM.updateBoardDate(date: Date())
        let image = formationVM.getFormation(type: .atLocation(0))?.image
        boardVM.updateBoardImage(imageData: image)
        self.stage.endActionsHelper()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    @IBAction func addFormationPressed(_ sender: Any) {
        
        let newSceneData = ImageDataManager.sceneToData(view: stageView) ?? #imageLiteral(resourceName: "defaultFormImage").jpegData(compressionQuality: 1.0)
        formationVM.updateFormImage(imageData: newSceneData)
        
        guard let currIndex = formationVM.getCurrentIndex() else { return }
        if currIndex + 1 != formationArray.count{
            formationVM.updatePosition(type: PositionType.add)
        }
        
        formationVM.createNewFormation(imageData: newSceneData)
        formationVM.setCurrentSelection(index: currIndex + 1)
        allFormUpdates()
        
        if let currForm = formationVM.getFormation(type: FormationType.current){
            _ = dancerVM.loadDancers(selectedFormation: currForm, current: true)
        }
        else{
            print("GVC - Error in getFormation Current")
        }
        
    }
    
    
    @IBAction func addMusicPressed(_ sender: UIButton) {
        let nextVC = storyboard?.instantiateViewController(identifier: "MusicViewController") as! MusicViewController
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    @IBAction func musicScrubberPressed(_ sender: UIButton) {
        
        guard let music = musicUrl else { return }
        let nextVC = storyboard?.instantiateViewController(identifier: "MusicScrubberViewController") as! MusicScrubberViewController
        nextVC.delegate = self
        nextVC.audioURL = music
        nextVC.song = boardVM.getCurrentBoard()?.songName ?? ""
        
        let prev = formationVM.getFormation(type: FormationType.previous)?.songTime
        let curr = formationVM.getFormation(type: FormationType.current)?.songTime
        let next = formationVM.getFormation(type: FormationType.next)?.songTime
        
        nextVC.prevSongTiming = prev
        nextVC.currSongTiming = curr
        nextVC.nextSongTiming = next
        
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    
    @IBAction func playFormationsPressed(_ sender: Any) {
        
        guard formationArray.count > 1, let currIndex = formationVM.getCurrentIndex() else { return }
        
        hideDetailButtons()
        disableStageTouch()
        stage.arrayOfActions = []
        let defaultWait  = 3.0
        
        for _ in currIndex..<formationVM.formationArray.count{
            
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    
                    stage.playThroughFormations(dancers: nextDancerForms, waitTime: defaultWait, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                    formationVM.setCurrentSelection(index: index + 1)
                }
                
            }
            self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
            
        }
        
    }
    
    
    @IBAction func labelTextFieldChanged(_ sender: UITextField) {
        
        if let text = nodeLabelTextField.text{
            stage.updateDancerLabel(label: text) //update on stage
            if let nodeId = self.stage.currentNode?.nodeId{
                dancerVM.updateDancerLabel(id: nodeId, label: text) //update on backend
                if let imageData = ImageDataManager.sceneToData(view: stageView){
                    formationVM.updateFormImage(imageData: imageData)
                    allFormUpdates()
                }
                
            }
            
        }
    }
    
    
    @IBAction func colorPickerButton(_ sender: UIButton) {
        colorPicker.supportsAlpha = true
        colorPicker.selectedColor = selectedColor
        present(colorPicker, animated: true)
        
    }
    
    
    @IBAction func addStageNode(_ sender: UIButton) {
        
        stage.addStageNode()
        
    }
    
    @IBAction func removeFormation(_ sender: UIButton) {
        //current 1 alert
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this formation?",  preferredStyle: UIAlertController.Style.alert)
        if let toRemove = formationVM.getFormation(type: FormationType.current){
            
            //formationVM.updatePosition(type: PositionType.remove)
            
            
            if let currIndex = formationVM.getCurrentIndex(){
                
                alert.addAction(UIAlertAction(title: "Cancel",
                                              style: UIAlertAction.Style.default,
                                                      handler: { (_: UIAlertAction!) in
                        }))
                
                alert.addAction(UIAlertAction(title: "Delete",
                                              style: UIAlertAction.Style.default,
                                                      handler: { [weak self] (_: UIAlertAction!) in
                                                        guard let formationVM = self?.formationVM, let self = self else { return }
                                                        formationVM.updatePosition(type: PositionType.remove)
                                                        formationVM.removeFormation(form: toRemove)
                                                        self.formationArray = formationVM.loadFormations(callDelegate: false)
                                                        
                                                        if currIndex - 1 == -1 && self.formationArray.count < 1{
                                                            formationVM.createNewFormation()
                                                            formationVM.setCurrentSelection(index: currIndex)
                                                            
                                                        }
                                                        else if currIndex - 1 == -1 && self.formationArray.count >= 1{
                                                            formationVM.setCurrentSelection(index: currIndex)
                                                            
                                                        }
                                                        else if currIndex - 1 != -1 && currIndex + 2 <= self.formationArray.count{
                                                            formationVM.setCurrentSelection(index: currIndex)
                                                        }
                                                        else{
                                                            formationVM.setCurrentSelection(index: currIndex - 1)
                                                        }
                         
                                                        self.allFormUpdates()
                                                        self.presentFormation()
                        }))
                
                //formationVM.removeFormation(form: toRemove)
                //handleRemoveForm(toRemove: toRemove)
//                self.formationArray = formationVM.loadFormations(callDelegate: false)
//                print(formationArray.count)
//                if currIndex - 1 == -1 && formationArray.count < 1{
//                    formationVM.createNewFormation()
//                    formationVM.setCurrentSelection(index: currIndex)
//
//                }
//                else if currIndex - 1 == -1 && formationArray.count >= 1{
//                    formationVM.setCurrentSelection(index: currIndex)
//
//                }
//                else if currIndex - 1 != -1 && currIndex + 2 <= formationArray.count{
//                    formationVM.setCurrentSelection(index: currIndex)
//                }
//                else{
//                    formationVM.setCurrentSelection(index: currIndex - 1)
//                }
                
            }
            self.present(alert, animated: true, completion: nil)
        
            
        }
    }
    
    @IBAction func nextFormationPlay(_ sender: UIButton) {
        
        self.stage.arrayOfActions = []
        
        if let nextFormation = formationVM.getFormation(type: FormationType.next){
            disableStageTouch()
            ableDetailButtons(enable: false)
            
            let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
            if let currIndex = formationVM.getCurrentIndex(){
                formationVM.setCurrentSelection(index: currIndex + 1)
            }
            if let index = formationVM.getCurrentIndex(){
                self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: index, totalForms: formationArray.count, playAll: false)
                let enableTouchAction = SKAction.run {
                    self.enableTouches()
                }
                stage.arrayOfActions.append(SKAction.wait(forDuration: 2.0))
                stage.arrayOfActions.append(enableTouchAction)
            }
        }
        
        self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
        
    }
    
    
    @IBAction func prevFormationPlay(_ sender: UIButton) {
        self.stage.arrayOfActions = []
        
        if let nextFormation = formationVM.getFormation(type: FormationType.previous){
            disableStageTouch()
            ableDetailButtons(enable: false)
            let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
            if let currIndex = formationVM.getCurrentIndex(){
                formationVM.setCurrentSelection(index: currIndex - 1)
            }
            if let index = formationVM.getCurrentIndex(){
                self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: index, totalForms: formationArray.count, playAll: false)
            }
            
            let enableTouchAction = SKAction.run {
                self.enableTouches()
            }
            stage.arrayOfActions.append(SKAction.wait(forDuration: 2.0))
            stage.arrayOfActions.append(enableTouchAction)
        }
        
        
        self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
    }
    
    
    @IBAction func labelTogglePressed(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        stage.showLabel = sender.isSelected
        stage.nodeLabelHelper()
    }
    
    
    @IBAction func musicTogglePressed(_ sender: UIButton) {
        
        guard formationArray.count > 1 else { return }
        guard stage.musicEnabled == true, let music = musicUrl else { print("GVC - error retrieving music URL")
            return }
        
        self.stage.arrayOfActions = []
        self.hideDetailButtons()
        self.disableStageTouch()
        
        presentFormation(first: true)
        
        self.stage.playSong(musicLink: music)
        
        for _ in 0..<formationVM.formationArray.count{
            
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    let time = self.calculateWaitHelper(withMusic: true)
                    
                    self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: time, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                    
                    formationVM.setCurrentSelection(index: index + 1)
                }
                
            }
            
            self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
        }
        
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        
        let nextVC = storyboard?.instantiateViewController(identifier: "InstructionsTableViewController") as! InstructionsTableViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        stage.endActionsHelper()
        presentFormation()
        showDetailButtons()
        
    }
    
    func allFormUpdates(){
        
        formationVM.saveFormation()
        _ = formationVM.loadFormations()
    }
    
    func presentFormation(first: Bool = false){
        if first{
            formationVM.setCurrentSelection(index: 0)
        }
        guard let curr = formationVM.getFormation(type: FormationType.current) else { return }
        let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
        let indexPath = IndexPath(row: Int(curr.position), section: 0)
        stage.formationSelected(dancers: dancers, index: indexPath)
    }
    
    func hideDetailButtons(){
        
        DispatchQueue.main.async {
            
            self.nodeColorButton.isHidden = true
            self.nodeLabelTextField.isHidden = true
            self.addNodeButton.isHidden = true
            self.playMusicButton.isHidden = true
            self.musicScrubberButton.isHidden = true
            
            self.addFormsButton.isHidden = true
            
            self.deleteFormsButton.isHidden = true
            
            self.prevFormsButton.isHidden = true
            
            self.nextFormsButton.isHidden = true
            
            self.addMusicButton.isHidden = true
            
            self.nodeLabelButton.isHidden = true
            
            self.playFormsButton.isHidden = true
            self.stopButton.isHidden = false
            
        }
    }
    
    
    func showDetailButtons(){
        
        self.nodeColorButton.isHidden = false
        self.playMusicButton.isHidden = !enableMusic
        self.musicScrubberButton.isHidden = !enableMusic
        self.addMusicButton.isHidden = false
        self.addFormsButton.isHidden = false
        
        self.deleteFormsButton.isHidden = false
        
        self.prevFormsButton.isHidden = false
        
        self.nextFormsButton.isHidden = false
        
        
        self.nodeLabelButton.isHidden = false
        self.addNodeButton.isHidden = false
        
        self.playFormsButton.isHidden = false
        
        self.stopButton.isHidden = true
    }
    
    
    func ableDetailButtons(enable: Bool){
        DispatchQueue.main.async {
            
            self.nodeColorButton.isEnabled = enable
            self.playMusicButton.isEnabled = enable
            self.musicScrubberButton.isEnabled = enable
            self.addMusicButton.isEnabled = enable
            self.addFormsButton.isEnabled = enable
            
            self.deleteFormsButton.isEnabled = enable
            
            self.prevFormsButton.isEnabled = enable
            self.nextFormsButton.isEnabled = enable
            
            
            self.nodeLabelButton.isEnabled = enable
            self.addNodeButton.isEnabled = enable
            
            self.playFormsButton.isEnabled = enable
        }
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
        cell.formNameTextfield.layer.borderWidth = 1
        cell.formNameTextfield.layer.borderColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
        if let item = formationVM.getFormation(type: FormationType.atLocation(indexPath.row)){
            if let formationStr = item.image{
                if let cellImage = ImageDataManager.dataToImage(dataStr: formationStr){
                    cell.formationImage?.image = cellImage
                }
            }
            else{
                cell.formationImage?.image = UIImage(named: "defaultFormImage")!
            }
            if let name = item.name{
                if name != ""{
                    // print("Index Path Name", indexPath.row, item.name ?? "Error")
                    cell.formNameTextfield?.text = item.name
                }
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        _ = tableView.cellForRow(at: indexPath) as! FormationSnapshotCell
        //currentCell.se
        formationVM.setCurrentSelection(index: indexPath.row)
        presentFormation()
        enableTouches()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(self.view.frame.size.height * 0.35)
        return self.view.frame.size.height * 0.35
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.35
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
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under 12 characters
        return updatedText.count <= 12
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
            if let imageData = ImageDataManager.sceneToData(view: stageView){
                formationVM.updateFormImage(imageData: imageData)
            }
            allFormUpdates()
        }
        
    }
}
