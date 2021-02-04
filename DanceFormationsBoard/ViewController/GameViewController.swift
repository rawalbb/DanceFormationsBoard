
import UIKit
import SpriteKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: KeyUIViewController{
    
    //navigation
    @IBOutlet var hieracrchyView: UIView!
    @IBOutlet weak var formsTableView: UITableView!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var stageView: SKView!
    @IBOutlet weak var formOptionsView: UIView!
    
    @IBOutlet weak var nodeLabelTextField: UITextField!
    @IBOutlet weak var nodeColorButton: UIButton!
    @IBOutlet weak var labelToggleButton: UIButton!
    
    @IBOutlet weak var musicToggleButton: UIButton!
    
    @IBOutlet weak var musicTimingButton: UIButton!
    
    
    
    
    
    
    var boardVM = BoardViewModel.shared
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    var enableText: Bool = false
    var selectedColor = #colorLiteral(red: 1, green: 0.9019607902, blue: 0.3450980484, alpha: 1)
    var colorPicker = UIColorPickerViewController()
    var musicUrl: URL? = nil
    var stage: StageScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.backBarButtonItem = UIBarButtonItem(
//            title: "Something Else", style: .plain, target: nil, action: nil)

        
        //Formation Options Properties
        formOptionsView.layer.cornerRadius = 20
        formOptionsView.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        formOptionsView.layer.borderWidth = 2
        formOptionsView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor

        nodeColorButton.layer.masksToBounds = true
        nodeColorButton.layer.cornerRadius = nodeColorButton.frame.width/2
        
       //Gets the board
        formationVM.currentBoard = boardVM.getCurrentBoard()
        
        
        //Define Stage properties
        stage = StageScene(size: stageView.bounds.size)
        stage.scaleMode = .fill
        stage.myDelegate = self
        stage.selectedColor = selectedColor

        stageView.presentScene(stage) // TODO - have in viewdidload or viewdidappear

        
        self.title = boardVM.getCurrentBoard()?.name ?? "My Formations"
        
        //Define labelToggle properties
        labelToggleButton.setImage(UIImage(systemName: "person.fill.checkmark"),
                                   for: [.highlighted, .selected])
        labelToggleButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: [.highlighted, .selected])
        
        
        //musicToggleButton.isEnabled = false
//        musicToggleButton.setImage(#imageLiteral(resourceName: "defaultFormImage"),
//                                   for: [.highlighted, .selected])
//        musicToggleButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: [.highlighted, .selected])
        
        //Define Tableview properties
        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        formsTableView.dataSource = self
        formsTableView.delegate = self
        

        nodeLabelTextField.delegate = self
        nodeLabelTextField.isHidden = true
        nodeLabelTextField.layer.borderWidth = 1
        nodeLabelTextField.layer.borderColor = #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)
        nodeLabelTextField.layer.cornerRadius = 2
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
        
    //Check if there is music,

        do{
            //print("In Game View Controller getting song ", boardVM.getCurrentBoard()?.song)
            if let a = boardVM.getCurrentBoard()?.song{
                //AVAudioPlayer.prepareToPlay(<#T##self: AVAudioPlayer##AVAudioPlayer#>)
                //let path = Bundle.main.path(forResource: a, ofType:nil)!
                //let path = Bundle.main.path(forResource: <#T##String?#>, ofType: <#T##String?#>)
                guard let music = URL(string: a) else { print("URL Nil");  return}
                    _ = try AVAudioPlayer(contentsOf: music)

                
//                    _ = try AVAudioPlayer(contentsOf: music)
                musicUrl = URL(string: a)
                musicToggleButton.isEnabled = true
                musicTimingButton.isEnabled = true
                stage.musicEnabled = true
            }
            else{
                print("No song")
                musicToggleButton.isEnabled = false
                musicTimingButton.isEnabled = false
                stage.musicEnabled = false
            }
            
        }
        catch{
            print("Could Not do music")
            musicToggleButton.isEnabled = false
            musicTimingButton.isEnabled = false
            stage.musicEnabled = false
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        //TODO - sometimes the image is not updated, so update here? by calling load
        formationArray = formationVM.loadFormations() //TODO - is this needed

        if let newSceneData = ImageDataManager.sceneToData(view: stageView){
            formationVM.updateFormImage(imageData: newSceneData)
            
            if let curr = formationVM.getCurrentIndex(){
                if curr + 1 != formationArray.count{
                    formationVM.updatePosition(type: PositionType.add)
                }
            }
            formationVM.createNewFormation(imageData: newSceneData)
            
            if let curr = formationVM.getCurrentIndex(){
                    formationVM.setCurrentSelection(index: curr + 1)
            }
             //TODO *** check to see where/when all form updates is called b/c everytime its called selection is set
            allFormUpdates()
            if let currForm = formationVM.getFormation(type: FormationType.current){
               _ = dancerVM.loadDancers(selectedFormation: currForm, current: true)
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
        nextVC.delegate = self
           nextVC.audioURL = musicUrl!
        
        let prev = formationVM.getFormation(type: FormationType.previous)?.songTime
        let curr = formationVM.getFormation(type: FormationType.current)?.songTime
        let next = formationVM.getFormation(type: FormationType.next)?.songTime
        //print("Prev Curr Next", prev, curr, next)
        
        nextVC.prevSongTiming = prev
        nextVC.currSongTiming = curr
        nextVC.nextSongTiming = next
        
        self.navigationController?.pushViewController(nextVC, animated: true)
        
        
        
    }
    
    
    @IBAction func playFormationsPressed(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.detailView.isUserInteractionEnabled = false
            self.detailView.alpha = 0.3
        }
        
        
        
        self.stage.arrayOfActions = []
        formationVM.setCurrentSelection(index: 0)
        if let curr = formationVM.getFormation(type: FormationType.current){
            let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
            stage.formationSelected(dancers: dancers)
        }
        else{
            print("Error loading in play formations pressed ")
        }
        
        ///The action is indeed cancelled(it actually finished when you start playing) but it will not stop the audio. Use SKAudioNode if you need to suddenly stop sounds
//        if let music = musicUrl{
//            if !musicToggleButton.isSelected{
//            self.stage.playSong(musicLink: music)
//            }
//            else{
//                print("Music Toggle Not Selected", musicToggleButton.isSelected)
//            }
//        }
        
        //formationVM.setCurrentSelection(index: 0)
        
        //Gets initial wait time
        
        for _ in 0..<formationVM.formationArray.count{

             // print("In For loop")
               // print(formationVM.currentFormation?.name)
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                    let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    let time = self.calculateWaitHelper()
                   // print("Second Wait Time", time)
                    self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: time, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                
                    //waitT = 3.0

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
                        if let imageData = ImageDataManager.sceneToData(view: stageView){
                            formationVM.updateFormImage(imageData: imageData)
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
        //current 1
        if let toRemove = formationVM.getFormation(type: FormationType.current){
            
            formationVM.updatePosition(type: PositionType.remove)

        
            if let currIndex = formationVM.getCurrentIndex(){
                if currIndex - 1 == -1{

                    formationVM.createNewFormation()
                    formationVM.setCurrentSelection(index: currIndex)
                    
                }
                else if currIndex - 1 != -1 && currIndex + 2 <= formationArray.count{
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
                print("In remove form dancers count", dancers.count)
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
            if let currIndex = formationVM.getCurrentIndex(){
                formationVM.setCurrentSelection(index: currIndex - 1)
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
//        sender.isSelected = true
//        ///print("Music Selection, ", sender.isSelected)
        //stage.musicEnabled = true
        //guard case stage.musicEnabled == true else { return }
        if stage.musicEnabled{
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
            self.stage.playSong(musicLink: music)
        }
        else{
            print("Error playing song")
        }
        
        for _ in 0..<formationVM.formationArray.count{

             // print("In For loop")
               // print(formationVM.currentFormation?.name)
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                    let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    let time = self.calculateWaitHelper(withMusic: true)
                   // print("Second Wait Time", time)
                    self.stage.playThroughFormations(dancers: nextDancerForms, waitTime: time, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                
                    waitT = 3.0

                    formationVM.setCurrentSelection(index: index + 1)
        }

    }
        
            self.stage.run(SKAction.sequence(self.stage.arrayOfActions))
        }
        }
        else{
            showMusicAlert()
        }
        
    }
    
    func showMusicAlert() {
        let alert = UIAlertController(title: "Music", message: "No music detected",         preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Continue",
                                      style: UIAlertAction.Style.default,
                                              handler: {(_: UIAlertAction!) in
                }))
           
            self.present(alert, animated: true, completion: nil)
        }
    
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        
        let nextVC = storyboard?.instantiateViewController(identifier: "SceneKitViewController") as! SceneKitViewController
        nextVC.formationVM = formationVM
        nextVC.dancerVM = dancerVM
        //nextVC.boardVM = boardVM
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    
    func allFormUpdates(){
        
        formationVM.saveFormation()
        _ = formationVM.loadFormations()
    }
    
    
    
    
    func calculateWaitHelper(withMusic: Bool = false) -> Double{
        var wait = 3.0
        guard let curr = formationVM.getFormation(type: FormationType.current) else {
            return wait
        }
        if  let prev = formationVM.getFormation(type: FormationType.previous) {
        if !withMusic{
                wait = 3.0
            
        }
        if withMusic{
            wait = Double(curr.songTime - prev.songTime)
        }
   //go through and set all the wait times, prev + 3 to a certain amount initially when music is loaded
        //when edited, select next song times to be + 3 seconds after
        //when
        }
        else{
            wait = Double(curr.songTime)
        }
        return wait
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
        if let curr = formationVM.getFormation(type: FormationType.current){
            let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
            stage.formationSelected(dancers: dancers, index: indexPath)

        }
        else{
            print("Error loading in didSelect")
        }
        
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
