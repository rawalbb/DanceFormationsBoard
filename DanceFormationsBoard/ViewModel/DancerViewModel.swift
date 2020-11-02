import Foundation
import UIKit

class DancerViewModel{
  
  let dancer: DancerModel
  
  init(dancer: DancerModel) {
    self.dancer = dancer
}
  
  func updateDancerLabel(newLabel: String){
    let updatedDancer = dancer
    updatedDancer.label = newLabel
  }
  
  func updateDancerColor(newColor: UIColor){
    let updatedDancer = dancer
    updatedDancer.dancer.color = newColor
  }
}
