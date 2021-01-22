//
//  OverlayScene.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/19/21.
//

import UIKit
import SpriteKit

protocol OverlaySceneDelegate{
    
    func playPressed()
    
    func nextPressed()
    
    func prevPressed()
    
    func musicPressed()
    
}

class OverlayScene: SKScene {
    
    var prevNode = SKSpriteNode()
    var playNode = SKSpriteNode()
    var nextNode = SKSpriteNode()
    var musicNode = SKSpriteNode()
    var overlayDelegate: OverlaySceneDelegate?
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clear
        print("SIZE ", size.width, size.width * 0.2)
        let widthMiddle = size.width/2
        let heightMenu = size.height/8

        
        let prevImage = UIImage(named: "prevButton")
        let playImage = UIImage(named: "playButton")
        let nextImage = UIImage(named: "nextButton")
        let musicImage = UIImage(named: "musicButton")
        let prevTexture = SKTexture(image: prevImage!)
        let playTexture = SKTexture(image: playImage!)
        let nextTexture = SKTexture(image: nextImage!)
        let musicTexture = SKTexture(image: musicImage!)
        prevNode = SKSpriteNode(texture: prevTexture)
        playNode = SKSpriteNode(texture: playTexture)
        nextNode = SKSpriteNode(texture: nextTexture)
        musicNode = SKSpriteNode(texture: musicTexture)
//        prevNode.color = SKColor.white
//        prevNode.colorBlendFactor = 1.0
        
        self.prevNode.size = CGSize(width: 34, height: 34)
        self.playNode.size = prevNode.size
        self.nextNode.size = self.prevNode.size
        self.musicNode.size = self.prevNode.size
        
        self.playNode.position = CGPoint(x: widthMiddle - 50, y: heightMenu)
        self.prevNode.position = CGPoint(x: playNode.position.x - 100, y: heightMenu)
        self.nextNode.position = CGPoint(x: widthMiddle + 50, y: heightMenu)
        self.musicNode.position = CGPoint(x: self.nextNode.position.x + 100, y: heightMenu)
        self.prevNode.name = "prevNode"
        self.playNode.name = "playNode"
        self.nextNode.name = "nextNode"
        self.musicNode.name = "musicNode"
        
        prevNode.isUserInteractionEnabled = false
        musicNode.isUserInteractionEnabled = false
        nextNode.isUserInteractionEnabled = false
        playNode.isUserInteractionEnabled = false
        playNode.isHidden = false
       
        

        
        self.addChild(self.prevNode)
        self.addChild(self.playNode)
        self.addChild(self.nextNode)
        self.addChild(self.musicNode)
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {  return }
                let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
            
        if let name = touchedNode.name
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
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard  let touch = touches.first as? UITouch else { return }
        let location = touch.location(in: self)
        
        if prevNode.contains(location){
            self.overlayDelegate?.prevPressed()
        }
        else if nextNode.contains(location){
            self.overlayDelegate?.nextPressed()
        }
        else if playNode.contains(location){
            print("Play")
            self.overlayDelegate?.playPressed()
        }
        else if musicNode.contains(location){
            self.overlayDelegate?.musicPressed()
        }
        
    }
}
