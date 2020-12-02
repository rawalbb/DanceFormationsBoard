//
//  NotesViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/1/20.
//

import UIKit

protocol NotesUpdatedDelegate{
    func updateNotes(notes: String)
}
class NotesViewController: UIViewController {

    
    @IBOutlet weak var notesTextView: UITextView!
    
    var notes: String?
    var delegate: NotesUpdatedDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.delegate = self
        notesTextView.text = notes

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.delegate != nil {
            if let dataToBeSent = notesTextView.text{
                   self.delegate?.updateNotes(notes: dataToBeSent)
               }
            else{
                print("Error in Sending Notes Data")
            }
    }
        else{
            print("Error in Sending Notes Data")
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
}

extension NotesViewController: UITextViewDelegate{
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"
            {
                textView.resignFirstResponder()
                return false
            }
            return true
    }
}
