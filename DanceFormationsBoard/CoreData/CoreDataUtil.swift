//
//  CoreDataUtil.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 11/4/20.
//

import CoreData
import UIKit

class CoreDataUtil{
    
    private let appDelegate: AppDelegate
    let managedObjectContext: NSManagedObjectContext
    //let rootURL: URL
    //let manifestPath: String
    
    static let shared = CoreDataUtil()
    
    private init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        //manifestPath = (NetworkManager.shared?.getPath(of: "manifest"))!
    }
    
    
    
//    public func get<T: NSManagedObject>(
//        id: Int64? = nil,
//        fieldName: String = "id"
//    ) -> T? {
//        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
//        if let id = id {
//            fetchRequest.predicate = NSPredicate(format: "\(fieldName) == %ld", id)
//        }
//        return (try? managedObjectContext.fetch(fetchRequest))?.first
//    }
}
