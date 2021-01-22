//
//  FormationSnapshotCell.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/2/20.
//

import UIKit

class FormationSnapshotCell: UITableViewCell {

    
    @IBOutlet weak var formationImage: UIImageView!
    
    @IBOutlet weak var formNameTextfield: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        formationImage.layer.borderWidth = 1
        formationImage.layer.borderColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        //formationImage.layer.borderWidth = 4
        ///formationImage.layer.borderColor = #colorLiteral(red: 0.4860776067, green: 0.5446216464, blue: 0.6717045903, alpha: 1)
        
        self.layer.borderWidth = 2
        self.layer.borderColor = selected ? UIColor(named: "color-heading")?.cgColor ?? #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1).cgColor : UIColor.clear.cgColor
        }
    


    
    
}
