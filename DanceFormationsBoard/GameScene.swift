
import SpriteKit

class GameScene: SKScene {
  
  var currentNode: SKSpriteNode?
  let player = SKSpriteNode(imageNamed: "player")
  var xArray: [CGFloat] = []
  var yArray: [CGFloat] = []
  var dancerLabel: String = ""
    
  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.gray
    // 3
//    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
//    // 4
//    addChild(player)
    
//       var gridWidthMultiple: CGFloat
//       {
//           return 10
//       }
//       var gridHeightMultiple : CGFloat
//       {
//           return 20
//       }

       var gridWidth: CGFloat
       {
        print(view.bounds.minX, view.bounds.maxX)
        print("FRAME", view.frame.minY, view.frame.maxY)
        return view.bounds.width
       }

       var gridHeight: CGFloat
       {
        print(view.bounds.minY, view.bounds.maxX)
        print("FRAME", view.frame.minX, view.frame.maxX)
        return view.bounds.height
       }

       var gridCenter: CGPoint {
        
        return CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
       }
    
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
    
    
  }
  
  
//  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    guard let touch = touches.first else {
//      return
//    }
//    let touchLocation = touch.location(in: self)
//    var nearest = getNearestIntersection(x: touchLocation.x, y: touchLocation.y)
//    print("TOUCH LOCATION", touchLocation)
//    let n = SKSpriteNode(imageNamed: "projectile")
//
//
//    //closestNode!.lineWidth = 20
//
//       n.position = nearest
//    n.name = "draggable"
//
//       self.addChild(n)
//  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first {
          let location = touch.location(in: self)
          
          let touchedNodes = self.nodes(at: location)
        if (touchedNodes.count == 0){
          
          var nearest = getNearestIntersection(x: location.x, y: location.y)
          print("TOUCH LOCATION", location)
          let n = SKSpriteNode(imageNamed: "circle")
          let label = SKLabelNode(text: dancerLabel)
          print("DANCE LABEL", dancerLabel)
          
          ////When text is changed it should get the currently selected Node and change it's text
          
          label.fontSize = 12.0
          label.color = UIColor.black
          

          //closestNode!.lineWidth = 20
          
             n.position = nearest
          label.position = CGPoint(x: 0, y: 16 )
          print(label.position, "LABEL Position")
          n.name = "draggable"
             
             self.addChild(n)
          //self.addChild(label)
          n.addChild(label)
          print(label.position, " 2 LABEL Position")
          
        }
          for node in touchedNodes.reversed() {
              if node.name == "draggable" {
                self.currentNode = (node as! SKSpriteNode)
              }
          }
      }
  
    
    
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first, let node = currentNode {
          let touchLocation = touch.location(in: self)
          node.position = touchLocation
      }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.currentNode = nil
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
}

