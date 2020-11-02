
import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var squareView: SKView!
//    @IBOutlet weak var dancerLabel: UITextField!
//
//
//    @IBAction func buttonPressed(_ sender: UIButton) {
//      let label = (dancerLabel.text)!
//        scene1.dancerLabel = label
//    }
    
    
    var scene1: GameScene!
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scene1 = GameScene(size: squareView.bounds.size)
    //let skView = view as! SKView
    squareView.showsFPS = true
    squareView.showsNodeCount = true
    squareView.ignoresSiblingOrder = true
    scene1.scaleMode = .fill
    
    squareView.presentScene(scene1)


  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}
