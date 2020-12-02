import SpriteKit
import UIKit
import CoreData


protocol GameSceneUpdatesDelegate {
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String)
    func gridFinished(finished: Bool)
    func dancerMoved(id: String, xPosition: Float, yPosition: Float)
    //func updateDancerLabel(id: String, label: String)
    func updateCellSelect()
    func updateCellDeselect()
    func enableTextField(enable: Bool)
    func updateNodeColor(color: UIColor)
    func removedDancer(id: String)
}

class GameScene: SKScene {
    
    var currentNode: DanceNode?
    var xArray: [CGFloat] = []
    var yArray: [CGFloat] = []
    var dancerLabel: String = ""
    var gridWidth: CGFloat = 0.0
    var gridHeight: CGFloat = 0.0
    var myDelegate : GameSceneUpdatesDelegate!
    var arrayOfActions: [SKAction] = []
    var backgroundMuisc: SKAudioNode!
    var selectedNodeColor: UIColor!
    //let font = UIFont(name: "GillSans-SemiBold", size: .14)!
    
    

    override func didMove(to view: SKView) {
        // 2
        backgroundColor = #colorLiteral(red: 0.1843137294, green: 0.2039215714, blue: 0.2156862766, alpha: 1)
        
        gridWidth = view.bounds.width
        gridHeight = view.bounds.height
        drawGrid(width: gridWidth, height: gridHeight)
        
    }
    

    //MARK: Scene Grid
    func drawGrid(width: CGFloat, height: CGFloat){

        var xCounter: CGFloat = 0.0
        var yCounter: CGFloat = 0.0
        let yIncrement: CGFloat = height/10
        let xIncrement: CGFloat = yIncrement
        let xNumLines: Int = Int(width/xIncrement)
        var xLineNodes: [SKShapeNode] = []
        var yLineNodes: [SKShapeNode] = []
        for _ in 1...xNumLines
        {
            let path = UIBezierPath()
            let start = CGPoint(x: xCounter, y: 0)
            let end = CGPoint(x: xCounter, y:height)
            path.move(to: start)
            path.addLine(to: end)
            xArray.append(xCounter)
            
            let shapeNode = SKShapeNode(path: path.cgPath)
            shapeNode.strokeColor = #colorLiteral(red: 0.5587006807, green: 0.6035502553, blue: 0.6746274233, alpha: 1)
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
            shapeNode.strokeColor = #colorLiteral(red: 0.5587006807, green: 0.6035502553, blue: 0.6746274233, alpha: 1)
            shapeNode.lineWidth = 2
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
                
                
                //let n = DanceNode(imageNamed: "circle")
                let n = DanceNode(circleOfRadius: 11)
                n.fillColor = selectedNodeColor
                n.strokeColor = selectedNodeColor
                    //let n = SKShapeNode(rectOf: CGSize(width: 10.0, height: 10.0), cornerRadius: 3.0)
                let label = SKLabelNode(text: "")
                var nearest = getNearestIntersection(x: location.x, y: location.y)
                
                label.fontSize = 14.0
                //label.color = UIColor.red
                label.fontColor = UIColor.red
                label.fontName = "GillSans-SemiBold"
                
                n.position = nearest
                label.name = "labelName"
                label.position = CGPoint(x: 20, y: 20 )
                //label.color = UIColor.blue
                n.name = "draggable"
                n.addChild(label)
                self.addChild(n)
                
                
            
                let xPos = Float(n.position.x)
                let yPos = Float(n.position.y)
                n.nodeId = UUID().uuidString
                let color = selectedNodeColor.toHexString()
                print("COLOR ", color)
                let dancerId = n.nodeId
                self.myDelegate.dancerToAdd(xPosition: xPos, yPosition: yPos, id: dancerId, color: color, label: label.text ?? "")
                //self.saveDancers()
                
                
                
            }
            else{
                self.currentNode = self.nodes(at: location).first as? DanceNode
                self.myDelegate.enableTextField(enable: true)
                self.myDelegate.updateNodeColor(color: currentNode?.fillColor ?? UIColor.white)
            }
//            for node in touchedNodes.reversed() {
//                if node.name == "draggable" {
//                    self.currentNode = (node as! DanceNode)
//                }
//            }
        }
        
        
        
    }
    
     func updateDancerLabel(label: String){
        var childLabelNodes: [SKLabelNode] = []
        if let node = currentNode{
            node.enumerateChildNodes(withName: "labelName") { (node, stop) in
                childLabelNodes.append(node as! SKLabelNode)
                print(childLabelNodes.count, "Child Count")
            }
            if childLabelNodes.count != 0{
            var a = childLabelNodes[0] as? SKLabelNode
            if let childToUpdate = a{
                print(childToUpdate.text)
                childToUpdate.fontSize = 14
                childToUpdate.fontName = "GillSans-SemiBold"
                childToUpdate.text = label
            }
        }
            else{
                print("No childnodes found")
            }
        }
        else{
            print("No current node")
        }
        
    }
    
    
    func updateDancerColor(color: String){
       
       if let node = currentNode{
        
        node.fillColor = UIColor(hex: color)
          
           }

           else{
               print("Cannot Update Node Color")
           }
       }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = currentNode {
            let touchLocation = touch.location(in: self)
            node.position = touchLocation
            
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = currentNode {
            let touchLocation = touch.location(in: self)
            print("In TOUCHES Ended")
            print("GameScene Size", view?.bounds.width, view?.bounds.height)
            print(self.children.count)
            if node.position.x < 0.0 || node.position.x >= gridWidth{
                print("X is offscreen")
                //node.removeFromParent()
                self.myDelegate.removedDancer(id: node.nodeId)
                //currentNode = nil
                //print("If", self.children.count)
                
            }
            else if node.position.y < 0.0 || node.position.y >= gridHeight{
                print("Y is offscreen")
                //node.removeFromParent()
                self.myDelegate.removedDancer(id: node.nodeId)
                //currentNode = nil
               // print("Else If", self.children.count)
            }
            else{
            node.position = getNearestIntersection(x: touchLocation.x, y: touchLocation.y)
            var id = node.nodeId
            self.myDelegate.dancerMoved(id: id, xPosition: Float(node.position.x), yPosition: Float(node.position.y))
                print("Else", self.children.count)
            }
        }
        //currentNode = nil
        //self.myDelegate.enableTextField(enable: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
        self.myDelegate.enableTextField(enable: false)
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
        //print("DAncer ", dancers.count)
        for dancer in dancers{
            let n = DanceNode(circleOfRadius: 11)
            print("In Formation Selected Color", dancer.color)
            n.fillColor = UIColor(hex: dancer.color)
            n.strokeColor = UIColor(hex: dancer.color)
            n.nodeId = dancer.id!
            let label = SKLabelNode(text: dancer.label)
            
            ////When text is changed it should get the currently selected Node and change it's text
            
            label.fontSize = 14.0
            label.fontName = "GillSans-SemiBold"
            label.fontColor = UIColor.red
            
            
            
            //closestNode!.lineWidth = 20
            
            n.position = CGPoint(x: CGFloat(dancer.xPos), y: CGFloat(dancer.yPos))
//            print("X ", n.position.x)
//            print("Y ", n.position.y)
            label.name = "labelName"
            label.position = CGPoint(x: 0, y: 16 )
            
            n.name = "draggable"
            n.addChild(label)
            self.addChild(n)
            //self.addChild(label)
            
            
        }
        
        //playThroughFormations()
        
    }
    
    func playSong(){
        
        if let musicURL = Bundle.main.url(forResource: "Bulleya", withExtension: "mp3") {
            backgroundMuisc = SKAudioNode(url: musicURL)
        }
        
        backgroundMuisc.name = "music"
        self.addChild(backgroundMuisc)
        
        let actionB = SKAction.run {
            self.backgroundMuisc.run(SKAction.play())
        }
        
        arrayOfActions.append(actionB)

    }
    
    func endSong(){

        
        let actionC = SKAction.run {
            self.backgroundMuisc.run(SKAction.stop())
        }
        
        arrayOfActions.append(actionC)

    }
    
    func playThroughFormations(dancers: [Dancer], waitTime: Double, transitionTime: Double, formIndex: Int, totalForms: Int){
        
        //print("Curr Index", self.formationVM.currentIndex)
   
        let actionA = SKAction.run { [unowned self] in
            var currNodes: [DanceNode] = []
                self.enumerateChildNodes(withName: "draggable") { (node, stop) in
                currNodes.append(node as! DanceNode)
            }
        
        for dancer in dancers{

            if let toUpdateIndex = currNodes.firstIndex(where: { $0.nodeId == dancer.id }) {
                
                let next = CGPoint(x: CGFloat(dancer.xPos), y: CGFloat(dancer.yPos))

                let action = SKAction.move(to: next , duration: 2.0)

                

                currNodes[toUpdateIndex].run(action)
                
        }
            else{
                print("Node not found")
            }

        }
                    //self.formationVM.currentIndex += 1
       
    }
            

        
            let wait = SKAction.wait(forDuration: waitTime)
        arrayOfActions.append(wait)
        arrayOfActions.append(actionA)
        
        print("Form Index ", formIndex)
        print("Total ", totalForms)
        if formIndex + 2 == totalForms{
            print("Form Indexxxxx ", formIndex)
            print("Total;;; ", totalForms)
            arrayOfActions.append(SKAction.wait(forDuration: 2.0))
            self.endSong()
        }
        
}
    
}


class DanceNode: SKShapeNode{
    
    var nodeId: String = ""
}

