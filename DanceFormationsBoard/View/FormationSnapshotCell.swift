//
//  FormationSnapshotCell.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/2/20.
//

import UIKit

class FormationSnapshotCell: UITableViewCell {

    
    @IBOutlet weak var formationImage: UIImageView!
    
    @IBOutlet weak var formationName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        formationImage.layer.borderWidth = 4
        formationImage.layer.borderColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        //formationImage.layer.borderWidth = 4
        ///formationImage.layer.borderColor = #colorLiteral(red: 0.4860776067, green: 0.5446216464, blue: 0.6717045903, alpha: 1)
        
        self.layer.borderWidth = 3
        self.layer.borderColor = selected ? UIColor.red.cgColor : UIColor.clear.cgColor
        }
    

    
    
    
}
