//
//  PositionManager.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/8/21.
//

import Foundation
import UIKit

class PositionManager{
    
    static func positionToPercentage(x: CGFloat, y: CGFloat, viewW: CGFloat?, viewH: CGFloat?) -> CGPoint{
        
        if let w = viewW, let h = viewH{
            
            let newX = (x)/(w)
            let newY = (y)/(h)
            return CGPoint(x: newX, y: newY)
        }
        else{
            print("Could not convert position to percent")
            return CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    static func percentageToPosition(x: Float, y: Float, viewW: CGFloat?, viewH: CGFloat?) -> CGPoint{
        
        if let w = viewW, let h = viewH{
            
            let newX = (w) * CGFloat(x)
            let newY = (h) * CGFloat(y)
            return CGPoint(x: newX, y: newY)
        }
        else{
            print("Could not convert percent to position")
            return CGPoint(x: 0.0, y: 0.0)
        }
    }
    
}
