//
//  MusicViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/7/20.
//

import UIKit
import MediaPlayer
import AVFoundation

protocol MusicChosenDelegate: AnyObject  {
    
    func musicChosen(url: URL, songName: String)
    
}

class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    
    var finalSongsArray: [MPMediaItem] = []
    weak var delegate: MusicChosenDelegate?
    var headerTitle = ""
    var permission: MPMediaLibraryAuthorizationStatus = .notDetermined
    var selectedMusicButton: UIBarButtonItem?
    var musicUrl: URL? = nil
    var songName: String = ""
    //nil
    
    override func viewDidLoad() {

        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Songs"
        
//                let mediaItems = MPMediaQuery.songs().items
//                     let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
//        finalSongsArray = mediaCollection.items
//                if mediaCollection.items.count > 0{
//                     let item = mediaCollection.items[0]
//                    _ = item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
//
//
//    }
        
        //let authorizationStatus = MPMediaLibrary.authorizationStatus()
        self.selectedMusicButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(musicSelected))
        self.navigationItem.setRightBarButton(selectedMusicButton, animated: true)
        self.selectedMusicButton?.isEnabled = false
        
        tableView?.backgroundColor = UIColor.clear

        self.navigationController?.navigationBar.tintColor = UIColor(named: "color-nav")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MPMediaLibrary.requestAuthorization { (stat) in
            switch stat{
            case .authorized:
                self.permission = stat
                print("Authorized")
                let mediaItems = MPMediaQuery.songs().items
                     let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
                self.finalSongsArray = mediaCollection.items
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            
            case .restricted:
                self.permissionNotGrantedAlert()
                self.permission = stat
            case .notDetermined:
                self.permission = stat
                self.permissionNotGrantedAlert()
            case .denied:
                self.permission = stat
                self.permissionNotGrantedAlert()
            @unknown default:
                self.permission = stat
                self.permissionNotGrantedAlert()
            }
        }
    }
    @objc func musicSelected(){
        if let musicUrl = self.musicUrl{
        self.delegate?.musicChosen(url: musicUrl, songName: songName)
            self.navigationController?.popViewController(animated: true)
        }
        else{
            print("Error selecting music")
        }
        }
    
    func permissionNotGrantedAlert(){
        DispatchQueue.main.async {
        let alert = UIAlertController(title: "Permissions", message: "Please toggle on Media & Apple Music access in Settings",         preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Continue",
                                      style: UIAlertAction.Style.default,
                                              handler: {(_: UIAlertAction!) in
                }))
           
            self.present(alert, animated: true, completion: nil)
        }
    }

    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int  {

        return finalSongsArray.count
    }

    func tableView( _ tableView: UITableView, cellForRowAt indexPath:IndexPath ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MusicPlayerCell",
            for: indexPath)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = finalSongsArray[indexPath.row].title
        cell.selectedBackgroundView?.backgroundColor = UIColor(named: "color-heading")

        return cell;
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard permission == .authorized else {
            return "Media Permission Denied"
        }
        
        if finalSongsArray.count == 0{
            return "No music in library"
        }
        else {
        return "My Music"
        }
    }


    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMusicButton?.isEnabled = true
        if let assetUrl = finalSongsArray[indexPath.row].assetURL{
            self.musicUrl = assetUrl
            self.songName = finalSongsArray[indexPath.row].title ?? ""
        
        //self.dismiss(animated: true, completion: nil)
    }
        
        

}
}
