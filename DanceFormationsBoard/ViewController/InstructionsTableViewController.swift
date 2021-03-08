//
//  InstructionsTableViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 2/5/21.
//

import UIKit

class InstructionsTableViewController: UITableViewController {

    var boardInstructions: [String] = ["1. Each Dance Board represents a dance routine with multiple formations",
        "2. Add a Board: Tap on the rectangular button with a plus sign at the top left",
        "3. Edit Board Title: Tap on the board title which will prompt your keyboard to appear",
        "4. Switch between 2D and 3D modes: Select the appropriate toggle switch and click on the image",
        "5. The 2D screen allows editing/viewing formations. 3D screen only allows viewing formations",
        "5. Delete Dance Board: Swipe right",
        "6. Add Notes to a Dance Board: Swipe left and select Notes",
        "7. Send a Dance Board: Swipe left and select the forward button. You should be prompted to send via multiple platforms including iMessage.",
        "8. Open a Dance Board sent to you through iMessage: Click on the individual’s name at the top of the iMessage and select the info button. Scroll to see all files shared. You should see the file with a .board extension. Select the file and select the upload button. You should be allowed to open the Dance Board through the DanceBoards app."]
    var formInstructions: [String] = [
        "1. Add a dancer: tap on the person icon with the add symbol",
        "2. The selected dancer will always be outlined",
        "3. Remove a dancer: drag the dancer out of the grid, the dancer will be removed for that formation only",
        "4. Add dancer label: tap on the dancer and enter the name on the textbox displayed on the bottom menu",
        "5. Disable/enable dancer label: tap on the person icon with checkmark/xmark",
        "6. Change dancer color: select the color button and select your color",
        "7. Add a formation: select the button with the plus sign",
        "8. Delete a formation: select the button with the delete symbol",
        "9. View transition to next formation: select the button with the > arrow",
        "10. View transition to previous formation: select the button with the < arrow",
        "11. Add music: Select the button with the music and add symbol. After music has been added, the scrubber and play formations with music button will display",
        "12. Play all formations: select the play button",
        "13. Play all formations with music: select tv button with music symbol",
        "14. To change the name of a formation: select the textbook at the right of the formation"]
    var instructions: [String] = []
    var instructionType: InstructionType = .boardInstruct{
        didSet{
            switch instructionType{
            case .boardInstruct:
                instructions = boardInstructions
            case .formInstruct:
                instructions = formInstructions
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: "color-nav") ?? UIColor.white
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "instructionCell", for: indexPath)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.text = instructions[indexPath.row]
        
        
        return cell
    }
}

enum InstructionType{
    case boardInstruct, formInstruct
}
