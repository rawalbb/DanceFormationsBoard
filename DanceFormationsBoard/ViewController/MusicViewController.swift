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
    
    func musicChosen(url: URL)
    
}

class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    
    var finalSongsArray: [MPMediaItem] = []
    weak var delegate: MusicChosenDelegate?
    //nil
    
    override func viewDidLoad() {

        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Songs"
        
                let mediaItems = MPMediaQuery.songs().items
                     let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
        finalSongsArray = mediaCollection.items
//                if mediaCollection.items.count > 0{
//                     let item = mediaCollection.items[0]
//                    _ = item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
//
//
//    }
        tableView?.backgroundColor = UIColor.clear

        self.navigationController?.navigationBar.tintColor = UIColor(named: "color-nav")
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

        return "My Music"
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let assetUrl = finalSongsArray[indexPath.row].assetURL{
        self.delegate?.musicChosen(url: assetUrl)
        }
        else{
            print("Error")
        }
        
        //self.dismiss(animated: true, completion: nil)
    }

}
