//
//  GameViewController+Music.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/22/20.
//

import UIKit
import MediaPlayer

extension GameViewController: MusicChosenDelegate{
    
    func calculateWaitHelper(withMusic: Bool = false) -> Double{
        var wait = 3.0
        guard let next = formationVM.getFormation(type: FormationType.next) else {
            return wait
        }
        guard let curr = formationVM.getFormation(type: FormationType.current) else {
            return wait
        }
        if !withMusic{
                wait = 3.0
            
        }
        if withMusic{
            wait = Double(next.songTime - curr.songTime)
        }
   //go through and set all the wait times, prev + 3 to a certain amount initially when music is loaded
        //when edited, select next song times to be + 3 seconds after
        //when
        return wait
    }
    
    func musicChosen(url: URL) {
        self.musicUrl = url
        self.musicToggleButton.isEnabled = true
        self.musicTimingButton.isEnabled = true
        boardVM.updateBoardSong(songUrl: "\(url)")
        self.setInitialSongTimes()
    }
    
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
            forms.songTime = prevForm?.songTime ?? 0.0 + 3.0
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
