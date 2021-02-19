//
//  InstructionsTableViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 2/5/21.
//

import UIKit

class InstructionsTableViewController: UITableViewController {
    

    var instructions: [String] = [
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
