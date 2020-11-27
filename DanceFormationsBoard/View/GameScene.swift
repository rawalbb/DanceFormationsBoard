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
    
    

    override func didMove(to view: SKView) {
        // 2
        backgroundColor = SKColor.white
        gridWidth = view.bounds.width
        gridHeight = view.bounds.height
        drawGrid(width: gridWidth, height: gridHeight)
        
    }
    

    //MARK: Scene Grid
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
                
                
                //let n = DanceNode(imageNamed: "circle")
                let n = DanceNode(circleOfRadius: 10)
                n.fillColor = UIColor.blue
                    //let n = SKShapeNode(rectOf: CGSize(width: 10.0, height: 10.0), cornerRadius: 3.0)
                let label = SKLabelNode(text: "Bunz")
                var nearest = getNearestIntersection(x: location.x, y: location.y)
                
                label.fontSize = 12.0
                //label.color = UIColor.red
                label.fontColor = UIColor.red
                
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
                let color = "Black"
                let dancerId = n.nodeId
                self.myDelegate.dancerToAdd(xPosition: xPos, yPosition: yPos, id: dancerId, color: color, label: label.text ?? "")
                //self.saveDancers()
                
                
                
            }
            else{
                self.currentNode = self.nodes(at: location).first as? DanceNode
                self.myDelegate.enableTextField(enable: true)
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
                childToUpdate.fontSize = 20
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
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = currentNode {
            let touchLocation = touch.location(in: self)
            node.position = touchLocation
            
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = currentNode {
            let touchLocation = touch.location(in: self)
            node.position = getNearestIntersection(x: touchLocation.x, y: touchLocation.y)
            var id = node.nodeId
            
            self.myDelegate.dancerMoved(id: id, xPosition: Float(node.position.x), yPosition: Float(node.position.y))
            
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
            let n = DanceNode(circleOfRadius: 10)
            n.fillColor = UIColor.blue
            n.nodeId = dancer.id!
            let label = SKLabelNode(text: dancer.label)
            
            ////When text is changed it should get the currently selected Node and change it's text
            
            label.fontSize = 12.0
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
