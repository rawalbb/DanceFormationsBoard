//
//  GameViewController+Stage.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/22/20.
//

import Foundation
import UIKit
import SpriteKit


//MARK: - GAMESCENE Delegate/Protocols
extension GameViewController: StageSceneUpdatesDelegate{
    
    func enableTouches() {
        print("In Enable Detail View")
        DispatchQueue.main.async {
            //self.detailView.isUserInteractionEnabled = true
            //self.detailView.alpha = 1.0
            self.showDetailButtons()
            self.enableStageTouch()
            self.ableDetailButtons(enable: true)
        }
    }
    

    
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String) {
        
        if let curr = formationVM.getFormation(type: FormationType.current){
            print("Current Index", formationVM.getCurrentIndex()!)

        dancerVM.addDancer(xPosition: xPosition, yPosition: yPosition, label: label, id: id, color: color, selectedFormation: curr)
            
            dancerVM.saveDancer()
            _ = dancerVM.loadDancers(selectedFormation: curr, current: true)
        }
        
        if let imageData = ImageDataManager.sceneToData(view: stageView){
                
            formationVM.updateFormImage(imageData: imageData)
            
        
        }
       
        allFormUpdates()
    }
    
    func dancerMoved(id: String, xPosition: Float, yPosition: Float) {
        if let curr = formationVM.getFormation(type: FormationType.current){

            dancerVM.updateDancerPosition(id: id, xPosition: xPosition, yPosition: yPosition, owner: curr)
        }
        else{
            print("Cannot Find Curr Formation")
        }
        
        
        dancerVM.saveDancer()
        if let imageData = ImageDataManager.sceneToData(view: stageView){

                formationVM.updateFormImage(imageData: imageData)
        
        }
        allFormUpdates()
    }
    
    func enableTextField(enable: Bool, id: String) {
        enableText = enable
        if enableText{
            nodeLabelTextField.isHidden = false
            nodeLabelTextField.text = dancerVM.getDancer(id: id)?.label ?? ""
        }
        else{

            nodeLabelTextField.isHidden = true
            nodeLabelTextField.text = ""
        }
        //print(enableText)
    }
    
    func updateNodeColor(color: UIColor) {
        stage.selectedColor = color
        selectedColor = color
        nodeColorButton.backgroundColor = selectedColor
    }
    
    func removedDancer(id: String) {
        dancerVM.removeDancer(dancerId: id)
        dancerVM.saveDancer()
        if let imageData = ImageDataManager.sceneToData(view: stageView){

                formationVM.updateFormImage(imageData: imageData)

        }
        allFormUpdates()
    }
    
    func updateFormationSelected(index: IndexPath) {
        DispatchQueue.main.async {
            self.formsTableView.selectRow(at: index, animated: true, scrollPosition: .top)
            self.enableText = false
            self.nodeLabelTextField.text = ""

        
        }
        
    }
    

    
}

extension GameViewController{
    
    func disableStageTouch(){
        stage.isUserInteractionEnabled = false
    }
    
    func enableStageTouch(){
        stage.isUserInteractionEnabled = true
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
            wait = Double(curr.songTime)
        }
        return wait
    }
    
}
