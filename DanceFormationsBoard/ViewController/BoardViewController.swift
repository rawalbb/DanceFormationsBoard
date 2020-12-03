//
//  BoardViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/28/20.
//

import UIKit

class BoardViewController: UIViewController {
    
    
    @IBOutlet weak var boardTableView: UITableView!
    
    
    var boardVM = FormationBoardViewModel()
    var boardVMArray: [FormationBoard] = []
    var lastSelectedIndexPath:IndexPath?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        boardVMArray = boardVM.loadBoards()
        boardVM.delegate = self
        
        boardTableView.register(UINib(nibName: "BoardTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardReusableCell")
        boardTableView.delegate = self
        boardTableView.dataSource = self
        
        boardTableView.rowHeight = UITableView.automaticDimension
        boardTableView.estimatedRowHeight = 120

        // Do any additional setup after loading the view.
        
        
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
                       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
                       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
                
                }
            
            deinit {
                 NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
                 NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
                 NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
             }
    
    override func viewWillAppear(_ animated: Bool) {
        boardVM.loadBoards()
        //Added so that when Board View Controller is loaded back up, it loads the pictures on the tableview
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func addBoardPressed(_ sender: UIBarButtonItem) {
        
        boardVM.createNewBoard()
        allBoardUpdates()
        //boardVMArray = boardVM.getBoardArray()
        //boardsCollectionView.reloadData()
        
//        let alert = UIAlertController(title: "Name Your Dance Board",
//                                message: nil,
//                                preferredStyle: .alert)
//
//                alert.view.tintColor = UIColor.brown            // change text color of the buttons
//                alert.view.backgroundColor = UIColor.lightGray  // change background color
//                alert.view.layer.cornerRadius = 25              // change corner radius
//
//                alert.addTextField { (textField: UITextField) in
//                    textField.keyboardAppearance = .dark
//                    textField.keyboardType = .default
//                    textField.autocorrectionType = .default
//                    textField.placeholder = "Board Name"
//                }
//
//        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] action in
//                    let brandName = alert.textFields![0]
//            self?.boardVM.createNewBoard()
////            self?.boardVMArray = self?.boardVM.getBoardArray()
////            self?.boardTableView.reloadData()
//                    print("Great! Let's Play with \(brandName.text!)!")
//
//                }))
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//                    print("Time to head home!")}))
//
//                self.present(alert, animated: true)
//
        
        
    }
    
    func allBoardUpdates(){
        
        boardVM.saveBoard()
        boardVM.loadBoards()
    }
    
    


}


extension BoardViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boardVMArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let cell = self.boardTableView.dequeueReusableCell(withIdentifier: "BoardReusableCell") as! BoardTableViewCell
        cell.boardNameTextField.text = boardVMArray[indexPath.row].name
        cell.boardDateTextField.text = "Last Updated: \(df.string(from: boardVMArray[indexPath.row].lastEdited))"
        
        if let subForm = boardVMArray[indexPath.row].subFormations?.allObjects as? [Formation]{
        if subForm.count != 0{
            if let a = subForm[0].image{
            cell.boardImageField.image = UIImage(data: a)
                cell.boardImageField.layer.borderWidth = 4
                cell.boardImageField.layer.borderColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
            }
        }
        else{
            cell.boardImageField.image = #imageLiteral(resourceName: "defaultFormImage")
        }
        
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        boardVM.setCurrentBoard(index: indexPath.row)
        let nextVC = storyboard?.instantiateViewController(identifier: "GameViewController") as! GameViewController
        nextVC.boardVM = boardVM
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func handleMoveToTrash() {
        
        if let toRemove = boardVM.getCurrentBoard(){
            boardVM.removeBoard(board: toRemove)
            allBoardUpdates()
        }
        else{
            print("Error in Removing Board")
        }
        
//        let alert = UIAlertController(title: "Are you sure you want to delete this Board?",
//                                    message: "",
//                                    preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
//                                        if let toRemove = self?.boardVM.getCurrentBoard(){
//                                            self?.boardVM.removeBoard(board: toRemove)
//                                        }
//                                        else{
//                                            print("Error in Removing Board")
//                                        }}))
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
//            print("Time to head home!")}))
//
//        self.present(alert, animated: true)
//
    }
        
    
    
    
    private func handleMarkAsFavourite() {
        print("Marked as favourite")
    }

    private func handleMarkAsUnread() {
        print("Marked as unread")
    }

    private func addNotes() {
        let nextVC = storyboard?.instantiateViewController(identifier: "NotesViewController") as! NotesViewController
        nextVC.delegate = self
        nextVC.notes = boardVM.getCurrentBoard()?.notes
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        boardVM.setCurrentBoard(index: indexPath.row)
        
        let action = UIContextualAction(style: .destructive,
                                        title: "") { [weak self] (action, view, completionHandler) in
                                            self?.handleMoveToTrash()
                                            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        boardVM.setCurrentBoard(index: indexPath.row)
        let notes = UIContextualAction(style: .normal,
                                         title: "Add Notes") { [weak self] (action, view, completionHandler) in
                                            self?.addNotes()
                                            completionHandler(true)
        }
        notes.backgroundColor = .systemGreen

        // Trash action
        let send = UIContextualAction(style: .normal,
                                       title: "") { [weak self] (action, view, completionHandler) in
            self?.handleMarkAsFavourite()
                                        completionHandler(true)
        }
        //send.image = UIImage(systemName: <#T##String#>)
        send.backgroundColor = .systemPink

        let configuration = UISwipeActionsConfiguration(actions: [send, notes])

        return configuration
    }
    
    
    
    
}




extension BoardViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if let updateText = textField.text{
            if updateText != "" {
            boardVM.updateBoardName(boardName: updateText)
            allBoardUpdates()
            }
            else{
                boardVM.updateBoardName(boardName: "Board \(boardVM.currentBoardIndex)")
                allBoardUpdates()
            }
        }

        //boardsCollectionView.reloadData()


        textField.resignFirstResponder()
        view.frame.origin.y = 0
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        boardVM.setCurrentBoard(index: textField.tag)
//        let pointInTable = textField.convert(textField.bounds.origin, to: self.boardsCollectionView)
//        let textFieldIndexPath = self.boardsCollectionView.indexPathForItem(at: pointInTable)
//
//        //boardsCollectionView.deselectItem(at: lastSelectedIndexPath ?? IndexPath(row: 0, section: 0), animated: true)
//
//        //lastSelectedIndexPath = IndexPath(row: boardVM.currentBoardIndex, section: 0)
//        boardsCollectionView.selectItem(at: textFieldIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        
      return true
    }
    
        @objc func keyboardWillChange(notification: Notification) {
            //view.frame.origin.y = -100 //TODO:
        }
    
}


extension BoardViewController: BoardUpdatesDelegate{
    
    func boardUpdated(boardArray: [FormationBoard]) {
        //self.boardVMArray = boardArray
        boardVMArray = boardVM.getBoardArray()
        DispatchQueue.main.async {
            self.boardTableView.reloadData()
        }
    }
}

extension BoardViewController: NotesUpdatedDelegate{
    
    func updateNotes(notes: String) {
        boardVM.updateBoardNotes(notes: notes)
        allBoardUpdates()
    }
}
