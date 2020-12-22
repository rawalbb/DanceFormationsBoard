//
//  ViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/14/20.
//

import UIKit

class ViewController: UIViewController {

    var wformView: ASWaveformPlayerView!
    let timeLabel = UILabel()

    let audioURL = Bundle.main.url(forResource: "Chand", withExtension: "mp3")!

    override func viewDidLoad() {
        super.viewDidLoad()


        do {
            try initWaveformPlayerView(audioURL)
            wformView.delegate = self
        } catch {
            print(error.localizedDescription)
        }

        view.addSubview(wformView)
        wformView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
                timeLabel.frame = CGRect(x: 150, y: 150, width: 100, height: 32)
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

        wformView = try ASWaveformPlayerView(audioURL: url,
                                             sampleCount: 1024,
                                             amplificationFactor: 500)

        wformView.normalColor = .lightGray
        wformView.progressColor = .orange
        wformView.allowSpacing = true
    }
}


//class ViewController: UIViewController {
    
//    let myView = UIView()
//    let myScroll = UIScrollView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        myScroll.translatesAutoresizingMaskIntoConstraints = false
//        myScroll.backgroundColor = .cyan
//        view.addSubview(myScroll)
//
//        NSLayoutConstraint.activate([
//            myScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
//            myScroll.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
//            myScroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            myScroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
//        ])
//
//        addView(myView, to: myScroll, color: .red, leading: 10, trailing: -10, top: 10, bottom: -10)
//    }
//
//    func addView(_ addedView: UIView, to superview: UIView, color: UIColor, leading: CGFloat, trailing: CGFloat, top: CGFloat, bottom: CGFloat) {
//
//        superview.addSubview(addedView)
//        addedView.translatesAutoresizingMaskIntoConstraints = false
//        addedView.backgroundColor = color
//
//        // these dictate the `contentSize` of the scroll view relative to the subview
//
//        NSLayoutConstraint.activate([
//            addedView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading),
//            addedView.topAnchor.constraint(equalTo: superview.topAnchor, constant: top),
//            addedView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing),
//            addedView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom)
//        ])
//
//        // these define the size of the `addedView`
//
//        NSLayoutConstraint.activate([
//            addedView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2.5),
//            addedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
//        ])
//    }
    
    
    
    

//    var wformView: ASWaveformPlayerView!
//      let myScroll = UIScrollView()
//    let soundLabel = UILabel()
//    let audioURL = Bundle.main.url(forResource: "Chand", withExtension: "mp3")!
//
//    override func viewDidLoad() {
//
//
//        super.viewDidLoad()
//              myScroll.translatesAutoresizingMaskIntoConstraints = false
//    myScroll.backgroundColor = .cyan
//    view.addSubview(myScroll)
//        view.addSubview(soundLabel)
//        soundLabel.backgroundColor = .red
//        do {
//            try initWaveformPlayerView(audioURL)
//            wformView.delegate = self
//        } catch {
//            print(error.localizedDescription)
//        }
//
//    NSLayoutConstraint.activate([
//        myScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 200),
//        myScroll.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -200),
//        myScroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
//        myScroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
//    ])
//        soundLabel.frame = CGRect(x: 150, y: 150, width: 100, height: 20)
//        soundLabel.textColor = UIColor.black
//        soundLabel.font = UIFont(name: "Helvetica", size: 20.0)
//    addView(wformView, to: myScroll, color: .white, leading: 10, trailing: -10, top: 10, bottom: -10)
//
//
//        //view.addSubview(wformView)
//        //wformView.translatesAutoresizingMaskIntoConstraints = false
//
//        let safeArea = view.safeAreaLayoutGuide
//
////        let constrs = [
////            wformView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
////            wformView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
////            wformView.heightAnchor.constraint(equalToConstant: 128),
////            wformView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
////            wformView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
////        ]
////        NSLayoutConstraint.activate(constrs)
//    }
//
//    private func initWaveformPlayerView(_ url: URL) throws {
//
//        wformView = try ASWaveformPlayerView(audioURL: url,
//                                             sampleCount: 1024,
//                                             amplificationFactor: 500)
//
//        wformView.normalColor = .lightGray
//        wformView.progressColor = .orange
//        wformView.allowSpacing = false
//    }
//
//
//    func addView(_ addedView: UIView, to superview: UIView, color: UIColor, leading: CGFloat, trailing: CGFloat, top: CGFloat, bottom: CGFloat) {
//
//        superview.addSubview(addedView)
//        addedView.translatesAutoresizingMaskIntoConstraints = false
//        addedView.backgroundColor = color
//
//        // these dictate the `contentSize` of the scroll view relative to the subview
//
//        NSLayoutConstraint.activate([
//            addedView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading),
//            addedView.topAnchor.constraint(equalTo: superview.topAnchor, constant: top),
//            addedView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing),
//            addedView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom)
//        ])
//
//        // these define the size of the `addedView`
//
//                NSLayoutConstraint.activate([
//                    addedView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
//                    addedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
//                ])
//    }
//}
//

//
//
//
//

extension ViewController: TimeDelegate{
    func updateTime(time: Float64) {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.minute, .second]
        dcf.unitsStyle = .positional
        dcf.zeroFormattingBehavior = .pad
        let string = dcf.string(from: TimeInterval(time))
        timeLabel.text = string
    }
}
