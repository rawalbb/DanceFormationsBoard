//
//  BoardTableViewCell.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/1/20.
//

import UIKit

class BoardTableViewCell: UITableViewCell, FJButton3DDelegate {

    
    @IBOutlet weak var boardNameTextField: UITextField!
    
    @IBOutlet weak var boardDateTextField: UILabel!
    
    @IBOutlet weak var boardImageField: UIImageView!
    
    @IBOutlet private weak var button3D: FJButton3D!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        button3D.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func didTap(onButton3D button3d: FJButton3D) {
        //toggleButton3D.pressed = false
    }

    
}


