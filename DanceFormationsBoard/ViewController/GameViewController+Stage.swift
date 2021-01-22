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

    
    func dancerToAdd(xPosition: Float, yPosition: Float, id: String, color: String, label: String) {
        
        if let curr = formationVM.getFormation(type: FormationType.current){
            print("Current Index", formationVM.getCurrentIndex()!)

        dancerVM.addDancer(xPosition: xPosition, yPosition: yPosition, label: label, id: id, color: color, selectedFormation: curr)
            
            dancerVM.saveDancer()
            dancerVM.loadDancers(selectedFormation: curr, current: true)
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
//            switch enableText{
//            case true:
//                <#code#>
//            case false:
//                <#code#>
//            }
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
    //stored is start time
    //for formation 1, calculate wait time by getting next formation
    func waitTimeCalculator() -> Double{
//        if let nextStart = formationVM.getFormation(type: FormationType.next)?.songTime, let currStart = formationVM.getFormation(type: FormationType.current)?.songTime {
//            return Double(nextStart - currStart)
//        }
//        else{
//            return 3.0
//        }
        //calculatewait
        
        return 3.0
    }
    
    func initialWaitCalculator(){
        guard let initial = formationVM.getFormation(type: FormationType.atLocation(0)) else { return }
        let wait = SKAction.wait(forDuration: Double(initial.songTime))
        stage.arrayOfActions.append(wait)
        
    }
    
}
