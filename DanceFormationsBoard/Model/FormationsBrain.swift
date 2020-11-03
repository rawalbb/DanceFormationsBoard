//
//  FormationsBrain.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/2/20.
//

import Foundation

public class FormationsBrain{
  
  var formations: [Formation]
  
  init(formation: Formation){
    self.formations = [formation]
  }
    

    func getNumFormations() -> Int{
        return formations.count
    }
    
    func getFormation() -> Formation{
        return formations[0]
    }
  //var currentNode - nil
  //var getCurrentNode
  //func delete current node
  //func delete all
  
  //var array of allNodes and their child node labels in formation
  //
    
    
    //get curent formation
    //get next formation
    //get previous formation
}
