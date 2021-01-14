
import Foundation
import UIKit
import SpriteKit
import CoreData
import Firebase


protocol FormUpdatesDelegate{
    
    func formUpdated(formArray: [Formation])
    
}

class FormationViewModel{
    
    var currentIndex: Int? //Initially nil
    var formationArray = [Formation]()
    var danceVM = DancerViewModel()
    var currentBoard: Board!
    var delegate: FormUpdatesDelegate?
    
        var documents: [DocumentSnapshot] = []

        let collection = Firestore.firestore().collection("formations")
        
    func createNewFormation(imageData: Data? = nil){
        
        var newImage: Data? = nil
                if let dataStr = imageData{
                        newImage = dataStr
                    }
                    else{
                        newImage = ImageDataManager.imageToData(image: UIImage(named: "defaultFormImage")!)
                    }
        var uniqueId = UUID().uuidString
        var position = 0
        var formOwnerId = self.getCurrentBoardId()
        
                if formationArray.count > 0 && currentIndex != nil
                {
//                    let dancerObjects = getFormation(type: FormationType.current)?.dancers as! Set<Dancer>
//
//                    for dancer in dancerObjects{
//                        danceVM.addDancer(dancer: dancer, selectedFormation: newFormation)
//                    }
                    //for dancer in dancers that match this formation id...load up only those that match the board id
                    if let currIndex = getCurrentIndex(){
                        position = currIndex + 1
                    }
        
                }
                else{
                    //var dancers = nil
                    position = 0
                }

            
        
            
        let newFormation = Formation(image: newImage, formName: "", position: position, songTime: -1.0, uniqueId: uniqueId, formOwner: formOwnerId)
            
            collection.document("\(uniqueId)").setData(newFormation.dictionary)
                //addDocument(data: newBoard.dictionary)
            
    }

        
        fileprivate func baseQuery() -> Query {
            return Firestore.firestore().collection("danceboards").limit(to: 50)
        }
        
        fileprivate var query: Query? {
            didSet {
                if let listener = listener {
                    listener.remove()
                    loadAllFormations()
                }
            }
        }
        
        private var listener: ListenerRegistration?
        
        
        fileprivate func stopObserving() {
            listener?.remove()
        }
        
        
        func loadAllFormations(){
            
            
            guard let query = query else { return }
            stopObserving()
            
            
            listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot results: \(error!)")
                    return
                }
                let models = snapshot.documents.map { (document) -> Formation in
                    let model = Formation(dictionary: document.data())!
                        return model
                    
                }
                self.formationArray = models
                self.documents = snapshot.documents
                
            }
            // Display data from Firestore, part one
            self.delegate?.formUpdated(formArray: formationArray)
            
        }
    
    func getCurrentBoardId() -> String{
        guard let boardId = BoardViewModel.shared.getCurrentBoard()?.uniqueId else { return "" }
        return boardId
    }
    
    
        func getFormation(type: FormationType) -> Formation?{
            var returnVal: Formation? = nil
            switch type{
    
            case .current:
                if let current = self.getCurrentIndex()
                {
                    returnVal = formationArray[current]
                }
                else{
                    print("Getting Current Formation Error")
                    returnVal = nil
                }
    
            case .previous:
                if let current = self.getCurrentIndex(){
                    if current > 0{
                        returnVal = formationArray[current - 1]
                    }
                    else{
                        returnVal = nil
                    }
                }
    
            case .next:
    
                if let current = self.getCurrentIndex(){
                    if current < formationArray.count - 1{
                        returnVal = formationArray[current + 1]
                    }
                }
                else{
                    returnVal = nil
                }
    
            case .atLocation(let index):
                if index < formationArray.count{
                    returnVal = formationArray[index]
                }
                else{
                    return nil
                }
    
        }
            return returnVal
        }
        
        
        //Function: Get current Board Index
        func getCurrentIndex() -> Int?{
            
            if let index = currentIndex
            {
                return index
            }
            else{
                print("Getting Current Formation Error")
                return nil
            }
        }
        
        //Function: Set current Board
        func setCurrentFormation(index: Int){
            currentIndex = index
        }
        
        

        
        func updateFormImage(imageData: Data?){
            if let index = currentIndex
            {
                formationArray[index].image = imageData
            }
            else{
                print("Error updating board notes")

            }
            
        }
        
    func updateFormName(name: String?){
            if let index = currentIndex
            {
                formationArray[index].formName = name
            }
            else{
                print("Error updating board name")
            }
        }
        
        
        func updateFormSongTime(time: Float?){
            
            var curr = getFormation(type: FormationType.current)
                if curr != nil {
                    curr?.songTime = time
                }

                    
        }
    
    
        func updatePosition(type: PositionType){
            if let curr = getCurrentIndex(){
                let updateStart = curr + 1
            switch type{
    
            case .add:
                for i in updateStart..<formationArray.count{
    
                    formationArray[i].position += 1
                }
                //For each formation greater than "current formation", increase position count
            case .remove:
                for i in updateStart..<formationArray.count{
    
                    formationArray[i].position -= 1
                }
            }
    
        }
        }
    
        func getFollowingForms() -> [Formation]?{
            let filtered = formationArray.filter{ forms in
                guard let index = currentIndex else { return false}
                    return forms.position > index
            }
            return filtered
        }
    
        func updateFormLabel(label: String?){
            
            var curr = getFormation(type: FormationType.current)
                if curr != nil {
                    if label != nil && label != ""{
                    curr?.formName = label
                    }
                    else{
                        curr?.formName = "Enter Name:"
                    }
                }
                    }
    

    
    
    func removeFormation(form: Formation){
        
        if let toUpdateIndex = formationArray.firstIndex(where: {
            $0.uniqueId == form.uniqueId
        }) {
            formationArray.remove(at: toUpdateIndex)
        }
        
    }
    
    func saveToFirebase(){
        
        for forms in formationArray{

        
        collection.document("\(forms.uniqueId)").setData([
            "image" : (forms.image),
            "formName": forms.formName,
            "position": forms.position,
            "songTime": forms.songTime,
            "uniqueId": forms.uniqueId,
            "formOwner": forms.formOwner

        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }

        
    }
    
        
    }
}

enum FormationType{
    
    case current, previous, next, atLocation(Int)
}

enum PositionType{
    
    case add, remove
}
