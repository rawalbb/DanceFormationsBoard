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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
