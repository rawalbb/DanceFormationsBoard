import SpriteKit
import UIKit
import CoreData


protocol GameSceneUpdatesDelegate {
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String)
    func dancerMoved(id: String, xPosition: Float, yPosition: Float)
    //func updateDancerLabel(id: String, label: String)
    func updateCellSelect()
    func updateCellDeselect()
    func enableTextField(enable: Bool, id: String)
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
    var initial: [Dancer]!
    var showLabel: Bool = false
    let highlightedNode = SKShapeNode(circleOfRadius: 6)
    var musicUrl: URL? = URL(string: "")
    //let font = UIFont(name: "GillSans-SemiBold", size: .14)!
    
    
    override func sceneDidLoad() {

    }
    override func didMove(to view: SKView) {
        // 2
        print("W H", view.bounds.width, view.bounds.height)
        backgroundColor = #colorLiteral(red: 0.1843137294, green: 0.2039215714, blue: 0.2156862766, alpha: 1)
        gridWidth = view.bounds.width
        gridHeight = view.bounds.height
        var gridArray: [SKNode] = []
        self.enumerateChildNodes(withName: "grid") { (gridNode, stop) in
            //dancerNode.removeFromParent()
            gridArray.append(gridNode as! SKNode)
        }
        
        guard gridArray.count == 0 else{
            print("Error in Initializing Grid")
            return
        }
        drawGrid()
        formationSelected(dancers: initial)
        
    }
    
    //Only want to

    //MARK: Scene Grid
    func drawGrid(){
        
        var xCounter: CGFloat = 0.0
        var yCounter: CGFloat = 0.0
        let increment: CGFloat = gridHeight/10
        var xNumLines: Int {
            return Int(gridWidth/increment)
        }
        var yNumLines: Int{
            return Int(gridHeight/increment)
        }
        for num in 0...xNumLines
        {
            let path = UIBezierPath()
            let start = CGPoint(x: xCounter, y: 0)
            let end = CGPoint(x: xCounter, y:gridHeight)
            path.move(to: start)
            path.addLine(to: end)
            
            
            let lineNode = SKShapeNode(path: path.cgPath)
            
            if num != 0{
                xArray.append(xCounter)
            }
            
                lineNode.strokeColor = #colorLiteral(red: 0.5587006807, green: 0.6035502553, blue: 0.6746274233, alpha: 1)
                lineNode.lineWidth = 2
                xArray.append(xCounter)
            
            lineNode.name = "grid"
            addChild(lineNode)
            xCounter += increment
        }
        
        for num in 0...yNumLines
        {
            let path = UIBezierPath()
            let start = CGPoint(x: 0, y: yCounter)
            let end = CGPoint(x: gridWidth, y:yCounter)
            path.move(to: start)
            path.addLine(to: end)
            
            let lineNode = SKShapeNode(path: path.cgPath)
            if num == 0 || num == yNumLines{
                lineNode.strokeColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
                lineNode.lineWidth = 3
            }
            else{
                lineNode.strokeColor = #colorLiteral(red: 0.5587006807, green: 0.6035502553, blue: 0.6746274233, alpha: 1)
                lineNode.lineWidth = 2
                yArray.append(yCounter)
            }
           
            lineNode.name = "grid"
            addChild(lineNode)
            yCounter += increment
        }
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let touchedNodes = self.nodes(at: location)
            if (touchedNodes.count == 0){
                
                
                //let n = DanceNode(imageNamed: "circle")
                let n = DanceNode(circleOfRadius: 10.5)
                n.fillColor = selectedNodeColor
                n.strokeColor = selectedNodeColor
                    //let n = SKShapeNode(rectOf: CGSize(width: 10.0, height: 10.0), cornerRadius: 3.0)
                let label = SKLabelNode(text: "")
                let nearest = getNearestIntersection(x: location.x, y: location.y)
                
                label.fontSize = 14.0
                //label.color = UIColor.red
                label.fontColor = UIColor.red
                label.fontName = "GillSans-SemiBold"
                
                n.position = nearest
                n.zPosition = 1
                label.name = "labelName"
                label.position = CGPoint(x: 20, y: 20 )
                //label.color = UIColor.blue
                n.name = "dancers"
                n.addChild(label)
                self.addChild(n)
                
                
            
                let xPos = Float(n.position.x)
                let yPos = Float(n.position.y)
                n.nodeId = UUID().uuidString
                let color = selectedNodeColor.toHexString()
                let dancerId = n.nodeId
                self.myDelegate.dancerToAdd(xPosition: xPos, yPosition: yPos, id: dancerId, color: color, label: label.text ?? "")
                //self.saveDancers()
    
            }
            else{
               
                highlightedNode.position = touchedNodes[0].position
                highlightedNode.fillColor = UIColor.black
                highlightedNode.lineWidth = 1
                highlightedNode.strokeColor = UIColor.black
                highlightedNode.glowWidth = 4
                highlightedNode.zPosition = 0
                highlightedNode.name = "highlight"
                self.addChild(highlightedNode)
                
                self.currentNode = self.nodes(at: location).first as? DanceNode
                self.myDelegate.enableTextField(enable: true, id: currentNode?.nodeId ?? "")
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
            }
            if childLabelNodes.count != 0{
                let a = childLabelNodes[0] as? SKLabelNode
            if let childToUpdate = a{
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
        self.enumerateChildNodes(withName: "highlight") { (dancerNode, stop) in
            dancerNode.removeFromParent()
            //**Keeps Grid**
        }
        if let touch = touches.first, let node = currentNode {
            let touchLocation = touch.location(in: self)

            if node.position.x < 0.0 || node.position.x >= gridWidth{
                node.removeFromParent()
                self.myDelegate.removedDancer(id: node.nodeId)
                
            }
            else if node.position.y < 0.0 || node.position.y >= gridHeight{
                node.removeFromParent()
                self.myDelegate.removedDancer(id: node.nodeId)
                //currentNode = nil
               // print("Else If", self.children.count)
            }
            else{
            node.position = getNearestIntersection(x: touchLocation.x, y: touchLocation.y)
                let id = node.nodeId
            self.myDelegate.dancerMoved(id: id, xPosition: Float(node.position.x), yPosition: Float(node.position.y))
            }
        }
        //currentNode = nil
        //self.myDelegate.enableTextField(enable: false)

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
        self.myDelegate.enableTextField(enable: false, id: "")
    }
    
    
    
    
    
    func getNearestIntersection(x: CGFloat, y: CGFloat) -> CGPoint{
        var nearestX: CGFloat {
           
            xArray.reduce(34.3 as CGFloat){
                if abs($1 - x) < abs($0 - x){
                    return CGFloat($1)
                    
                }
                else{
                    return CGFloat($0)
                }
            }
        }
        
        
        var nearestY: CGFloat {
            yArray.reduce(34.3 as CGFloat){
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
    
    
    func formationSelected(dancers: [Dancer]?){
        
        self.enumerateChildNodes(withName: "dancers") { (dancerNode, stop) in
            dancerNode.removeFromParent()
            //**Keeps Grid**
        }

        //self.removeAllChildren()
        //print("DAncer ", dancers.count)
        if let dancers = dancers{
        for dancer in dancers{
            let n = DanceNode(circleOfRadius: 10)
            n.fillColor = UIColor(hex: dancer.color)
            n.strokeColor = UIColor(hex: dancer.color)
            n.nodeId = dancer.id
            let label = SKLabelNode(text: dancer.label)
            
            ////When text is changed it should get the currently selected Node and change it's text
            
            label.fontSize = 14.0
            label.fontName = "GillSans-SemiBold"
            label.fontColor = UIColor.red
            
            
            
            //closestNode!.lineWidth = 20
            
            n.position = CGPoint(x: CGFloat(dancer.xPos), y: CGFloat(dancer.yPos))
            n.zPosition = 1
            label.name = "labelName"
            label.position = CGPoint(x: 0, y: 16 )
            
            n.name = "dancers"
            n.addChild(label)
            
            
            self.addChild(n)
            
            nodeLabelHelper()
            //self.addChild(label)
            
            
        }
        }
        //playThroughFormations()
        
    }
    
    func playSong(){
        
        if let musicURL = musicUrl{
            backgroundMuisc = SKAudioNode(url: musicURL)
            print("selected")
        }
        else if let musicURL = Bundle.main.url(forResource: "Bulleya", withExtension: "mp3"){
            backgroundMuisc = SKAudioNode(url: musicURL)
            print("bulleya")
        }
        else{
            print("Error")
        }
        
        backgroundMuisc.name = "music"
        self.addChild(backgroundMuisc)
        
        let actionB = SKAction.run {
            self.backgroundMuisc.run(SKAction.play())
        }
        
        arrayOfActions.append(actionB)

    }
    
    func endSong(){

        if backgroundMuisc != nil{
        let actionC = SKAction.run {
            self.backgroundMuisc.run(SKAction.stop())
        }
        
        arrayOfActions.append(actionC)
        }
    }
    
    func playThroughFormations(dancers: [Dancer], waitTime: Double, transitionTime: Double, formIndex: Int, totalForms: Int){
   
        let actionA = SKAction.run { [unowned self] in
            var currNodes: [DanceNode] = []
                self.enumerateChildNodes(withName: "dancers") { (node, stop) in
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
        
        if formIndex + 2 == totalForms{
            arrayOfActions.append(SKAction.wait(forDuration: 2.0))
            self.endSong()
        }
        
}
    
    
    //Create function where if switch is on - then add child labels, if not remove chid labels
    
    func nodeLabelHelper(){
        
        if showLabel{
        self.enumerateChildNodes(withName: "dancers") { (dancerNode, stop) in
            
            dancerNode.enumerateChildNodes(withName: "labelName") { (node, stop) in
                print("A")
                node.isHidden = true
            }

        }
            
        }
        else{
         
            self.enumerateChildNodes(withName: "dancers") { (dancerNode, stop) in
                
                dancerNode.enumerateChildNodes(withName: "labelName") { (node, stop) in
                    
                    print("B")
                    node.isHidden = false
                }

            }
            
        }
        
        
    }
    
}


class DanceNode: SKShapeNode{
    
    var nodeId: String = ""
}

