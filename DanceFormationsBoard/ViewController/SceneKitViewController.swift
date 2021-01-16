//
//  3DGameViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/7/21.
//

import UIKit
import QuartzCore
import SceneKit

class SceneKitViewController: UIViewController {

    var sceneView: SCNView!
    var scene: SCNScene!
    var templateScene: SCNScene!
    var formationVM: FormationViewModel!
    var dancerVM: DancerViewModel!
    var arrayOfActions: [SCNAction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        
        
        // Do any additional setup after loading the view.
    }
       
            // create a new scene
    //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
    //
    //        // create and add a camera to the scene
    //        let cameraNode = SCNNode()
    //        cameraNode.camera = SCNCamera()
    //        scene.rootNode.addChildNode(cameraNode)
    //
    //        // place the camera
    //        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
    //
    //        // create and add a light to the scene
    //        let lightNode = SCNNode()
    //        lightNode.light = SCNLight()
    //        lightNode.light!.type = .omni
    //        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
    //        scene.rootNode.addChildNode(lightNode)
    //
    //        // create and add an ambient light to the scene
    //        let ambientLightNode = SCNNode()
    //        ambientLightNode.light = SCNLight()
    //        ambientLightNode.light!.type = .ambient
    //        ambientLightNode.light!.color = UIColor.darkGray
    //        scene.rootNode.addChildNode(ambientLightNode)
    //
    //        // retrieve the ship node
    //        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
    //
    //        // animate the 3d object
    //        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
    //
    //        // retrieve the SCNView
    //        let scnView = self.view as! SCNView
    //
    //        // set the scene to the view
    //        scnView.scene = scene
    //
    //        // allows the user to manipulate the camera
    //        scnView.allowsCameraControl = true
    //
    //        // show statistics such as fps and timing information
    //        scnView.showsStatistics = true
    //
    //        // configure the view
    //        scnView.backgroundColor = UIColor.black
    //
    //        // add a tap gesture recognizer
    //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    //        scnView.addGestureRecognizer(tapGesture)
      
    override func didMove(toParent parent: UIViewController?) {
        print("HI there")
        
        
    }
        
        func setupScene(){
            sceneView = self.view as! SCNView
            sceneView.allowsCameraControl = true
            scene = SCNScene(named: "art.scnassets/MainScene.scn")
            sceneView.scene = scene
            print("HI there setup")
            templateScene = SCNScene(named: "art.scnassets/Nodes.scn")
            
            let stage = scene.rootNode.childNode(withName: "stage", recursively: true)!
            //let boy = templateScene.rootNode.childNode(withName: "boy", recursively: true)!
            
            
            
            //let cubeNode = boy

            //cubeNode.position = stage.position
            //cubeNode.position = SCNVector3(0, 8, 0) // SceneKit/AR coordinates are in meters
            //sceneView.scene?.rootNode.addChildNode(cubeNode)
           // drawGrid()
            playFormations()
            
        }
    
    func convertToStageDimensions(originalX: Float, originalY: Float) -> SCNVector3{
        let stage = scene.rootNode.childNode(withName: "stage", recursively: true)!

        let width = (stage.boundingBox.max.x - stage.boundingBox.min.x) * 1.5
        let length = (stage.boundingBox.max.z - stage.boundingBox.min.z) * 1.5
        
        let point = PositionManager.percentageToPosition(x: originalX, y: originalY, viewW: CGFloat(width), viewH: CGFloat(length))


        let newVector = SCNVector3(point.x + CGFloat(stage.boundingBox.min.x * 1.5), 8, point.y + CGFloat(stage.boundingBox.min.z * 1.5))
        return newVector

    }
    
    
    func drawGrid(){
        let stage = scene.rootNode.childNode(withName: "stage", recursively: true)!
        
        let gridWidth = CGFloat(stage.boundingBox.max.x - stage.boundingBox.min.x) * 1.5 - 4
        let gridZ = CGFloat(stage.boundingBox.max.z - stage.boundingBox.min.z) * 1.5 - 4
        print("Grid Height, Grid Width ", gridZ, gridWidth)
        let box = SCNBox(width: 0.5, height: 0.5, length: gridZ, chamferRadius: 0)
        let box2 = SCNBox(width: gridWidth, height: 0.5, length: 0.5, chamferRadius: 0)
        
        
        var xCounter: CGFloat = CGFloat(stage.boundingBox.min.x) * 1.5 + 2
        print("XCounter Original", xCounter)
        var yCounter: CGFloat = CGFloat(stage.boundingBox.min.z) * 1.5 + 2
        let increment: CGFloat = gridWidth/10
        let yIncrement: CGFloat = gridZ/10
        var xNumLines: Int {
            return Int(gridWidth/increment)
        }
        var yNumLines: Int{
            return Int(gridZ/yIncrement)
        }
        for num in 1...xNumLines
        {
            
            let lineNode = SCNNode(geometry: box)
            lineNode.position = SCNVector3(xCounter, 6, CGFloat(stage.position.z))
            
            lineNode.name = "grid"
            sceneView.scene?.rootNode.addChildNode(lineNode)
            //addChild(lineNode)
            xCounter += increment
        }
        
        for num in 0...yNumLines
        {
            
            let lineNode = SCNNode(geometry: box2)
            lineNode.position = SCNVector3(CGFloat(stage.position.x), 6, yCounter)
            
            lineNode.name = "grid"
            sceneView.scene?.rootNode.addChildNode(lineNode)
            //addChild(lineNode)
            yCounter += yIncrement
        }
        
        
    }
        

        
        @objc
        func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            // retrieve the SCNView
    //        let scnView = self.view as! SCNView
    //
    //        // check what nodes are tapped
    //        let p = gestureRecognize.location(in: scnView)
    //        let hitResults = scnView.hitTest(p, options: [:])
    //        // check that we clicked on at least one object
    //        if hitResults.count > 0 {
    //            // retrieved the first clicked object
    //            let result = hitResults[0]
    //
    //            // get its material
    //            let material = result.node.geometry!.firstMaterial!
    //
    //            // highlight it
    //            SCNTransaction.begin()
    //            SCNTransaction.animationDuration = 0.5
    //
    //            // on completion - unhighlight
    //            SCNTransaction.completionBlock = {
    //                SCNTransaction.begin()
    //                SCNTransaction.animationDuration = 0.5
    //
    //                material.emission.contents = UIColor.black
    //
    //                SCNTransaction.commit()
    //            }
    //
    //            material.emission.contents = UIColor.red
    //
    //            SCNTransaction.commit()
    //        }
        }
        
        override var shouldAutorotate: Bool {
            return false
        }
        
        override var prefersStatusBarHidden: Bool {
            return true
        }
        
    //    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    //        if UIDevice.current.userInterfaceIdiom == .phone {
    //            return .allButUpsideDown
    //        } else {
    //            return .all
    //        }
    //    }


    
    func playThroughFormations(dancers: [Dancer], waitTime: Double, transitionTime: Double, formIndex: Int, totalForms: Int){

        let actionA = SCNAction.run {[weak self] _ in
            //THIS IS THE PROBLEM
            var currNodes: [SCNNode] = []
            self?.scene.rootNode.childNodes.filter({ $0.name == "boy" }).forEach({
                        currNodes.append($0 as! SCNNode) })
            

        for dancer in dancers{

            //IF there isn't a dancer at that position - not found, add that node


            if let toUpdateIndex = currNodes.firstIndex(where: { $0.accessibilityLabel == dancer.uniqueId }) {

                
                
                if let next = self?.convertToStageDimensions(originalX: dancer.xPos, originalY: dancer.yPos){
                let action = SCNAction.move(to: next, duration: 2.0)
                    currNodes[toUpdateIndex].runAction(action)
                }
        }
            else{
                    print("Not found")

            }
            //TODO - handle case when dancers are removed from one formation

        }


    }
            

        
        let wait = SCNAction.wait(duration: waitTime)
        arrayOfActions.append(wait)
        arrayOfActions.append(actionA)

        
}
    
    func playFormations(){
        self.arrayOfActions = []
        formationVM.setCurrentSelection(index: 0)
        if let curr = formationVM.getFormation(type: FormationType.current){
            let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
            self.formationSelected(dancers: dancers)
        }
        else{
            print("Error loading in play formations pressed ")
        }
        var waitT = 0.0

        for _ in 0..<formationVM.formationArray.count{

             // print("In For loop")
               // print(formationVM.currentFormation?.name)
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                    let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    
                   // print("Second Wait Time", time)
                    self.playThroughFormations(dancers: nextDancerForms, waitTime: 3.0, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                
                    waitT = 3.0

                    formationVM.setCurrentSelection(index: index + 1)
            
            

        }

    }   
        
            scene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
        }
        
    }
    
    
    func formationSelected(dancers: [Dancer]? = nil, index: IndexPath? = nil){
        
        //endActionsHelper()
        
        if let dancers = dancers{
        for dancer in dancers{

            templateScene = SCNScene(named: "art.scnassets/Nodes.scn")
            let stage = scene.rootNode.childNode(withName: "stage", recursively: true)!
            let cubeNode = templateScene.rootNode.childNode(withName: "boy", recursively: true)! as! SCNNode
            
            cubeNode.accessibilityLabel = dancer.uniqueId
            let width = (stage.boundingBox.max.x - stage.boundingBox.min.x) * 1.5
            let height = (stage.boundingBox.max.z - stage.boundingBox.min.z) * 1.5
            
            let point = PositionManager.percentageToPosition(x: dancer.xPos, y: dancer.yPos, viewW: CGFloat(width), viewH: CGFloat(height))
            
            print("POINT 3D, ", point.x, point.y)
            cubeNode.position = SCNVector3(point.x + CGFloat(stage.boundingBox.min.x * 1.5), 8, point.y + CGFloat(stage.boundingBox.min.z * 1.5)) // SceneKit/AR coordinates are in meters

            sceneView.scene?.rootNode.addChildNode(cubeNode)
            //closestNode!.lineWidth = 20
            
        }
        }

        
    }
    

}
