//
//  MusicViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/7/20.
//

import UIKit
import MediaPlayer
import AVFoundation

protocol MusicChosenDelegate{
    
    func musicChosen(url: URL)
    
}

class MusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet var tableView : UITableView?
    let myTableView: UITableView = UITableView( frame: CGRect.zero, style: .grouped )


    var audio: AVAudioPlayer?
    var finalSongsArray: [MPMediaItem] = []
    var delegate: MusicChosenDelegate? = nil

    override func viewDidLoad() {

        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.title = "Songs"
        
        
        
                let mediaItems = MPMediaQuery.songs().items
                     let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
        finalSongsArray = mediaCollection.items
        print("Final Array", finalSongsArray.count, mediaCollection.items.count)
               // print("mediaCollectionItems: \(String(describing: mediaCollection.items[0].title))") //It's alwa
                if mediaCollection.items.count > 0{
                     let item = mediaCollection.items[0]
                    _ = item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        
        
                //let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Bulleya", ofType: "mp3")!)
        
 
    }
    }


    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int  {

        print("Count", finalSongsArray.count)
        return finalSongsArray.count
    }

    func tableView( _ tableView: UITableView, cellForRowAt indexPath:IndexPath ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MusicPlayerCell",
            for: indexPath) 
        cell.textLabel?.text = finalSongsArray[indexPath.row].title
        print("Text", finalSongsArray[indexPath.row].title)
        //cell.labelMusicTitle?.text = albums[indexPath.section].songs[indexPath.row].songTitle
        //cell.labelMusicDescription?.text = albums[indexPath.section].songs[indexPath.row].artistName
        //let songId: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
        //let item: MPMediaItem = songQuery.getItem( songId: songId )

//        if  let imageSound: MPMediaItemArtwork = item.value( forProperty: MPMediaItemPropertyArtwork ) as? MPMediaItemArtwork {
//            cell.imageMusic?.image = imageSound.image(at: CGSize(width: cell.imageMusic.frame.size.width, height: cell.imageMusic.frame.size.height))
//        }
        return cell;
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return "Header"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Chosen", finalSongsArray[indexPath.row].assetURL)
        if let assetUrl = finalSongsArray[indexPath.row].assetURL{
        self.delegate?.musicChosen(url: assetUrl)
        }
        else{
            print("Error")
        }
        self.dismiss(animated: true, completion: nil)
    }
//   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    let songId: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
//    let item: MPMediaItem = songQuery.getItem( songId: songId )
//    let url: NSURL = item.value( forProperty: MPMediaItemPropertyAssetURL ) as! NSURL
//    do {
//        audio = try AVAudioPlayer(contentsOf: url as URL)
//        guard let player = audio else { return }
//
//        player.prepareToPlay()
//        player.play()
//    } catch let error {
//        print(error.localizedDescription)
//    }
//
//    self.title = albums[indexPath.section].songs[indexPath.row].songTitle
//  }

}
