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
    
static func imageToString(image: UIImage) -> String?{
    
        // 1.0 represents best compression quality
        if let data = image.jpegData(compressionQuality: 1.0){
            return data.base64EncodedString()
        }
        else{
            return nil
        }
    }
    
    static func stringToImage(string: String) -> UIImage?{
        
            // 1.0 represents best compression quality
            if let data = Data(base64Encoded: string){
                return UIImage(data: data)
            }
            else{
                return nil
            }
        }
    
    static func imageToRegString(image: UIImage) -> String?{
        
        if let data = image.jpegData(compressionQuality: 1.0){
            let decodedString = String(data: data, encoding: .utf8)
            print("DECODEDDD  ", decodedString)
            print(data.base64EncodedString())
            return decodedString
        }
        else{
            return nil
        }
        
    }
    static func stringToRegImage(dataStr: String) -> UIImage?{
        
        guard let encoded = dataStr.data(using: .utf8)?.base64EncodedString() else {return nil}
        
        if let data = Data(base64Encoded: encoded){
            return UIImage(data: data)
        }
        else{
            return nil
        }
    }
    
    static func sceneToImage(view formationView: SKView) -> UIImage?{
        
        let renderer = UIGraphicsImageRenderer(size: formationView.frame.size)
        let image = renderer.image { ctx in
            formationView.drawHierarchy(in: formationView.bounds, afterScreenUpdates: true)
        }
     
        return image
    }
    
    static func sceneToString(view formationView: SKView) -> String?{
        
        let renderer = UIGraphicsImageRenderer(size: formationView.frame.size)
        let image = renderer.image { ctx in
            formationView.drawHierarchy(in: formationView.bounds, afterScreenUpdates: true)
        }
        
        let convertedStr = self.imageToRegString(image: image)
        print("PRINTING CONVERTED STRING ", convertedStr)
        return convertedStr
    }
    
    
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
