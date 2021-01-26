//
//  ImageDataManager.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/7/20.
//

import Foundation
import UIKit
import SpriteKit

class ImageDataManager{
    
    static func imageToData(image: UIImage) -> Data?{
        
        if let convertedData = image.jpegData(compressionQuality: 1.0){
            return convertedData
        }
        else{
            return nil
        }
    }
    
    static func dataToImage(dataStr: Data) -> UIImage?{
        if let convertedImage = UIImage(data: dataStr){
            return convertedImage
        }
        else{
            return nil
        }
        
    }
    
    static func sceneToData(view formationView: SKView!) -> Data?{
        
        let renderer = UIGraphicsImageRenderer(size: formationView.frame.size)
        let sceneImage = renderer.image { ctx in
            formationView.drawHierarchy(in: formationView.bounds, afterScreenUpdates: true)
        }
        let convertedData = self.imageToData(image: sceneImage)
        return convertedData
    }

    
}
