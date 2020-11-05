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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
