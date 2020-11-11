
import SpriteKit
import UIKit
import CoreData

protocol GameSceneUpdatesDelegate {
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String)
    
    func gridFinished(finished: Bool)
    
    func dancerMoved(id: String, xPosition: Float, yPosition: Float)
}


class GameScene: SKScene {
  
  var currentNode: DanceNode?
  var xArray: [CGFloat] = []
  var yArray: [CGFloat] = []
  var dancerLabel: String = ""
    var gridWidth: CGFloat = 0.0
    var gridHeight: CGFloat = 0.0
  var myDelegate : GameSceneUpdatesDelegate!

    var createFormationPressed: Bool = false
    var formationArray: [Formation] = []

    
    
  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.white

    gridWidth = view.bounds.width

    gridHeight = view.bounds.height
 

       //var gridCenter: CGPoint { return CGPoint(x: view.bounds.midX, y: view.bounds.midY) }
    
    drawGrid(width: gridWidth, height: gridHeight)
    
  }
  

  func drawGrid(width: CGFloat, height: CGFloat){
    

    let xIncrement: CGFloat = width/10
    var xCounter: CGFloat = 0.0
    var yCounter: CGFloat = 0.0
    let yIncrement: CGFloat = height/10
    var xLineNodes: [SKShapeNode] = []
    var yLineNodes: [SKShapeNode] = []
    for _ in 1...10
          {
      let path = UIBezierPath()
              let start = CGPoint(x: xCounter, y: 0)
              let end = CGPoint(x: xCounter, y:height)
              path.move(to: start)
              path.addLine(to: end)
              xArray.append(xCounter)
            
            let shapeNode = SKShapeNode(path: path.cgPath)
            shapeNode.strokeColor = UIColor.black
            //drawGrid(path: path, width: gridWidth, height: gridHeight)
            addChild(shapeNode)
            xCounter += xIncrement
            xLineNodes.append(shapeNode)
          }
    
    for _ in 1...10
    {
      let path = UIBezierPath()
        let start = CGPoint(x: 0, y: yCounter)
        let end = CGPoint(x: width, y:yCounter)
        path.move(to: start)
        path.addLine(to: end)
      yArray.append(yCounter)
      
      let shapeNode = SKShapeNode(path: path.cgPath)
      shapeNode.strokeColor = UIColor.black
      //drawGrid(path: path, width: gridWidth, height: gridHeight)
      addChild(shapeNode)
      yCounter += yIncrement
      yLineNodes.append(shapeNode)
    }
    
    self.myDelegate.gridFinished(finished: true)
    
  }
        

  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first {
          let location = touch.location(in: self)
          
          let touchedNodes = self.nodes(at: location)
        if (touchedNodes.count == 0){
          
          var nearest = getNearestIntersection(x: location.x, y: location.y)
          //print("TOUCH LOCATION", location)
          let n = DanceNode(imageNamed: "circle")
          let label = SKLabelNode(text: dancerLabel)
          
          ////When text is changed it should get the currently selected Node and change it's text
          
          label.fontSize = 12.0
          label.color = UIColor.black
          

          //closestNode!.lineWidth = 20
          
             n.position = nearest
          label.position = CGPoint(x: 0, y: 16 )
          n.name = "draggable"
             
             self.addChild(n)
          //self.addChild(label)
          n.addChild(label)
            
            
//            let newDancer = Dancer(context: self.context)
//
//            //let formation = Formation(context: Dancer)
//
            let xPos = Float(n.position.x)
            let yPos = Float(n.position.y)
            n.nodeId = UUID().uuidString
            let color = "Black"
            let dancerId = n.nodeId
            self.myDelegate.dancerToAdd(xPosition: xPos, yPosition: yPos, id: dancerId, color: color)
            //self.saveDancers()
            

            
        }
          for node in touchedNodes.reversed() {
              if node.name == "draggable" {
                self.currentNode = (node as! DanceNode)
              }
          }
      }
  
    
    
  }
    
    //Instead of touches moved - try to do it at touches ended
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first, let node = currentNode {
          let touchLocation = touch.location(in: self)
        node.position = touchLocation

      }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first, let node = currentNode {
        let touchLocation = touch.location(in: self)
        node.position = touchLocation
      var id = node.nodeId
      print("Node ID", id)
        print("Moved", node.position.x, node.position.y)
        print("Moved", Float(node.position.x), Float(node.position.y))
      self.myDelegate.dancerMoved(id: id, xPosition: Float(node.position.x), yPosition: Float(node.position.y))

    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.currentNode = nil
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  func getNearestIntersection(x: CGFloat, y: CGFloat) -> CGPoint{
  
    var nearestX: CGFloat {
      xArray.reduce(0.0 as CGFloat){
          if abs($1 - x) < abs($0 - x){
          return CGFloat($1)
            
          }
          else{
            return CGFloat($0)
          }
  }
    }
    
    
    var nearestY: CGFloat {
      yArray.reduce(0.0 as CGFloat){
          if abs($1 - y) < abs($0 - y){
          return CGFloat($1)
            
          }
          else{
            return CGFloat($0)
          }
  }
    }
    
    return CGPoint(x: nearestX, y: nearestY)

  }
    
    
    func formationSelected(dancers: [Dancer]){
        
        self.removeAllChildren()
        drawGrid(width: gridWidth, height: gridHeight)
        print("DAncer ", dancers.count)
        for dancer in dancers{
        let n = DanceNode(imageNamed: "circle")
            n.nodeId = dancer.id!
        let label = SKLabelNode(text: dancerLabel)
            print("When Formation selected ids", dancer.id)
        
        ////When text is changed it should get the currently selected Node and change it's text
        
        label.fontSize = 12.0
        label.color = UIColor.black
        

        //closestNode!.lineWidth = 20
            
            n.position = CGPoint(x: CGFloat(dancer.xPos), y: CGFloat(dancer.yPos))
                        print("X ", n.position.x)
                        print("Y ", n.position.y)
        label.position = CGPoint(x: 0, y: 16 )
            
        n.name = "draggable"
           
           self.addChild(n)
        //self.addChild(label)
        n.addChild(label)
        
    }
    
}

}

class DanceNode: SKSpriteNode{
    
    var nodeId: String = ""
}

