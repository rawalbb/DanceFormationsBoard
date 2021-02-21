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
    var stageScene: SCNScene!
    var dancerScene: SCNScene!
    var formationVM = FormationViewModel()
    var dancerVM = DancerViewModel()
    var arrayOfActions: [SCNAction] = []
    var spriteScene: OverlayScene!
    var prevNode: SKNode?
    var nextNode: SKNode?
    var playNode: SKNode?
    var musicNode: SKNode?
    var stopNode: SKNode?
    var backgroundAudioSource: SCNAudioSource?
    var musicEnabled: Bool = false
    var boardVM = BoardViewModel.shared
    var stageWidth: Float = 0.0
    var stageHeight: Float = 0.0
    var stageWidthMin: Float = 0.0
    var stageWidthMax: Float = 0.0
    var stageHeightMin: Float = 0.0
    var stopActionButton: UIBarButtonItem?
    let stageScale: Float = 2.0
    
    var stage: SCNNode? = nil {
        didSet{
            guard let stage = stage else { return }
            stageWidth = (stage.boundingBox.max.x - stage.boundingBox.min.x) * stageScale
            stageHeight = ((stage.boundingBox.max.z - stage.boundingBox.min.z) * stageScale) - (stageScale * 2)
            stageWidthMin = stage.boundingBox.min.x * stageScale
            stageWidthMax = stage.boundingBox.max.x * stageScale
            stageHeightMin = stage.boundingBox.min.z * stageScale
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets stopActionButton properties
        stopActionButton = UIBarButtonItem(image: UIImage(systemName: "stop.fill"), style: .plain, target: self, action: #selector(stopAction(_:)))
        stopActionButton?.tintColor = UIColor(named: "color-nav")
        
        setupScene()
        
        spriteScene = OverlayScene(size: self.view.frame.size)
        spriteScene.isUserInteractionEnabled = true
        spriteScene.overlayDelegate = self
        sceneView.overlaySKScene = self.spriteScene
        
        prevNode = spriteScene.childNode(withName: "prevNode") as! SKSpriteNode
        nextNode = spriteScene.childNode(withName: "nextNode") as! SKSpriteNode
        playNode = spriteScene.childNode(withName: "playNode") as! SKSpriteNode
        musicNode = spriteScene.childNode(withName: "musicNode") as! SKSpriteNode
        //stopNode = spriteScene.childNode(withName: "stopNode") as! SKSpriteNode
        
        do{
            if let musicUrl = BoardViewModel.shared.getCurrentBoard()?.song{
                guard let music = URL(string: musicUrl) else { print("SKVC - cannoto convert music String to Url");  return}
                _ = try AVAudioPlayer(contentsOf: music)
                backgroundAudioSource = SCNAudioSource(url: music)
                musicEnabled = true
            }
            else{
                print("SKVC - no music detected")
                musicEnabled = false
            }
            
        }
        catch{
            print("SKVC - could not play music")
            musicEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.endActionsHelper()
    }
    
    @objc func stopAction(_ sender: UIBarButtonItem) {
        self.endActionsHelper()
        
        if formationVM.formationArray.count > 0{
            presentCurrentFormation(index: 0)
        }
        else{
            print("SVC - no formation to present")
        }
        
        
    }
    
    func presentCurrentFormation(index: Int? = nil){
        if let index = index{
            formationVM.setCurrentSelection(index: index)
        }
        guard let curr = formationVM.getFormation(type: FormationType.current) else { print("SVC - Error presenting current formation"); return }
        let dancers = dancerVM.loadDancers(selectedFormation: curr, current: true)
        self.formationSelected(dancers: dancers)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        print("HI there")
        
        
    }
    
    func setupScene(){
        sceneView = (self.view as! SCNView)
        sceneView.allowsCameraControl = true
        stageScene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene = stageScene
        dancerScene = SCNScene(named: "art.scnassets/Nodes.scn")
        
        stage = stageScene.rootNode.childNode(withName: "stage", recursively: true)!
        
        formationVM.currentBoard = boardVM.getCurrentBoard()
        
        _ = formationVM.loadFormations()
        
        if formationVM.formationArray.count > 0{
            presentCurrentFormation(index: 0)
        }
        else{
            print("SVC - no formations")
        }
        
    }
    
    func convertToStageDimensions(originalX: Float, originalY: Float) -> SCNVector3{
        
        let point = PositionManager.percentageToPosition(x: originalX, y: originalY, viewW: CGFloat(self.stageWidth), viewH: CGFloat(self.stageHeight))
        
        let newVector = SCNVector3(point.x + CGFloat(stageWidthMin), 3, -(point.y + CGFloat(stageHeightMin)))
        return newVector
        
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func playThroughFormations(dancers: [Dancer], waitTime: Double, transitionTime: Double, formIndex: Int, totalForms: Int){
        
        let actionA = SCNAction.run {[weak self] _ in
            
            var currNodes: [SCNNode] = []
            self?.stageScene.rootNode.childNodes.filter({ $0.name == "dancer" }).forEach({
                                                                                            currNodes.append($0 ) })
            
            for dancer in dancers{
                
                if let toUpdateIndex = currNodes.firstIndex(where: { $0.accessibilityLabel == dancer.id }) {
                    
                    if let next = self?.convertToStageDimensions(originalX: dancer.xPos, originalY: dancer.yPos){
                        let action = SCNAction.move(to: next, duration: 2.0)
                        currNodes[toUpdateIndex].runAction(action)
                    }
                }
                else{
                    self?.dancerScene = SCNScene(named: "art.scnassets/Nodes.scn")
                    let cubeNode = self?.dancerScene.rootNode.childNode(withName: "dancer", recursively: true) as! SCNNode
                    
                    cubeNode.geometry?.material(named: "headColor")?.diffuse.contents = UIColor(hex: dancer.color)
                    cubeNode.geometry?.material(named: "legColor")?.diffuse.contents = UIColor(hex: dancer.color)
                    cubeNode.geometry?.material(named: "bodyColor")?.diffuse.contents = UIColor(hex: dancer.color)
                    
                    cubeNode.accessibilityLabel = dancer.id
                    
                    guard let point = self?.convertToStageDimensions(originalX: dancer.xPos, originalY: dancer.yPos) else { return }
                    
                    self?.sceneView.scene?.rootNode.addChildNode(cubeNode)
                    currNodes.append(cubeNode)
                    
                    let startingX = self?.getNearestStartingPoint(endPointX: point.x)
                    
                    let newVector = SCNVector3(CGFloat(startingX ?? 0.0), 3, (CGFloat(point.z)))
                    cubeNode.position = newVector
                    
                    let action = SCNAction.move(to: point, duration: 2.0)
                    cubeNode.runAction(action)
                    
                }
                
            }
            
            for nodes in currNodes{
                
                if dancers.firstIndex(where: { $0.id == nodes.accessibilityLabel }) == nil {
                    let fadeAction = SCNAction.fadeOut(duration: 1.0)
                    let remove = SCNAction.removeFromParentNode()
                    let sequence = SCNAction.sequence([fadeAction, remove])
                    nodes.runAction(sequence)
                }
                
            }
            
        }
        print("WAITING FOR", waitTime)
        let wait = SCNAction.wait(duration: waitTime)
        arrayOfActions.append(wait)
        arrayOfActions.append(actionA)
        
        let enableTouchAction = SCNAction.run {_ in
            self.enableTouches()
        }
        print("Form Index, Totla forms: ", formIndex, totalForms)
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
        let root = stageScene.rootNode
        root.removeAllAudioPlayers()
        root.removeAllActions()
        root.enumerateChildNodes({ (dancerNode, stop) in
            if dancerNode.name == "dancer"{
                dancerNode.removeFromParentNode()
                dancerNode.removeAllActions()
            }
        })
        
        self.navigationItem.rightBarButtonItems?.removeAll()
        self.sceneView.overlaySKScene?.isUserInteractionEnabled = true
        self.sceneView.overlaySKScene?.alpha = 1.0
    }
    
    
    func playFormations(withMusic: Bool = false){
        
        guard formationVM.formationArray.count > 1 else { print("SVC - formation array !> 1"); return }
        self.arrayOfActions = []
        self.endActionsHelper()
        
        guard let curr = formationVM.getFormation(type: FormationType.current) else { return }
        var proceed: Bool = true
        if withMusic{
            proceed = playMusic()
            guard proceed == true else {print("SVC - Failed Music in FormationMusicHelper"); return }
        }
        
        
        self.navigationItem.setRightBarButton(stopActionButton, animated: true)
        
        presentCurrentFormation(index: 0)
        
        self.sceneView.overlaySKScene?.isUserInteractionEnabled = false
        self.sceneView.overlaySKScene?.alpha = 0.3
        
        for _ in 0..<formationVM.formationArray.count{
            
            if let nextFormation = formationVM.getFormation(type: FormationType.next){
                let nextDancerForms = dancerVM.loadDancers(selectedFormation: nextFormation, current: false)
                if let index = formationVM.getCurrentIndex(){
                    let wait = calculateWaitHelper(withMusic: withMusic)
                    self.playThroughFormations(dancers: nextDancerForms, waitTime: wait, transitionTime: 2.0, formIndex: index, totalForms: formationVM.formationArray.count)
                    
                    formationVM.setCurrentSelection(index: index + 1)
                    
                }
                
            }   
            
            stageScene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
        }
        
    }
    
    
    func formationSelected(dancers: [Dancer]? = nil, index: IndexPath? = nil){
        
        if let dancers = dancers{
            for dancer in dancers{
                
                dancerScene = SCNScene(named: "art.scnassets/Nodes.scn")
                
                let cubeNode = dancerScene.rootNode.childNode(withName: "dancer", recursively: true)!
                
                cubeNode.geometry?.material(named: "headColor")?.diffuse.contents = UIColor(hex: dancer.color)
                
                cubeNode.geometry?.material(named: "legColor")?.diffuse.contents = UIColor(hex: dancer.color)
                cubeNode.geometry?.material(named: "bodyColor")?.diffuse.contents = UIColor(hex: dancer.color)
                
                
                cubeNode.accessibilityLabel = dancer.id
                
                
                let point = PositionManager.percentageToPosition(x: dancer.xPos, y: dancer.yPos, viewW: CGFloat(self.stageWidth), viewH: CGFloat(self.stageHeight))
                
                cubeNode.position = SCNVector3(point.x + CGFloat(self.stageWidthMin), 3, -(point.y + CGFloat(self.stageHeightMin))) // SceneKit/AR coordinates are in meters
                
                sceneView.scene?.rootNode.addChildNode(cubeNode)
                
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
        stageScene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
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
        stageScene.rootNode.runAction(SCNAction.sequence(self.arrayOfActions))
    }
    
}

extension SceneKitViewController: OverlaySceneDelegate{
    func playPressed() {
        playFormations()
    }
    
    func nextPressed() {
        playNextFormation()
    }
    
    func prevPressed() {
        playPrevFormation()
    }
    
    func musicPressed() {
        playFormations(withMusic: true)

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
        }
        else{
            if !withMusic{
                wait = 3.0
                
            }
            if withMusic{
                wait = Double(curr.songTime)
            }
        }
        return wait
    }
    
    func getNearestStartingPoint(endPointX: Float) -> Float{
        let nearestStartArray = [stageWidthMin, stageWidthMax]
        
        var nearestX: Float {
            
            nearestStartArray.reduce(34.3 as Float){
                if abs($1 - endPointX) < abs($0 - endPointX){
                    return Float($1)
                    
                }
                else{
                    return Float($0)
                }
            }
        }
        return nearestX
    }
    
}

extension SceneKitViewController{
    func playMusic() -> Bool{
        
        if musicEnabled{
            guard let musicSource = backgroundAudioSource else { print("Error Setting Background Source")
                return false
            }
            musicSource.isPositional = false
            musicSource.shouldStream = false
            musicSource.load()
            let musicPlayer = SCNAudioPlayer(source: musicSource)
            self.sceneView.scene?.rootNode.addAudioPlayer(musicPlayer)
            return true
        }
        else{
            showMusicAlert()
            return false
        }
    }
    
    func endSong(){
        
        if backgroundAudioSource != nil{
            let actionC = SCNAction.run {_ in
                self.stageScene.rootNode.removeAllAudioPlayers()
            }
            
            arrayOfActions.append(actionC)
        }
        else{
            print("SVC - Background music is nil so cannot stop")
        }
    }
    
}
