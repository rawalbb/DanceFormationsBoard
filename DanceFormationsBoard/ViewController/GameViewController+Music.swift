//
//  GameViewController+Music.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/22/20.
//
//
//import UIKit
//import MediaPlayer
//
//extension GameViewController: MusicChosenDelegate{
//    
//    func calculateWaitHelper() -> Double{
//        var wait = 3.0
//        guard let next = formationVM.getFormation(type: FormationType.next) else {
//            return wait
//        }
//        guard let curr = formationVM.getFormation(type: FormationType.next) else {
//            return wait
//        }
//        if !musicToggleButton.isSelected{
//            if next.songTime == 0.0 || curr.songTime == 0.0{
//                wait = 3.0
//            }
//        }
//        else{
//            wait = Double(next.songTime - curr.songTime)
//        }
//   
//        return wait
//    }
//    
//    func musicChosen(url: URL) {
//        self.musicUrl = url
//        self.musicToggleButton.isEnabled = true
//        boardVM.updateBoardSong(songUrl: "\(url)")
//    }
//    
//
//}
//
//extension GameViewController: ScrubberUpdates{
//    func updateFollowingForms() {
//        guard let followingForms = formationVM.getFollowingForms() else { return }
//        for forms in followingForms{
//            forms.songTime = -1.0
//        }
//    }
//    
//    
//    func timeSelected(time: Float) {
//        let songTime = Float(time)
//        formationVM.setSongTime(time: songTime)
//    }
//    
//  
//}
//
//extension GameViewController{
//    
////    func songExists(){
////        var finalSongsArray: [MPMediaItem] = []
////                let mediaItems = MPMediaQuery.songs().items
////                     let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
////        finalSongsArray = mediaCollection.items
////    }
//    
//    
//}
