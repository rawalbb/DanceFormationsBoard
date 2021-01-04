//
//  ViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/14/20.
//

import UIKit
import AVFoundation

protocol ScrubberUpdates{
    func timeSelected(time: Float)
    func updateFollowingForms()
}


class ViewController: UIViewController {

    var wformView: ASWaveformPlayerView!
    let timeLabel = UILabel()
    var delegate: ScrubberUpdates? = nil
    var currSongTiming: Float?
    var prevSongTiming: Float?
    var nextSongTiming: Float?
    var audioURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()


        do {
            if let audioUrl = audioURL{
            try initWaveformPlayerView(audioUrl)
            wformView.delegate = self
            }
        } catch {
            print(error.localizedDescription)
        }

        view.addSubview(wformView)
//        wformView.addTarget(self, action: #selector(rangeSliderValueChanged(_:)),
//                              for: .valueChanged)
        wformView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
                timeLabel.frame = CGRect(x: 350, y: 150, width: 100, height: 32)
                timeLabel.textColor = UIColor.white
                timeLabel.font = UIFont(name: "Helvetica", size: 28)
        let safeArea = view.safeAreaLayoutGuide

        let constrs = [
            wformView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            wformView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            wformView.heightAnchor.constraint(equalToConstant: 128),
            wformView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            wformView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constrs)

    }

    private func initWaveformPlayerView(_ url: URL) throws {
        var prevTiming: CMTime
        var currTiming: CMTime
        if let prev = prevSongTiming{
            prevTiming = CMTimeMake(value: Int64(prev), timescale: 1)
            
        }
        else{
            prevTiming = CMTimeMake(value: 0, timescale: 1)
        }
        if let curr = currSongTiming{
            currTiming = CMTimeMake(value: Int64(curr), timescale: 1)
        }
        else{
            currTiming = CMTimeMake(value: 0, timescale: 1)
        }
        print("Previous Time ", CMTimeGetSeconds(prevTiming))
        wformView = try ASWaveformPlayerView(audioURL: url,
                                             sampleCount: 1024,
                                             amplificationFactor: 500, prevTime: prevTiming, currTime: currTiming)

        wformView.normalColor = .lightGray
        wformView.progressColor = .orange
        wformView.allowSpacing = false


        
    }
    
    func showSimpleAlert() {
        let alert = UIAlertController(title: "Scrubber", message: "Current formation start time exceeds next formation start time. Select Continue to set the following formation times to default",         preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            }))
        
        alert.addAction(UIAlertAction(title: "Continue",
                                      style: UIAlertAction.Style.default,
                                              handler: {(_: UIAlertAction!) in
                                                //Sign out action
                                                //TODO
                                                self.delegate?.updateFollowingForms()
                }))
           
            self.present(alert, animated: true, completion: nil)
        }
    
    @IBAction func timingSelectedPressed(_ sender: UIBarButtonItem) {
        
        if prevSongTiming == nil && nextSongTiming == nil{
            self.delegate?.timeSelected(time: self.currSongTiming ?? 0.0)
            self.navigationController?.popViewController(animated: true)
            //self.dismiss(animated: true, completion: nil)
        }
        else if prevSongTiming != nil && nextSongTiming == nil{
            if let curr = currSongTiming, let prev = prevSongTiming{
                if prev < curr{
                    self.delegate?.timeSelected(time: curr)
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    print("Cannot close VC, timing not valid, prev")
                }
            }
        }
        else if prevSongTiming == nil && nextSongTiming != nil {
            if let curr = currSongTiming, let next = nextSongTiming{
                if curr < next{
                    self.delegate?.timeSelected(time: curr)
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    print("Cannot close VC, timing not valid, enxt")
                }
            }
        }
        else{
            if let curr = currSongTiming, let prev = prevSongTiming, let next = nextSongTiming{
                if curr < next && prev < curr{
                    self.delegate?.timeSelected(time: curr)
                    self.navigationController?.popViewController(animated: true)
                }
                else if prev < curr && curr > next{
                    self.showSimpleAlert()
                }
                else{
                    print("Cannot close VC, timing not valid both present")
                }
            }
        }
//        if prevSongTiming == nil && nextSongTiming != nil{
////            if currSongTiming < nextSongTiming{
////                //trigger method where it sets all remaining formations to default 3.0 seconds
////            }
//            //else save timing and dismiss
//        }
//        if prevSongTiming != nil && nextSongTiming == nil{
//            //if currsongtiming > prevsongtiming{
//            //trigger warning message
//
//        //}
//        }
   
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        wformView.audioPlayer.pause()
    }
    
}


extension ViewController: TimeDelegate{
    func updateTime(time: Float) {
        //print("Updating Timing")
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.minute, .second]
        dcf.unitsStyle = .positional
        dcf.zeroFormattingBehavior = .pad
        let string = dcf.string(from: TimeInterval(time))
        DispatchQueue.main.async {
            self.timeLabel.text = string
        }
        currSongTiming = Float(time)
        
    }
}
