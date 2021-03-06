//
//  BoardViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/28/20.
//

import UIKit

class BoardViewController: KeyViewController {
    
    @IBOutlet weak var boardTableView: UITableView!
    
    var boardVM = BoardViewModel.shared
    var boardVMArray: [Board] = []
    let defaultImageView:UIImageView = UIImageView()
    let defaultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets tableview in inherited class KeyboardViewController
        self.backgroundSV = boardTableView
        
        boardVM.delegate = self
        
        //Sets tableview properties
        boardTableView.register(UINib(nibName: "BoardTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardReusableCell")
        boardTableView.delegate = self
        boardTableView.dataSource = self
        boardTableView.backgroundColor = UIColor.clear
        boardTableView.rowHeight = UITableView.automaticDimension
        //boardTableView.estimatedRowHeight = 120
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Loads boards
        boardVM.loadBoards()
        boardVMArray = boardVM.getBoardArray()
        //**Don't need to call DispatchQueue - check for formations b/c already called from load boards delegate method
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func addBoardPressed(_ sender: UIBarButtonItem) {
        
        boardVM.createNewBoard()
        allBoardUpdates()
        
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
        df.dateFormat = "yyyy-MM-dd"
        
        let cell = self.boardTableView.dequeueReusableCell(withIdentifier: "BoardReusableCell") as! BoardTableViewCell
        
        let board = boardVMArray[indexPath.row]
        
        cell.boardNameTextField.delegate = self
        cell.boardNameTextField.text = board.name
        cell.boardDateTextField.text = "Last Updated: \(df.string(from: board.lastEdited))"
        cell.backgroundColor = UIColor.clear
        
        if let boardImageData = board.image{
            cell.boardImageField.image = ImageDataManager.dataToImage(dataStr: boardImageData)
        }
        else{
            cell.boardImageField.image = UIImage(named: "defaultFormImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BoardTableViewCell
        cell.boardNameTextField.resignFirstResponder()
        
        boardVM.setCurrentBoard(index: indexPath.row)
        let nextVC = storyboard?.instantiateViewController(identifier: "GameViewController") as! GameViewController
        //nextVC.boardVM = boardVM
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func handleMoveToTrash() {
        
        if let toRemove = boardVM.getCurrentBoard(){
            boardVM.removeBoard(board: toRemove)
            allBoardUpdates()
            //Don't need to call checkFormations in DispatchQuueue, already called in delegate method
        }
        else{
            print("Error in Removing Board")
        }
        
    }
    
    private func handleSendBoard() {
        print("Send board pressed")
      
        
        guard
            let sendingBoard = self.boardVM.getCurrentBoard(),
            let url = sendingBoard.exportToURL(name: sendingBoard.name ?? "Heya")
            else { return }
          
          // 2
        
          let activity = UIActivityViewController(
            activityItems: ["Check out this book! I like using Book Tracker.", url],
            applicationActivities: nil
          )

          // 3
          present(activity, animated: true, completion: nil)
        
    }
    
    private func addNotes() {
        let nextVC = storyboard?.instantiateViewController(identifier: "NotesViewController") as! NotesViewController
        nextVC.delegate = self
        nextVC.notes = boardVM.getCurrentBoard()?.notes
        //nextVC.navTitle = boardVM.getCurrentBoard()?.name ?? "Board Notes"
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
        action.backgroundColor = UIColor(hex: "F24E1D")
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
        notes.backgroundColor = UIColor(hex: "09CF84")
        
        // Trash action
        let send = UIContextualAction(style: .normal,
                                      title: "") { [weak self] (action, view, completionHandler) in
            self?.handleSendBoard()
            completionHandler(true)
        }
        
        send.image = UIImage(systemName: "arrowshape.turn.up.right.fill")
        send.backgroundColor = UIColor(hex: "1BBCFE")
        
        return UISwipeActionsConfiguration(actions: [send, notes])
        
    }
    
    
    func checkForNoFormations(){
        
        if boardVM.getBoardArray().count == 0{
            
            defaultImageView.isHidden = false
            defaultLabel.isHidden = false
            boardTableView.isHidden = true
            
            
            defaultImageView.contentMode = UIView.ContentMode.scaleAspectFill
            defaultImageView.frame.size.width = 200
            defaultImageView.frame.size.height = 200
            defaultImageView.center = self.view.center
            
            defaultImageView.image = UIImage(systemName: "plus.rectangle.fill.on.rectangle.fill")
            defaultImageView.tintColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
            view.addSubview(defaultImageView)
            imageViewAnimate(imageView: defaultImageView)
            
            let mid = self.view.center
            defaultLabel.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height/10)
            defaultLabel.center = CGPoint(x: mid.x, y: mid.y + 148)
            defaultLabel.textAlignment = .center
            defaultLabel.text = "No formations yet :/. Select button at top-right to add"
            defaultLabel.textColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
            self.view.addSubview(defaultLabel)
            
        }
        else{
            defaultImageView.isHidden = true
            defaultLabel.isHidden = true
            boardTableView.isHidden = false
            self.boardTableView.reloadData()
        }
    }
    
    func imageViewAnimate(imageView: UIImageView){
        
        let rotate = CGAffineTransform(rotationAngle: -0.2)
        let stretchAndRotate = rotate.scaledBy(x: 0.5, y: 0.5)
        imageView.transform = stretchAndRotate
        imageView.alpha = 0.5
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping:  0.45, initialSpringVelocity: 10.0, options:[.curveEaseOut], animations: {
            imageView.alpha = 1.0
            let rotate = CGAffineTransform(rotationAngle: 0.0)
            let stretchAndRotate = rotate.scaledBy(x: 1.0, y: 1.0)
            imageView.transform = stretchAndRotate
            
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(self.view.frame.size.height * 0.2)
        return self.view.frame.size.height * 0.2
    }

     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.2
    }
    
}


extension BoardViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let updateText = textField.text{
            if updateText != ""{
                boardVM.updateBoardName(boardName: updateText)
                allBoardUpdates()
            }
            else{
                boardVM.updateBoardName(boardName: boardVM.getCurrentBoard()?.name ?? "Board \(String(describing: boardVM.currentBoardIndex))")
                allBoardUpdates()
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 16 characters
        return updatedText.count <= 30
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let cell: UITableViewCell = textField.superview?.superview?.superview as! BoardTableViewCell //TODO: REFACTOR
        let table: UITableView = cell.superview as! UITableView
        let path = table.indexPath(for: cell)
        
        boardVM.setCurrentBoard(index: path?.row ?? 0)
        return true
    }
    
}


extension BoardViewController: BoardUpdatesDelegate{
    
    func boardUpdated(boardArray: [Board]) {
        boardVMArray = boardVM.getBoardArray()
        
        DispatchQueue.main.async {
            self.checkForNoFormations()
        }
    }
}

extension BoardViewController: NotesUpdatedDelegate{
    
    func updateNotes(notes: String) {
        boardVM.updateBoardNotes(notes: notes)
        allBoardUpdates()
    }
}

//TODO: Needs to be updated 
