//
//  FormationBoardViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/28/20.
//

import UIKit

class FormationBoardViewController: UIViewController {
    
    
    
    @IBOutlet weak var boardsCollectionView: UICollectionView!
    
    var boardVM = FormationBoardViewModel()
    var boardVMArray: [FormationBoard] = []
    var lastSelectedIndexPath:IndexPath?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardsCollectionView.delegate = self
        boardsCollectionView.dataSource = self
        
        boardVMArray = boardVM.loadBoards()
        boardVM.delegate = self
        self.registerNib()
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
        boardVMArray = boardVM.getBoardArray()
        boardsCollectionView.reloadData()
        
    }
    

}

// MARK: Formation Board Collection View
extension FormationBoardViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.reuseIdentfier, for: indexPath) as! BoardCollectionViewCell
        
        let item = boardVMArray[indexPath.row]
        if let formationData = item.image{
            let cellImage = UIImage(data: formationData)
            cell.boardImage.image = cellImage
        }
        
        cell.boardTextField.text = item.name
        cell.boardTextField.delegate = self
        cell.boardTextField.tag = indexPath.row
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardVMArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //if selected item is equal to current selected item, ignore it
        guard lastSelectedIndexPath != indexPath else {
            return
        }
        
        if lastSelectedIndexPath != nil {
            collectionView.deselectItem(at: lastSelectedIndexPath!, animated: false)
        }
        boardVM.setCurrentBoard(index: indexPath.row)
        print("Selected:\(indexPath)")
        let selectedCell = collectionView.cellForItem(at: indexPath) as! BoardCollectionViewCell
        selectedCell.isSelected = true
        lastSelectedIndexPath = indexPath
    }

    
    func registerNib() {
        let nib = UINib(nibName: BoardCollectionViewCell.nibName, bundle: nil)
        boardsCollectionView.register(nib, forCellWithReuseIdentifier: BoardCollectionViewCell.reuseIdentfier)
    }
    
    

    }


extension FormationBoardViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if let updateText = textField.text{
            if updateText != "" {
            boardVM.updateBoardName(boardName: updateText)
            }
            else{
                boardVM.updateBoardName(boardName: "Board \(boardVM.currentBoardIndex)")
            }
        }

        //boardsCollectionView.reloadData()


        textField.resignFirstResponder()
        view.frame.origin.y = 0
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        print("tag", textField.tag)
        boardVM.setCurrentBoard(index: textField.tag)
      return true
    }
    
        @objc func keyboardWillChange(notification: Notification) {
            view.frame.origin.y = -100 //TODO:
        }
    
}


extension FormationBoardViewController: BoardUpdatesDelegate{
    
    func boardUpdated(boardArray: [FormationBoard]) {
        self.boardVMArray = boardArray
        print("In Board Updated")
        DispatchQueue.main.async {
            self.boardsCollectionView.reloadData()
        }
    }
}
