//
//  3DGameViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/7/21.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import AVFoundation

class SceneKitViewController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var templateScene: SCNScene!
    var formationVM: FormationViewModel!
    var dancerVM: DancerViewModel!
    var arrayOfActions: [SCNAction] = []
    var spriteScene: OverlayScene!
    var prevNode: SKNode?
    var nextNode: SKNode?
    var playNode: SKNode?
    var musicNode: SKNode?
    var backgroundMusic: SCNAudioSource?
    var musicEnabled: Bool = false
    var boardVM = BoardViewModel.shared
    var stageWidth: Float = 0.0
    var stageHeight: Float = 0.0
    var stageWidthMin: Float = 0.0
    var stageHeightMin: Float = 0.0
    var stopActionButton: UIBarButtonItem?
    
    var stage: SCNNode? = nil {
        didSet{
            guard let stage = stage else { return }
            stageWidth = (stage.boundingBox.max.x - stage.boundingBox.min.x) * 2.0
            stageHeight = ((stage.boundingBox.max.z - stage.boundingBox.min.z) * 1.8) - 1.8
            stageWidthMin = stage.boundingBox.min.x * 2.0
            stageHeightMin = stage.boundingBox.min.z * 1.8
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.stopActionButton = UIBarButtonItem(image: UIImage(systemName: "stop.fill"), style: .plain, target: self, action: #selector(stopAction(_:)))
        //            self.stopActionButton = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(stopAction(_:)))
        self.stopActionButton?.tintColor = UIColor(named: "color-nav")
        
        
        formationVM = FormationViewModel()
        dancerVM = DancerViewModel()
        setupScene()
        
        self.spriteScene = OverlayScene(size: self.view.frame.size)
        self.spriteScene.isUserInteractionEnabled = true
        prevNode = self.spriteScene.childNode(withName: "prevNode") as! SKSpriteNode
        nextNode = self.spriteScene.childNode(withName: "nextNode") as! SKSpriteNode
        playNode = self.spriteScene.childNode(withName: "playNode") as! SKSpriteNode
        musicNode = self.spriteScene.childNode(withName: "musicNode") as! SKSpriteNode
        self.spriteScene.overlayDelegate = self
        self.sceneView.overlaySKScene = self.spriteScene
        
        
        // add a tap gesture recognizer
        //               let tapGesture = UITapGestureRecognizer(target: self, action:
        //                   #selector(handleTap(_:)))
        //                sceneView.addGestureRecognizer(tapGesture)
        
        // result.node is the node that the user tapped on
        // perform any actions you want on it
        // Do any additional setup after loading the view.
        
        do{
            //print("In Game View Controller getting song ", boardVM.getCurrentBoard()?.song)
            if let a = BoardViewModel.shared.getCurrentBoard()?.song{
                guard let music = URL(string: a) else { print("URL Nil");  return}
                _ = try AVAudioPlayer(contentsOf: music)
                
                musicEnabled = true
            }
            else{
                print("No song")
                musicEnabled = false
            }
            
        }
        catch{
            print("Could Not do music")
            
            musicEnabled = false
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.endActionsHelper()
    }
    
    
    
    @objc func stopAction(_ sender: UIBarButtonItem) {
        //self.navigationItem.setRightBarButton(stopActionButton, animated: true)
        print("Ayy")
        self.endActionsHelper()
        
        
        if formationVM.formationArray.count > 0{
            formationVM.setCurrentSelection(index: 0)
            if let curr = formationVM.getFormation(type: FormationType.current){
                let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
                self.formationSelected(dancers: dancers)
            }
            else{
                print("Error loading in play formations pressed ")
            }
        }
        else{
            print("No formations yet")
        }
        
        
    }
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        //retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject = hitResults[0]
            print(prevNode?.position.x, prevNode?.position.y)
            if prevNode!.contains(p){
                print("PREV NODEIT IS")
            }
            guard let resultNode = result as? SKSpriteNode else { return }
            
            
            
            if let name = resultNode.name
            {
                switch name{
                case "prevNode":
                    print("prev node touched")
                    
                case "nextNode":
                    print("next node touched")
                    
                case "playNode":
                    print("play node touched")
                    
                case "musicNode":
                    print("music node touched")
                default:
                    print("idk")
                }
            }
            
        }
    }
    
    
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
        
        self.stage = scene.rootNode.childNode(withName: "stage", recursively: true)!
        //let boy = templateScene.rootNode.childNode(withName: "boy", recursively: true)!
        
        formationVM.currentBoard = boardVM.getCurrentBoard()
        
        //BoardViewModel.shared.getCurrentBoard()
        formationVM.loadFormations()
        
        
        //let cubeNode = boy
        
        //cubeNode.position = stage.position
        //cubeNode.position = SCNVector3(0, 8, 0) // SceneKit/AR coordinates are in meters
        //sceneView.scene?.rootNode.addChildNode(cubeNode)
        // drawGrid()
        //playFormations()
        if formationVM.formationArray.count > 0{
            formationVM.setCurrentSelection(index: 0)
            if let curr = formationVM.getFormation(type: FormationType.current){
                let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
                self.formationSelected(dancers: dancers)
            }
            else{
                print("Error loading in play formations pressed ")
            }
        }
        else{
            print("No formations yet")
        }
        
    }
    
    func starButtonClicked(){
        print("Button Clicked")
        
    }
    
    func convertToStageDimensions(originalX: Float, originalY: Float) -> SCNVector3{
        //        let stage = scene.rootNode.childNode(withName: "stage", recursively: true)!
        //
        //        let width = (stage.boundingBox.max.x - stage.boundingBox.min.x) * 2.0
        //        let length = (stage.boundingBox.max.z - stage.boundingBox.min.z) * 1.8
        
        let point = PositionManager.percentageToPosition(x: originalX, y: originalY, viewW: CGFloat(self.stageWidth), viewH: CGFloat(self.stageHeight))
        //0.5
        
        let newVector = SCNVector3(point.x + CGFloat(stageWidthMin), 5, -(point.y + CGFloat(stageHeightMin)))
        return newVector
        
    }
    
    
    
    // @objc
    //func handleTap(_ gestureRecognize: UIGestureRecognizer) {
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
    //}
    
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
                
                
                if let toUpdateIndex = currNodes.firstIndex(where: { $0.accessibilityLabel == dancer.id }) {
                    
                    
                    
                    if let next = self?.convertToStageDimensions(originalX: dancer.xPos, originalY: dancer.yPos){
                        let action = SCNAction.move(to: next, duration: 2.0)
                        currNodes[toUpdateIndex].runAction(action)
                    }
                }
                else{
                    print("Not found")
                    self?.templateScene = SCNScene(named: "art.scnassets/Nodes.scn")
                    let cubeNode = self?.templateScene.rootNode.childNode(withName: "boy", recursively: true)! as! SCNNode
                    
                    cubeNode.geometry?.material(named: "headColor")?.diffuse.contents = UIColor(hex: dancer.color)
                    
                    cubeNode.geometry?.material(named: "legColor")?.diffuse.contents = UIColor(hex: dancer.color)
                    cubeNode.geometry?.material(named: "bodyColor")?.diffuse.contents = UIColor(hex: dancer.color)
                    
                    cubeNode.accessibilityLabel = dancer.id
                    let point = self?.convertToStageDimensions(originalX: dancer.xPos, originalY: dancer.yPos)
                    guard let stageWidthMin = self?.stageWidthMin, let stageHeightMin = self?.stageHeightMin else { return }
                    self?.sceneView.scene?.rootNode.addChildNode(cubeNode)
                    currNodes.append(cubeNode)
                    
                    let newVector = SCNVector3(CGFloat(stageWidthMin), 5, -(CGFloat(stageHeightMin)))
                    cubeNode.position = newVector
                    
                    let action = SCNAction.move(to: point!, duration: 2.0)
                    cubeNode.runAction(action)
                    
                }
                //TODO - handle case when dancers are removed from one formation
                
            }
            
            for nodes in currNodes{
                
                if dancers.firstIndex(where: { $0.id == nodes.accessibilityLabel }) != nil {
                    
                }
                else{
                    
                    nodes.removeFromParentNode()
                }
                
            }
            
            
        }
        
        let wait = SCNAction.wait(duration: waitTime)
        arrayOfActions.append(wait)
        arrayOfActions.append(actionA)
        
        let enableTouchAction = SCNAction.run {_ in
            self.enableTouches()
        }
        
        if formIndex + 2 == totalForms && self.musicEnabled == true{
            self.arrayOfActions.append(SCNAction.wait(duration: 2.0))
            self.endSong()
            self.arrayOfActions.append(enableTouchAction)
        }
        else if formIndex + 2 == totalForms && self.musicEnabled == false{
            self.arrayOfActions.append(SCNAction.wait(duration: 2.0))
            self.arrayOfActions.append(enableTouchAction)
        }
        
        
    }
    
    func enableTouches() {
        print("In Enable Detail View")
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItems?.removeAll()
            self.sceneView.overlaySKScene?.isUserInteractionEnabled = true
            self.sceneView.overlaySKScene?.alpha = 1.0
        }
    }
    
    func endActionsHelper(removeDancers: Bool = true){
        self.scene.rootNode.removeAction(forKey: "playMusic")
        self.scene.rootNode.removeAllAudioPlayers()
        sceneView.scene?.rootNode.enumerateChildNodes({ (dancerNode, stop) in
            sceneView.scene?.rootNode.removeAllActions()
            if dancerNode.name == "boy"{
                dancerNode.removeFromParentNode()
                dancerNode.removeAllActions()
                
            }
            
            if dancerNode.name == "music"{
                dancerNode.removeAllActions()
                dancerNode.removeFromParentNode()
            }
        })
        
        self.navigationItem.rightBarButtonItems?.removeAll()
        self.sceneView.overlaySKScene?.isUserInteractionEnabled = true
        self.sceneView.overlaySKScene?.alpha = 1.0
    }
    
    
    func playFormations(){
        
        guard formationVM.formationArray.count > 1 else { return }
        self.arrayOfActions = []
        self.endActionsHelper()
        formationVM.setCurrentSelection(index: 0)
        
        guard let curr = formationVM.getFormation(type: FormationType.current) else { return }
        self.navigationItem.setRightBarButton(stopActionButton, animated: true)
        let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
        self.formationSelected(dancers: dancers)
        
        self.sceneView.overlaySKScene?.isUserInteractionEnabled = false
        self.sceneView.overlaySKScene?.alpha = 0.3
        
        var waitT = 0.0
        
        for _ in 0..<formationVM.formationArray.count{
            
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    
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
                
                cubeNode.geometry?.material(named: "headColor")?.diffuse.contents = UIColor(hex: dancer.color)
                
                cubeNode.geometry?.material(named: "legColor")?.diffuse.contents = UIColor(hex: dancer.color)
                cubeNode.geometry?.material(named: "bodyColor")?.diffuse.contents = UIColor(hex: dancer.color)
                
                
                cubeNode.accessibilityLabel = dancer.id
                //            let width = (stage.boundingBox.max.x - stage.boundingBox.min.x) * 2.0
                //            let height = (stage.boundingBox.max.z - stage.boundingBox.min.z) * 1.8
                
                let point = PositionManager.percentageToPosition(x: dancer.xPos, y: dancer.yPos, viewW: CGFloat(self.stageWidth), viewH: CGFloat(self.stageHeight))
                
                cubeNode.position = SCNVector3(point.x + CGFloat(self.stageWidthMin), 5, -(point.y + CGFloat(self.stageHeightMin))) // SceneKit/AR coordinates are in meters
                
                sceneView.scene?.rootNode.addChildNode(cubeNode)
                //closestNode!.lineWidth = 20
                
            }
        }
        
        
    }
    
    func playNextFormation(){
        
        self.arrayOfActions = []
        
        if let nextFormation = formationVM.getFormation(type: FormationType.next){
            
            let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
            if let nextIndex = formationVM.getCurrentIndex(){
                formationVM.setCurrentSelection(index: nextIndex + 1)
            }
            if let index = formationVM.getCurrentIndex(){
                self.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
            }
        }
        scene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
    }
    
    func playPrevFormation(){
        
        self.arrayOfActions = []
        
        if let prevFormation = formationVM.getFormation(type: FormationType.previous){
            //Get previous, load dancers from previous,
            let nextDancerForms = dancerVM.loadDancers(selectedFormation: prevFormation, current: false)
            
            if let index = formationVM.getCurrentIndex(){
                formationVM.setCurrentSelection(index: index - 1)
                self.playThroughFormations(dancers: nextDancerForms, waitTime: 0.0, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
            }
        }
        scene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
    }
}

extension SceneKitViewController: OverlaySceneDelegate{
    func playPressed() {
        print("YOO")
        playFormations()
    }
    
    func nextPressed() {
        print("YOO")
        playNextFormation()
    }
    
    func prevPressed() {
        print("YOO")
        playPrevFormation()
    }
    
    func musicPressed() {
        
        
        if musicEnabled{
            guard formationVM.formationArray.count > 1 else { return }
            guard let songString = BoardViewModel.shared.getCurrentBoard()?.song else { return }
            self.arrayOfActions = []
            self.endActionsHelper()
            
            let music = URL(string: songString)
            self.sceneView.overlaySKScene?.isUserInteractionEnabled = false
            self.sceneView.overlaySKScene?.alpha = 0.3
            
            self.navigationItem.setRightBarButton(stopActionButton, animated: true)
            
            
            formationVM.setCurrentSelection(index: 0)
            
            playSong(musicLink: music)
            if let curr = formationVM.getFormation(type: FormationType.current){
                let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
                self.formationSelected(dancers: dancers)
            }
            else{
                print("Error loading in play formations pressed ")
            }
            var waitT = 0.0
            
            for _ in 0..<formationVM.formationArray.count{
                
                if let nextFormation = formationVM.getFormation(type: FormationType.next){
                    let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                    let time = self.calculateWaitHelper(withMusic: true)
                    if let index = formationVM.getCurrentIndex(){
                        
                        self.playThroughFormations(dancers: nextDancerForms, waitTime: time, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                        
                        waitT = 3.0
                        
                        formationVM.setCurrentSelection(index: index + 1)
                    }
                    
                }
                
                scene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
            }
            
        }
        else{
            showMusicAlert()
        }
    }
    
    func showMusicAlert() {
        let alert = UIAlertController(title: "Music", message: "No music detected",         preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Continue",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                      }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func calculateWaitHelper(withMusic: Bool = false) -> Double{
        var wait = 3.0
        guard let curr = formationVM.getFormation(type: FormationType.current) else {
            return wait
        }
        if  let prev = formationVM.getFormation(type: FormationType.previous) {
            if !withMusic{
                wait = 3.0
                
            }
            if withMusic{
                wait = Double(curr.songTime - prev.songTime)
            }
            //go through and set all the wait times, prev + 3 to a certain amount initially when music is loaded
            //when edited, select next song times to be + 3 seconds after
            //when
        }
        else{
            wait = Double(curr.songTime)
        }
        return wait
    }
    
    
    
    
    
    
    
}


extension SceneKitViewController{
    
    
    func playSong(musicLink: URL? = nil){
        
        
        sceneView.scene?.rootNode.enumerateChildNodes({ (musicNode, stop) in
            sceneView.scene?.rootNode.removeAllActions()
            if musicNode.name == "music"{
                musicNode.removeFromParentNode()
                musicNode.removeAllActions()
                
            }
        })
        
        if let musicURL = musicLink{
            backgroundMusic = SCNAudioSource(url: musicURL)
            
            //            node.runAction(SCNAction.playAudio(sounds[sound]!, waitForCompletion: false))
            //
            //            backgroundMusic.name = "music"
            //            sceneView.scene?.rootNode.runAction(SCNAction.playAudio(backgroundMusic!, waitForCompletion: false))
            
            //            let enableTouchAction = SCNAction.run {_ in
            //                self.enableTouches()
            //            }
            //self.sceneView.scene?.rootNode.runAction(SCNAction.playAudio(self.backgroundMusic!), forKey: "playMusic")
            self.sceneView.scene?.rootNode.runAction(SCNAction.playAudio(self.backgroundMusic!, waitForCompletion: false), forKey: "playMusic")
            
            //            let actionB = SCNAction.run {_ in
            //                self.sceneView.scene?.rootNode.runAction(SCNAction.playAudio(self.backgroundMusic!, waitForCompletion: false), forKey: "playMusic")
            //            }
            
            //arrayOfActions.append(actionB)
        }
        
        else{
            print("Error in selecting music")
        }
        
        //scene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
    }
    
    
    func endSong(){
        //var musicNodeArray : [SKNode] = []
        
        if backgroundMusic != nil{
            
            let actionC = SCNAction.run {_ in
                
                self.scene.rootNode.removeAction(forKey: "playMusic")
                self.scene.rootNode.removeAllAudioPlayers()
            }
            
            arrayOfActions.append(actionC)
        }
        else{
            print("Error in stopping music")
        }
    }
    
}
