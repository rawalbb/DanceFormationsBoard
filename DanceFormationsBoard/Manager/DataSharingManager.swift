//
//  DataSharing.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 1/10/21.
//

import Foundation

class DataSharingManager{
    
    let boardVM = BoardViewModel()
    
    static func importData(from url: URL, decoder: JSONDecoder) {
      

        if let data = try? Data(contentsOf: url){
            print("DATA IN IMPORT ", data)
        }
      guard
        let data = try? Data(contentsOf: url), let newBoard = try? decoder.decode(Board.self, from: data)
        else { return }
      
      // 3
      //try? FileManager.default.removeItem(at: url)
    }
    
}
