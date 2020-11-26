
import UIKit
import SpriteKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: UIViewController{
    
    
    @IBOutlet weak var formsTableView: UITableView!

    @IBOutlet weak var squareView: SKView!
    @IBOutlet weak var musicSlider: UISlider!
    
    
    
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var formationArray: [Formation] = []
    var sceneGridFinished = false
    var currIndexPath: IndexPath?
    var audioPlayer = AVAudioPlayer()
    var player: AVAudioPlayer!

    //let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
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
        var waitT = 0.0
        //player.play()
        //musicPlayer.play()
               
                for i in formationVM.currentIndex..<formationVM.formationArray.count{
                    
                    if let currentPath = self.currIndexPath{

                    print(formationVM.currentFormation?.name)
                    if let nextFormation = formationVM.getNextFormation(){
                    let nextDancerForms = dancerVM.loadNextDancers(nextFormation: nextFormation)
                        formationVM.currentFormation = nextFormation
                        
                        
                        print("New Current Path ", currentPath.row)

                
                    self.scene1.playThroughFormations(dancers: nextDancerForms, waitTime: waitT, transitionTime: 2.0)
                    
                        waitT = 4.0
                
                //for i in currentPath.row..<self.formationArray.count{
                //self?.playFormations


                }
                    
                    formationVM.currentIndex += 1
       
    }
                    //currIndexPath = IndexPath(row: formationVM.currentIndex, section: 0)
                self.scene1.run(SKAction.sequence(self.scene1.arrayOfActions))
                    
                    let currNext = IndexPath(row: formationVM.currentIndex, section: 0)

               
    }
        player.stop()
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
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! FormationSnapshotCell
        formationVM.setCurrentSelection(index: indexPath.row)
        var curr = formationVM.getCurrentFormation()
        var dancers = dancerVM.loadDancers(selectedFormation: curr)
        //currentCell.selectionStyle = .blue
        //currentCell.setSelected(true, animated: true)
        currentCell.setHighlighted(false, animated: false)
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
       
        var imageData = dancerVM.imageToData(view: squareView)
        formationVM.getCurrentFormation().image = imageData
        formationVM.saveFormation()
        formationArray = formationVM.loadFormations()
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
 
}



//MARK: - Music

extension GameViewController: AVAudioPlayerDelegate{

    @IBAction func uploadMusic(sender: UIButton){
        
        let mediaItems = MPMediaQuery.songs().items
             let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
       // print("mediaCollectionItems: \(String(describing: mediaCollection.items[0].title))") //It's alwa
        if mediaCollection.items.count > 0{
             let item = mediaCollection.items[0]
             let pathURL = item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        

        //let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Bulleya", ofType: "mp3")!)

        do{
            //player = try AVAudioPlayer(contentsOf: unwrappedPath)
            
            player = try! AVAudioPlayer(contentsOf: pathURL as URL)
            print(pathURL)
            print("AudiPlayer set")
            player.delegate = self
            player.prepareToPlay()
            player.play()
        }
        catch{
            print(error)
        }
        
        
        
    }
    
    
    }
    
}





