//
//import UIKit
//import SpriteKit
//import CoreData
//import AVFoundation
//import MediaPlayer
//
//class gviewcontroller: UIViewController{
//    
//    
//    @IBOutlet weak var formsTableView: UITableView!
//
//    @IBOutlet weak var squareView: SKView!
//    @IBOutlet weak var musicSlider: UISlider!
//    
//    @IBOutlet weak var labelTextField: UITextField!
//    @IBOutlet weak var nodeColorButton: UIButton!
//    
//    
//    
//    var formationVM = FormationViewModel()
//    var dancerVM = DancerViewModel()
//    var formationArray: [Formation] = []
//    var sceneGridFinished = false
//    var currIndexPath: IndexPath?
//    var audioPlayer = AVAudioPlayer()
//    var player: AVAudioPlayer!
//    var enableText: Bool = false
//    var colorPicker = UIColorPickerViewController()
//    var selectedColor = UIColor.black
//    //let musicPlayer = MPMusicPlayerController.systemMusicPlayer
//    
//    //var formimage: [UIImage] = [] //Don't need
//    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    //var formationArray: [Formation] = []
//    var scene1: GameScene!
//    //var newFormation: Formation!
//    
//    //Need Array of Formations
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        squareView.layer.borderWidth = 1
////        squareView.layer.borderColor = #colorLiteral(red: 0.3058823645, green: 0.8039215803, blue: 0.7686274648, alpha: 1).cgColor
//        scene1 = GameScene(size: squareView.bounds.size)
//        //squareView.ignoresSiblingOrder = true
//        scene1.scaleMode = .fill
//        
//        
//        
//        formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
//        formsTableView.dataSource = self
//        formsTableView.delegate = self
//        scene1.myDelegate = self
//        labelTextField.delegate = self
//        nodeColorButton.backgroundColor = selectedColor
//        colorPicker.delegate = self
//        scene1.selectedNodeColor = selectedColor
//        
//        //squareView.presentScene(scene1)
//        //squareView.backgroundColor = .blue
//        
//        formationArray = formationVM.loadFormations()
//
//
//        if formationArray.count == 0{
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
//        
//
//        
//        
//        for formation in formationArray{
//            var a = formation.dancers?.allObjects as! [Dancer]
//            //print("Formation INFO \(formation.name) ", a.count)
//        }
//        
//        
////        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
////               NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
////               NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        
//        }
//    
////    deinit {
////         NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
////         NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
////         NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
////     }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        squareView.presentScene(scene1)
//    }
//    
//    
//    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//
//    
//    @IBAction func nextFormationPressed(_ sender: Any) {
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
//    }
//    
//    
//    
//    @IBAction func playFormationsPressed(_ sender: Any) {
//        var waitT = 0.0
//        //player.play()
//        //musicPlayer.play()
//        
//        ///The action is indeed cancelled(it actually finished when you start playing) but it will not stop the audio. Use SKAudioNode if you need to suddenly stop sounds
//        self.scene1.playSong()
//
//        
//                for i in formationVM.currentIndex..<formationVM.formationArray.count{
//                    
//                    if let currentPath = self.currIndexPath{
//
//                    print(formationVM.currentFormation?.name)
//                    if let nextFormation = formationVM.getNextFormation(){
//                    let nextDancerForms = dancerVM.loadNextDancers(nextFormation: nextFormation)
//                        formationVM.currentFormation = nextFormation
//                        
//                        
//                        //print("New Current Path ", currentPath.row)
//
//                
//                        self.scene1.playThroughFormations(dancers: nextDancerForms, waitTime: waitT, transitionTime: 2.0, formIndex: formationVM.currentIndex, totalForms: formationArray.count)
//                    
//                        waitT = 4.0
//                
//                //for i in currentPath.row..<self.formationArray.count{
//                //self?.playFormations
//
//                        
//                }
//                    
//                    formationVM.currentIndex += 1
//       
//    }
//                    //currIndexPath = IndexPath(row: formationVM.currentIndex, section: 0)
//                    
//                    
//                    //self.scene1.endSong()
//
//                self.scene1.run(SKAction.sequence(self.scene1.arrayOfActions))
//                    
//                    let currNext = IndexPath(row: formationVM.currentIndex, section: 0)
//                    //self.scene1.arrayOfActions = []
//
//               
//    }
//        //player.stop()
//    }
//    
//
//    @IBAction func labelTextFieldChanged(_ sender: UITextField) {
//        print("Label changed")
//        if let text = labelTextField.text{
//            print(text)
//            self.scene1.updateDancerLabel(label: text)
//            if let nodeId = self.scene1.currentNode?.nodeId{
//            dancerVM.updateDancerLabel(id: nodeId, label: text)
//            var imageData = dancerVM.imageToData(view: squareView)
//            formationVM.getCurrentFormation().image = imageData
//            formationVM.saveFormation()
//            formationArray = formationVM.loadFormations()
//            formsTableView.reloadData()
//            }
//            
//        }
//    }
//    
//    
//    @IBAction func colorPickerButton(_ sender: UIButton) {
//        colorPicker.supportsAlpha = true
//        colorPicker.selectedColor = selectedColor
//        present(colorPicker, animated: true)
//    }
//    
//    
//    
//
//}
//
//extension gviewcontroller: UITableViewDataSource, UITableViewDelegate{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    
//        return formationArray.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = self.formsTableView.dequeueReusableCell(withIdentifier: "ReusableCell") as! FormationSnapshotCell
//        //cell.formationName.delegate = self
//        let index = formationVM.currentIndex
//        if indexPath.row == index {
//            //cell.backgroundColor = UIColor.blue
//            //cell.setSelected(true, animated: true)
//            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//        }
//        
//        let item = formationArray[indexPath.row]
//        if let formationData = item.image{
//            let cellImage = UIImage(data: formationData)
//            cell.formationImage?.image = cellImage
//        }
//        
//        cell.formationName?.text = item.name
//        return cell
//        
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let currentCell = tableView.cellForRow(at: indexPath) as! FormationSnapshotCell
//        formationVM.setCurrentSelection(index: indexPath.row)
//        var curr = formationVM.getCurrentFormation()
//        var dancers = dancerVM.loadDancers(selectedFormation: curr)
//        //currentCell.selectionStyle = .blue
//        //currentCell.setSelected(true, animated: true)
//        currentCell.setHighlighted(false, animated: false)
//        scene1.formationSelected(dancers: dancers)
//        currIndexPath = indexPath
//    }
//    
//    
//    
//
//    
//    
//    
//    
//}
//
////MARK: - KEYBOARD EXTENSIONS
//extension gviewcontroller: UITextFieldDelegate{
//    
//    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        //print("In Return")
//        textField.resignFirstResponder()
//        return true
//    }
//    
//    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//      return enableText
//    }
//    
////    @objc func keyboardWillChange(notification: Notification) {
////        view.frame.origin.y = -100
////    }
//    
//}
//
////MARK: - GAMESCENE Delegate/Protocols
//extension gviewcontroller: GameSceneUpdatesDelegate{
//    
//    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String) {
//        
//        let curr = formationVM.getCurrentFormation()
//
//        dancerVM.addDancer(xPosition: xPosition, yPosition: yPosition, label: label, id: id, color: color, selectedFormation: curr)
//        var imageData = dancerVM.imageToData(view: squareView)
//        formationVM.getCurrentFormation().image = imageData
//        formationVM.saveFormation()
//        formationArray = formationVM.loadFormations()
//        formsTableView.reloadData()
//    }
//    
//    
//    func gridFinished(finished: Bool) {
//        sceneGridFinished = true
//    }
//    
//    func dancerMoved(id: String, xPosition: Float, yPosition: Float) {
//        dancerVM.updateDancerPosition(id: id, xPosition: xPosition, yPosition: yPosition)
//       
//        var imageData = dancerVM.imageToData(view: squareView)
//        formationVM.getCurrentFormation().image = imageData
//        formationVM.saveFormation()
//        formationArray = formationVM.loadFormations()
//        formsTableView.reloadData()
//    }
//    
//    func updateCellSelect() {
//        let curr = IndexPath(row: self.formationVM.currentIndex, section: 0)
//        
//        DispatchQueue.main.async {
//            self.formsTableView.selectRow(at: curr, animated: true, scrollPosition: .top)
//        }
//    }
//    
//    func updateCellDeselect(){
//        
//        DispatchQueue.main.async {
//            let curr = IndexPath(row: self.formationVM.currentIndex, section: 0)
//            self.formsTableView.deselectRow(at: curr, animated: true)
//        }
//    }
//    
//    func enableTextField(enable: Bool) {
//        enableText = enable
//        //print(enableText)
//    }
//    
//    func updateNodeColor(color: UIColor) {
//        selectedColor = color
//        nodeColorButton.backgroundColor = selectedColor
//    }
//    
//    func removedDancer(id: String) {
//        dancerVM.removeDancer(dancerId: id)
//        var imageData = dancerVM.imageToData(view: squareView)
//        formationVM.getCurrentFormation().image = imageData
//        formationVM.saveFormation()
//        formationArray = formationVM.loadFormations()
//        formsTableView.reloadData()
//    }
// 
//}
//
//
//
////MARK: - Music
//
//extension gviewcontroller: AVAudioPlayerDelegate{
//
//    @IBAction func uploadMusic(sender: UIButton){
//        
////        let mediaItems = MPMediaQuery.songs().items
////             let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
////       // print("mediaCollectionItems: \(String(describing: mediaCollection.items[0].title))") //It's alwa
////        if mediaCollection.items.count > 0{
////             let item = mediaCollection.items[0]
////             let pathURL = item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
////
////
////        //let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Bulleya", ofType: "mp3")!)
////
////        do{
////            //player = try AVAudioPlayer(contentsOf: unwrappedPath)
////
////            player = try! AVAudioPlayer(contentsOf: pathURL as URL)
////           // print(pathURL)
////            //print("AudiPlayer set")
////            player.delegate = self
////            player.prepareToPlay()
////            player.play()
////        }
////        catch{
////            //print(error)
////        }
////
//        let formToDelete = formationVM.getCurrentFormation()
//        formationVM.removeFormation(form: formToDelete)
//        formationVM.setCurrentSelection(index: formationVM.currentIndex-1)
//        if formationVM.currentIndex == -1{
//            self.scene1.removeAllChildren()
//            formationVM.createNewFormation()
//        }
//        formationVM.saveFormation()
//        formationArray = formationVM.loadFormations()
//        formsTableView.reloadData()
//    }
//    
//    
//    }
//    
//
//
//extension gviewcontroller: UIColorPickerViewControllerDelegate{
//    
//    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
//        print("Did Dismiss Controller")
//    }
//    
//    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
//        selectedColor = viewController.selectedColor
//        nodeColorButton.backgroundColor = selectedColor
//       
//        let colorString = selectedColor.toHexString()
//        scene1.selectedNodeColor = selectedColor
//        self.scene1.updateDancerColor(color: colorString)
//        
//        if let nodeId = self.scene1.currentNode?.nodeId{
//            dancerVM.updateDancerColor(id: nodeId, color: colorString)
//        var imageData = dancerVM.imageToData(view: squareView)
//        formationVM.getCurrentFormation().image = imageData
//        formationVM.saveFormation()
//        formationArray = formationVM.loadFormations()
//        formsTableView.reloadData()
//        }
//    
//}
//}
//
//
//



//
//        var gradient: CAGradientLayer = {
//            let gradient = CAGradientLayer()
//            gradient.type = .axial
//            gradient.colors = [
//                #colorLiteral(red: 0.1098039216, green: 0.1215686275, blue: 0.1294117647, alpha: 1).cgColor,
//                #colorLiteral(red: 0.2693683384, green: 0.298371269, blue: 0.3166539141, alpha: 1).cgColor,
//                #colorLiteral(red: 0.3892080132, green: 0.4268733048, blue: 0.4268733048, alpha: 1).cgColor
//            ]
//
//
//            gradient.locations = [0, 0.5, 0.75]
//            return gradient
//        }()
//
//
//            gradient.frame = view.bounds
//
//        view.layer.insertSublayer(gradient, at: 0)




//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//               NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//               NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//        
//        }
//    
//    deinit {
//         NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
//         NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
//         NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
//     }
