//
//  BoardCollectionViewCell.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/28/20.
//

import UIKit

class BoardCollectionViewCell: UICollectionViewCell {


    @IBOutlet weak var boardImage: UIImageView!
    
    @IBOutlet weak var boardTextField: UITextField!
    
    static var reuseIdentfier: String {
        return "BoardReusableCell"
    }
    static var nibName: String {
        return "BoardCollectionViewCell"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.green
          isSelected = false
        // Initialization code
    }
    
    override var isSelected: Bool {
      didSet {
        self.boardImage.image = UIImage(systemName: "airplayaudio")
      }
    }
    
    
    
    
    

}

