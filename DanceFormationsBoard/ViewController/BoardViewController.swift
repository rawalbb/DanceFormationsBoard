//
//  BoardViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/28/20.
//

import UIKit
import GoogleMobileAds

class BoardViewController: KeyViewController {
    
    @IBOutlet weak var boardTableView: UITableView!
    
    var boardVM = BoardViewModel.shared
    var boardVMArray: [Board] = []
    let defaultImageView:UIImageView = UIImageView()
    let defaultLabel = UILabel()
    var interstitialo: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets tableview in inherited class KeyboardViewController
        self.backgroundSV = boardTableView
        
        
        //Sets tableview properties
        boardTableView.register(UINib(nibName: "BoardTableViewCell", bundle: nil), forCellReuseIdentifier: "BoardReusableCell")
        boardTableView.delegate = self
        boardTableView.dataSource = self
        boardTableView.backgroundColor = UIColor.clear
        boardTableView.rowHeight = UITableView.automaticDimension
        
        boardVM.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        boardVM.loadBoards()
        //**check for formations b/c already called from load boards delegate method
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createAd()
    }
    
    @IBAction func addBoardPressed(_ sender: UIBarButtonItem) {
        
        boardVM.createNewBoard()
        allBoardUpdates()
        
    }
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        let nextVC = storyboard?.instantiateViewController(identifier: "InstructionsTableViewController") as! InstructionsTableViewController
        nextVC.instructionType = .boardInstruct
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    func allBoardUpdates(){
        
        boardVM.saveBoard()
        boardVM.loadBoards()
    }
    
    private func createAd(){
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: Constants.viewAdId,
                                        request: request,
                              completionHandler: { [self] ad, error in
                                if let error = error {
                                  print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                  return
                                }
                                interstitialo = ad
                                //interstitial?.fullScreenContentDelegate = self
                              }
            )
        

    }
    
}


extension BoardViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boardVMArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        
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
        print("Set Current Board ", indexPath.row)
        
        switch cell.stageTypeSegmentedControl.selectedSegmentIndex
        {
        case 0:
            let nextVC = storyboard?.instantiateViewController(identifier: "GameViewController") as! GameViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 1:
            let nextVC = storyboard?.instantiateViewController(identifier: "SceneKitViewController") as! SceneKitViewController
            nextVC.interstitial = interstitialo
            nextVC.interstitial?.fullScreenContentDelegate = nextVC
            //boardVM.setCurrentBoard(index: indexPath.row)
            
            
            
            self.navigationController?.pushViewController(nextVC, animated: true)
        default:
            break
        }
        
    }
    
    private func handleMoveToTrash() {
        
        guard let toRemove = boardVM.getCurrentBoard() else { print("Error removing board")
            return }
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this dance board?",  preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
                                              handler: { (_: UIAlertAction!) in
                }))
        
        
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: UIAlertAction.Style.default,
                                              handler: { [weak self] (_: UIAlertAction!) in
                                                
                                                self?.boardVM.removeBoard(board: toRemove)
                                                self?.allBoardUpdates()
                }))
           
            self.present(alert, animated: true, completion: nil)
        
    }
    
    private func handleSendBoard() {
        
        guard
            let sendingBoard = self.boardVM.getCurrentBoard(),
            let url = sendingBoard.exportToURL(name: sendingBoard.name ?? "DanceBoard")
        else { return }
        
        let activity = UIActivityViewController(
            activityItems: ["Check out this Dance Formation Board!", url],
            applicationActivities: nil
        )
        
        activity.excludedActivityTypes = [.openInIBooks, .markupAsPDF, .addToReadingList, .assignToContact, .postToFlickr, .postToTencentWeibo, .copyToPasteboard ]
        present(activity, animated: true, completion: nil)
        
    }
    
    private func addNotes() {
        let nextVC = storyboard?.instantiateViewController(identifier: "NotesViewController") as! NotesViewController
        nextVC.delegate = self
        nextVC.notes = boardVM.getCurrentBoard()?.notes
        nextVC.navTitle = boardVM.getCurrentBoard()?.name ?? "Board Notes"
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
            defaultImageView.tintColor = UIColor(named: "color-nav")
            view.addSubview(defaultImageView)
            imageViewAnimate(imageView: defaultImageView)
            
            let mid = self.view.center
            defaultLabel.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height/10)
            defaultLabel.center = CGPoint(x: mid.x, y: mid.y + 148)
            defaultLabel.textAlignment = .center
            defaultLabel.text = "No DanceBoards created yet. Select button at top-left to add"
            defaultLabel.textColor = UIColor(named: "color-nav")
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
        return updatedText.count <= 24
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
        boardVMArray = boardArray
        
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
