//
//  InstructionsTableViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 2/5/21.
//

import UIKit

class InstructionsTableViewController: UITableViewController {
    
    
    var instructions: [String] = [
                                  "1. Add a dancer: tap anywhere on the grid, the dancer will be added on that formation only",
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(instructions.count, "Instructions count" )
        return instructions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "instructionCell", for: indexPath)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = instructions[indexPath.row]
       

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
