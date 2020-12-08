//
//  ImageDataManager.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/7/20.
//

import Foundation
import UIKit

class ImageDataManager{
    
static func imageToData(image: UIImage) -> Data?{
    
        // 1.0 represents best compression quality
        if let data = image.jpegData(compressionQuality: 1.0){
            return data
        }
        else{
            return nil
        }
    }
}
