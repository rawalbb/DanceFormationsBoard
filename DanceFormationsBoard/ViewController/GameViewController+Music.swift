//
//  GameViewController+Music.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/22/20.
//

import UIKit
import MediaPlayer

extension GameViewController: MusicChosenDelegate {

    func musicChosen(url: URL, songName: String) {
                self.musicUrl = url
                self.musicToggleButton.isEnabled = true
                self.musicTimingButton.isEnabled = true
                boardVM.updateBoardSong(songUrl: "\(url)", songName: songName)
                self.setInitialSongTimes()
                stage.musicEnabled = true
    }
    
//    func musicChosen(url: URL) {
//        self.musicUrl = url
//        self.musicToggleButton.isEnabled = true
//        self.musicTimingButton.isEnabled = true
//        boardVM.updateBoardSong(songUrl: "\(url)")
//        self.setInitialSongTimes()
//        stage.musicEnabled = true
//    }
    
    //Should be called when music is first added
    //Should also be called when formationis are - no scratch that
    func setInitialSongTimes(){
        var initial: Float = 0.0
        for formNum in 0..<formationArray.count{
            if let currentForm = formationVM.getFormation(type: .atLocation(formNum)){
                currentForm.songTime = initial
        }
            initial += 3.0
        
        }
        formationVM.saveFormation()
        formationVM.loadFormations()
        
        //TODO: Print to see timings ..withMusic
        for formNum in 0..<formationArray.count{
            if let currentForm = formationVM.getFormation(type: .atLocation(formNum)){
                print(currentForm.songTime)
        }
    }
    
    //Should be called when song time for prev is greater than next formations
    

}
}

extension GameViewController: ScrubberUpdates{
    //Should be called whenever changing prev form to greater song selection
    func updateFollowingForms() {
        guard let followingForms = formationVM.getFollowingForms() else { return }
        for forms in followingForms{
            let prevForm = formationVM.getFormation(type: .atLocation(Int(forms.position) - 1))
            forms.songTime = (prevForm?.songTime ?? 0.0) + 3.0
        }
        
        formationVM.saveFormation()
        formationVM.loadFormations()
    }
    
    
    func timeSelected(time: Float) {
        let songTime = Float(time)
        formationVM.setSongTime(time: songTime)
    }
    
  
}

extension GameViewController{
    
//    func songExists(){
//        var finalSongsArray: [MPMediaItem] = []
//                let mediaItems = MPMediaQuery.songs().items
//                     let mediaCollection = MPMediaItemCollection(items: mediaItems ?? [])
//        finalSongsArray = mediaCollection.items
//    }
    
    
}
