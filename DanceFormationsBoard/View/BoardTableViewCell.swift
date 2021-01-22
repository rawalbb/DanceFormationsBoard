//
//  BoardTableViewCell.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/1/20.
//

import UIKit

class BoardTableViewCell: UITableViewCell {

    
    @IBOutlet weak var boardNameTextField: UITextField!
    
    @IBOutlet weak var boardDateTextField: UILabel!
    
    @IBOutlet weak var boardImageField: UIImageView!
    
    @IBOutlet weak var stageTypeSegmentedControl: UISegmentedControl!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        stageTypeSegmentedControl.layer.backgroundColor = UIColor.black.cgColor
        
        stageTypeSegmentedControl.layer.borderWidth = 2
        
        stageTypeSegmentedControl.layer.borderColor = UIColor.black.cgColor
        
        stageTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
