
import UIKit
import SpriteKit

class GameViewController: UIViewController{
    
    
    @IBOutlet weak var formsTableView: UITableView!
    @IBOutlet weak var squareView: SKView!
//    @IBOutlet weak var dancerLabel: UITextField!
//
//
//    @IBAction func buttonPressed(_ sender: UIButton) {
//      let label = (dancerLabel.text)!
//        scene1.dancerLabel = label
//    }
    
    var formimage: UIImage?
    @IBAction func formationCreate(_ sender: Any) {
        
        let renderer = UIGraphicsImageRenderer(size: squareView.frame.size)
        print("SQUARE VIEW SIZE", squareView.frame.size)
        print(" VIEW SIZE", formsTableView.frame.size)
        let image = renderer.image { ctx in
            squareView.drawHierarchy(in: squareView.bounds, afterScreenUpdates: true)
            
        }
       
        formimage = image
        scene1.formationImage = image
        scene1.createFormationPressed = true
        self.formsTableView.reloadData()
        
    }
    
    var scene1: GameScene!
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scene1 = GameScene(size: squareView.bounds.size)
    //let skView = view as! SKView
    //squareView.showsFPS = true
    //squareView.showsNodeCount = true
    squareView.ignoresSiblingOrder = true
    scene1.scaleMode = .fill
    
    formsTableView.register(UINib(nibName: "FormationSnapshotCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
    formsTableView.dataSource = self
    formsTableView.delegate = self
    
    squareView.presentScene(scene1)


  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}


extension GameViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.formsTableView.dequeueReusableCell(withIdentifier: "ReusableCell") as! FormationSnapshotCell
        cell.formationName.delegate = self
        if let image = formimage{
            cell.formationImage?.image = image
        }
        
        cell.formationName?.text = "Formation 1"
        
        return cell
        
    }
    
    
}

extension GameViewController: UITextFieldDelegate{
                       
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    }

