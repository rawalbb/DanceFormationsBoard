import SpriteKit
import UIKit
import CoreData


protocol StageSceneUpdatesDelegate {
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String)
    func dancerMoved(id: String, xPosition: Float, yPosition: Float)
    //func updateDancerLabel(id: String, label: String)
    func enableTextField(enable: Bool, id: String)
    func updateNodeColor(color: UIColor)
    func removedDancer(id: String)
    func updateFormationSelected(index: IndexPath)
    func enableTouches()
}

class StageScene: SKScene {
    
    var currentNode: DanceNode? = nil {
        didSet {
            currentNode?.lineWidth = 4
            currentNode?.strokeColor = UIColor(named: "color-icons") ?? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        }
    }
    
    
    var xArray: [CGFloat] = []
    var yArray: [CGFloat] = []
    var dancerLabel: String = ""
    var gridWidth: CGFloat = 0.0
    var gridHeight: CGFloat = 0.0
    var myDelegate : StageSceneUpdatesDelegate!
    var arrayOfActions: [SKAction] = []
    var backgroundMuisc: SKAudioNode!
    var selectedColor: UIColor!
    var showLabel: Bool = false
    var playMusic: Bool = false
    let highlightedNode = SKShapeNode(circleOfRadius: 6)
    var musicEnabled: Bool = false
    //let font = UIFont(name: "GillSans-SemiBold", size: .14)!
    
    
    override func sceneDidLoad() {

    }
    override func didMove(to view: SKView) {

        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        gridWidth = view.bounds.width
        gridHeight = view.bounds.height
        var gridArray: [SKNode] = []
        
        ///Makes sure there is no grid
        self.enumerateChildNodes(withName: "grid") { (gridNode, stop) in
            gridArray.append(gridNode )
        }
        
        guard gridArray.count == 0 else{
            print("Error in Initializing Grid")
            return
        }
        drawGrid()
    }
    
    //Only want to

    //MARK: Scene Grid
    func drawGrid(){
        ///
        var xCounter: CGFloat = 0.0
        var yCounter: CGFloat = 0.0
        let xNumLines: Int = 20
        let yNumLines: Int = 10
        var xIncrement: CGFloat{
            return gridWidth/20
        }
        var yIncrement: CGFloat{
            return gridHeight/10
        }
       //Adds vertical lines
        for num in 0...xNumLines
        {
            let path = UIBezierPath()
            let start = CGPoint(x: xCounter, y: 0.0)
            let end = CGPoint(x: xCounter, y:gridHeight)
            path.move(to: start)
            path.addLine(to: end)

            let lineNode = SKShapeNode(path: path.cgPath)
            lineNode.strokeColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
            lineNode.lineWidth = 0.5
            lineNode.name = "grid"
            
            //As long as line is
            if num != 0 && num != 20 {
                xArray.append(xCounter)
            }

                //xArray.append(xCounter)

            addChild(lineNode)
            xCounter += xIncrement
        }
        
        
        
        
        let midXPath = UIBezierPath()
        let midXStart = CGPoint(x: 0, y: gridHeight/2)
        let midXEnd = CGPoint(x: gridWidth, y: gridHeight/2)
        let midYPath = UIBezierPath()
        let midYStart = CGPoint(x: gridWidth/2, y: 0)
        let midYEnd = CGPoint(x: gridWidth/2, y: gridHeight)
        midXPath.move(to: midXStart)
        midXPath.addLine(to: midXEnd)
        midYPath.move(to: midYStart)
        midYPath.addLine(to: midYEnd)
        let midXLineNode = SKShapeNode(path: midXPath.cgPath)
        midXLineNode.strokeColor =  #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        midXLineNode.lineWidth = 2.5
        let midYLineNode = SKShapeNode(path: midYPath.cgPath)
        midYLineNode.strokeColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        midYLineNode.lineWidth = 2.5
        addChild(midXLineNode)
        addChild(midYLineNode)
        
        
        //let midXNode = SKShapeNode(path: midXPath.cgPath)
        //let midYNode = SKShapeNode(path: midYPath.cgPath)
        //Adds horizontal lines
        for num in 0...yNumLines
        {
            let path = UIBezierPath()
            let start = CGPoint(x: 0, y: yCounter)
            let end = CGPoint(x: gridWidth, y:yCounter)
            path.move(to: start)
            path.addLine(to: end)
            
            let lineNode = SKShapeNode(path: path.cgPath)
            lineNode.name = "grid"
            
            if num != 0 && num != yNumLines{
                lineNode.strokeColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
                lineNode.lineWidth = 0.5
                yArray.append(yCounter)
            }
            if num == 0{
                lineNode.strokeColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
                lineNode.lineWidth = 4
            }
 
            
            addChild(lineNode)
            yCounter += yIncrement
        }
        
        var xLabelCounter = Double(xIncrement)
        
        //Button tapped once add grid lines starting from end, twice, add grid lines starting from one off of end, add grid lines to each
        for num in 0...yNumLines
        {
            let path = UIBezierPath()
            let start = CGPoint(x: xLabelCounter, y: 0.0)
            let end = CGPoint(x: xLabelCounter, y: Double(yIncrement/3))
            path.move(to: start)
            path.addLine(to: end)
            
            let lineNode = SKShapeNode(path: path.cgPath)

                lineNode.strokeColor = UIColor(named: "color-icons") ?? #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)
            lineNode.lineWidth = 2.5
   
            
            lineNode.name = "markers"
            addChild(lineNode)
            xLabelCounter += Double(xIncrement * 2)
        }
//        var xLabelCounter = gridWidth/2
//        for num in 0...10{
//
//            let winner = SKLabelNode(fontNamed: "GillSans-SemiBold")
//            winner.text = "\(num)"
//            winner.fontSize = 16
//            winner.fontColor = SKColor.white
//            winner.position = CGPoint(x: xLabelCounter, y: yIncrement/4)
//            addChild(winner)
//
//            xLabelCounter += xIncrement
//        }
        
//        var xLabelCounterNext = gridWidth/2
//        for num in 0...10{
//
//            let winner = SKLabelNode(fontNamed: "GillSans-SemiBold")
//            winner.text = "\(num)"
//            winner.fontSize = 16
//            winner.fontColor = SKColor.white
//            winner.position = CGPoint(x: xLabelCounterNext, y: yIncrement/4)
//            addChild(winner)
//
//            xLabelCounter -= xIncrement
//        }
        
           
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var spotTaken = false
        if let prevNode = currentNode{
            prevNode.lineWidth = 0
        }
        currentNode = nil
        if let touch = touches.first {
            let location = touch.location(in: self)
            let gridLocation = getNearestIntersection(x: location.x, y: location.y)
            
            let touchedNodes = self.nodes(at: gridLocation)
            //if touched nodes have name dancer don't add
            
            if touchedNodes.contains(where: { (node) -> Bool in
                node.name == "dancers"
            }){
                print("Already dancer here")
                spotTaken = true
            }
            //printing curr array - I
            if !spotTaken {
                
                
                //let n = DanceNode(imageNamed: "circle")
                let n = DanceNode(circleOfRadius: 11)
                n.fillColor = selectedColor
                n.strokeColor = selectedColor
 
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
                currentNode = n
                
                

                let point = PositionManager.positionToPercentage(x: n.position.x, y: n.position.y, viewW: self.view?.bounds.width, viewH: self.view?.bounds.height)

                let xPos = Float(point.x)
                let yPos = Float(point.y)
                print("PRINTING POINTS", xPos, yPos)
                n.nodeId = UUID().uuidString
                let color = selectedColor.toHexString()
                let dancerId = n.nodeId
                self.myDelegate.dancerToAdd(xPosition: xPos, yPosition: yPos, id: dancerId, color: color, label: label.text ?? "")
                //self.saveDancers()
    
            }
            else{
                highlightedNode.position = touchedNodes[0].position
                if let nodeTouched = touchedNodes[0] as? SKSpriteNode{
                    highlightedNode.fillColor = nodeTouched.color
                    highlightedNode.strokeColor = nodeTouched.color
                }
                else{
                    highlightedNode.fillColor = selectedColor
                    highlightedNode.strokeColor = selectedColor
                }
                highlightedNode.lineWidth = 1
                
                highlightedNode.alpha = 0.5
                highlightedNode.glowWidth = 4
                highlightedNode.zPosition = 0
                highlightedNode.name = "highlight"
                self.addChild(highlightedNode)
                if let prevNode = currentNode{
                    prevNode.lineWidth = 0
                }
                self.currentNode = self.nodes(at: location).first as? DanceNode
                self.myDelegate.enableTextField(enable: true, id: currentNode?.nodeId ?? "")
                self.myDelegate.updateNodeColor(color: currentNode?.fillColor ?? selectedColor)
            }

        }
        
        
        
    }
    
     func updateDancerLabel(label: String){
        var childLabelNodes: [SKLabelNode] = []
        if let node = currentNode{
            node.enumerateChildNodes(withName: "labelName") { (node, stop) in
                childLabelNodes.append(node as! SKLabelNode)
            }
            if childLabelNodes.count != 0{
                let a = childLabelNodes[0] as! SKLabelNode
            let childToUpdate = a
                childToUpdate.fontSize = 14
                childToUpdate.fontName = "GillSans-SemiBold"
                childToUpdate.text = label
            
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
        node.strokeColor = UIColor(hex: color)
          
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
                
                
                
                let point = PositionManager.positionToPercentage(x: node.position.x, y: node.position.y, viewW: self.view?.frame.width, viewH: self.view?.frame.height)

            self.myDelegate.dancerMoved(id: id, xPosition: Float(point.x), yPosition: Float(point.y))
            }
        }
        //currentNode = nil
        //self.myDelegate.enableTextField(enable: false)

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let prevNode = currentNode{
            prevNode.lineWidth = 0
        }
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
    
    
    func formationSelected(dancers: [Dancer]? = nil, index: IndexPath? = nil){
        
        endActionsHelper()
        if let prevNode = currentNode{
            prevNode.lineWidth = 0
        }
        currentNode = nil
        self.myDelegate.enableTextField(enable: false, id: "")
        
        if let dancers = dancers{
        for dancer in dancers{
            let n = DanceNode(circleOfRadius: 11)
            n.fillColor = UIColor(hex: dancer.color)
            n.strokeColor = UIColor(hex: dancer.color)
            n.nodeId = dancer.id
            let label = SKLabelNode(text: dancer.label)
            
            ////When text is changed it should get the currently selected Node and change it's text
            
            label.fontSize = 14.0
            label.fontName = "GillSans-SemiBold"
            label.fontColor = UIColor.red
            
            
            
            //closestNode!.lineWidth = 20
            
            let point = PositionManager.percentageToPosition(x: dancer.xPos, y: dancer.yPos, viewW: self.view?.bounds.width, viewH: self.view?.bounds.height)
            print("Formation Selected positions ", point.x, point.y, self.view?.bounds.width, self.view?.bounds.height)
            let point2 = getNearestIntersection(x: point.x, y: point.y)
            
            n.position = CGPoint(x: CGFloat(point2.x), y: CGFloat(point2.y))
            n.zPosition = 1
            label.name = "labelName"
            label.position = CGPoint(x: 0, y: 14 )
            
            n.name = "dancers"
            n.addChild(label)
            
            
            self.addChild(n)
            
            nodeLabelHelper()
            //self.addChild(label)
            
            
        }
        }
        //playThroughFormations()
        if let path = index{
            self.myDelegate.updateFormationSelected(index: path)
        }
        
    }
    
    func playSong(musicLink: URL? = nil){

        self.enumerateChildNodes(withName: "music") { (musicNode, stop) in
            musicNode.removeAllActions()
            musicNode.removeFromParent()
        }
        if let musicURL = musicLink{
            backgroundMuisc = SKAudioNode(url: musicURL)
            
            backgroundMuisc.name = "music"
            self.addChild(backgroundMuisc)
            
            let actionB = SKAction.run {
                self.backgroundMuisc.run(SKAction.play())
            }
            
            arrayOfActions.append(actionB)
        }

        else{
            print("Error in selecting music")
        }

    }
    
    func endSong(){
        //var musicNodeArray : [SKNode] = []

        if backgroundMuisc != nil{
        let actionC = SKAction.run {
            self.backgroundMuisc.run(SKAction.stop())
        }
        
        arrayOfActions.append(actionC)
        }
        else{
            print("Error in stopping music")
        }
    }
    func endActionsHelper(removeDancers: Bool = true){
        
        self.enumerateChildNodes(withName: "music") { (musicNode, stop) in
            musicNode.removeAllActions()
            musicNode.removeFromParent()
        }
        self.removeAllActions()
        

        self.enumerateChildNodes(withName: "dancers") { (danceNode, stop) in
           
                danceNode.removeFromParent()
            
            danceNode.removeAllActions()
 
    }
    }
    
    func playThroughFormations(dancers: [Dancer], waitTime: Double, transitionTime: Double, formIndex: Int, totalForms: Int){
        
        let wait = SKAction.wait(forDuration: waitTime)
    arrayOfActions.append(wait)
   
        let actionA = SKAction.run { [unowned self] in
            //THIS IS THE PROBLEM
            var currNodes: [DanceNode] = []
                self.enumerateChildNodes(withName: "dancers") { (node, stop) in
                currNodes.append(node as! DanceNode)
            }
        
        for dancer in dancers{
            
            //IF there isn't a dancer at that position - not found, add that node
            

            if let toUpdateIndex = currNodes.firstIndex(where: { $0.nodeId == dancer.id }) {
                let point = PositionManager.percentageToPosition(x: dancer.xPos, y: dancer.yPos, viewW: self.view?.bounds.width, viewH: self.view?.bounds.height)
                let next = CGPoint(x: point.x, y: point.y)

                let action = SKAction.move(to: next , duration: 2.0)

                currNodes[toUpdateIndex].run(action)
                
        }
            else{

                let n = DanceNode(circleOfRadius: 11)
                n.fillColor = UIColor(hex: dancer.color)
                n.strokeColor = UIColor(hex: dancer.color)
                n.nodeId = dancer.id
                let label = SKLabelNode(text: dancer.label)
                
                ////When text is changed it should get the currently selected Node and change it's text
                
                label.fontSize = 14.0
                label.fontName = "GillSans-SemiBold"
                label.fontColor = UIColor.red
                
                
                
                //closestNode!.lineWidth = 20
                
                //n.position = CGPoint(x: CGFloat(dancer.xPos), y: CGFloat(dancer.yPos))
                let point = PositionManager.percentageToPosition(x: dancer.xPos, y: dancer.yPos, viewW: self.view?.bounds.width, viewH: self.view?.bounds.height)
                let nextX = getNearestStartingPoint(endPointX: point.x)
                n.position = CGPoint(x: nextX, y: point.y)
                n.zPosition = 1
                label.name = "labelName"
                label.position = CGPoint(x: 0, y: 14 )
                
                n.name = "dancers"
                n.addChild(label)
                
                
                self.addChild(n)
                currNodes.append(n)
                

                
                let next = CGPoint(x: point.x, y: point.y)
                
                
                let action = SKAction.move(to: next , duration: 2.0)
                n.run(action)
            }
            //TODO - handle case when dancers are removed from one formation

        }
            
            for nodes in currNodes{
                
                if dancers.firstIndex(where: { $0.id == nodes.nodeId }) != nil {

            }
                else{
  
                    nodes.removeFromParent()
                }
                
            }
                    //self.formationVM.currentIndex += 1
       
    }
            

        
        
        arrayOfActions.append(actionA)
        let enableTouchAction = SKAction.run {
            self.myDelegate.enableTouches()
        }
        if formIndex + 2 == totalForms && musicEnabled == true{
            arrayOfActions.append(SKAction.wait(forDuration: 2.0))
            self.endSong()
            arrayOfActions.append(enableTouchAction)
        }
        else if formIndex + 2 == totalForms && musicEnabled == false{
            arrayOfActions.append(SKAction.wait(forDuration: 2.0))
            //self.endSong()
            arrayOfActions.append(enableTouchAction)
        }
        
}
    
    
    //Create function where if switch is on - then add child labels, if not remove chid labels
    
    func nodeLabelHelper(){
        
        if showLabel{
        self.enumerateChildNodes(withName: "dancers") { (dancerNode, stop) in
            
            dancerNode.enumerateChildNodes(withName: "labelName") { (node, stop) in

                node.isHidden = true
            }

        }
            
        }
        else{
         
            self.enumerateChildNodes(withName: "dancers") { (dancerNode, stop) in
                
                dancerNode.enumerateChildNodes(withName: "labelName") { (node, stop) in

                    node.isHidden = false
                }

            }
            
        }
        
        
    }
    
    func getNearestStartingPoint(endPointX: CGFloat) -> CGFloat{
        let nearestStartArray = [0.0, gridWidth]
        
        var nearestX: CGFloat {
           
            nearestStartArray.reduce(34.3 as CGFloat){
                if abs($1 - endPointX) < abs($0 - endPointX){
                    return CGFloat($1)
                    
                }
                else{
                    return CGFloat($0)
                }
            }
        }
        return nearestX
    }
    
}


class DanceNode: SKShapeNode{
    
    var nodeId: String = ""
}

