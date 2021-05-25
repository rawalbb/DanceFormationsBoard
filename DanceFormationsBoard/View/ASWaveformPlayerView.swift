import UIKit
import AVFoundation

protocol TimeDelegate: AnyObject{
    func updateTime(time: Float)
}

public class ASWaveformPlayerView: UIView {
        
    public var normalColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
    
    public var progressColor = UIColor.orange
    
    public var allowSpacing = true
    
    
    //MARK: Private properties
    
    private var playerToken: Any?
    
    public var audioPlayer: AVPlayer!
    
    private var audioAnalyzer = AudioAnalyzer()
    
    private var waveformDataArray = [Float]()
    
    private var waveforms = [CALayer]()
    
    public var currentPlaybackTime: CMTime = CMTimeMake(value: 0, timescale: 1)
    public var  imageThumbnail = #imageLiteral(resourceName: "addMusicIcon")
    private let trackLayer = CALayer()
    //private var mySlider = UISlider()
    public var prevPlaybackTime: CMTime = CMTimeMake(value: 0, timescale: 1)
    
    private var shouldAutoUpdateWaveform = true
    weak var delegate: TimeDelegate?
    
    
    
    //MARK: -
    
    public init(audioURL: URL,
                sampleCount: Int,
                amplificationFactor: Float, prevTime: CMTime, currTime: CMTime) throws {
        
        //Throws error if sample count isn't greater than 0
        guard sampleCount > 0 else {
            throw WaveFormViewInitError.incorrectSampleCount
        }
        
        let rawWaveformDataArray = try audioAnalyzer.analyzeAudioFile(audioURL)
        
        let resampledDataArray = audioAnalyzer.resample(rawWaveformDataArray, to: sampleCount)
        
        waveformDataArray = audioAnalyzer.amplify(resampledDataArray, by: amplificationFactor)
        
        audioPlayer = AVPlayer(url: audioURL)
        
        super.init(frame: .zero)
        prevPlaybackTime = prevTime
        currentPlaybackTime = currTime
        audioPlayer.seek(to: currTime, completionHandler: { [weak self] (_) in
            print("Current Play Back Time when initially seeking", self?.currentPlaybackTime)
            self?.shouldAutoUpdateWaveform = true
        })
        
        self.updateOriginalPlot(prevTime)
        playerToken = audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 60),queue: .main) { [weak self] time in
            //print(self?.mySlider.maximumValue, "Max Val")
            // Update waveform with current playback time value.
            print(CMTimeGetSeconds(time), "observer")
            
            self?.updatePlotWith(time)
        }

        
        // Tap gesture for play - pause support.
        let tapGestureRecornizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecornizer.numberOfTouchesRequired = 1
        tapGestureRecornizer.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecornizer)
        
        // Pan gesture for scrubbing support.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(panGestureRecognizer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        audioPlayer.removeTimeObserver(playerToken!)
        playerToken = nil
        print("\(self) dealloc")
    }
    
    
    //MARK: View Life cycle
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        populateWithData()
        addOverlay()
        
        if audioPlayer.rate == 0{
            // When orientation changes, update plot with currentPlaybackTime value.
            print("Current Playback Time", currentPlaybackTime)
            updatePlotWith(currentPlaybackTime)
        }
    }
    
    //MARK: private
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            shouldAutoUpdateWaveform = false
            
        case .changed:
            let xLocation = Float(recognizer.location(in: self).x)
            
            //Update waveform with translation value
            updatePlotWith(xLocation)
            
        case .ended:
            
            guard let totalAudioDuration = audioPlayer.currentItem?.asset.duration else {
                return
            }
            
            let xLocation = recognizer.location(in: self).x
            
            let percentageInSelf = Double(xLocation / bounds.width)
            
            let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
            
            let scrubbedDutation = totalAudioDurationSeconds * percentageInSelf
            
            var scrubbedDutationMediaTime = CMTimeMakeWithSeconds(scrubbedDutation, preferredTimescale: 1000)
            if scrubbedDutationMediaTime <= prevPlaybackTime{
                scrubbedDutationMediaTime = prevPlaybackTime
            }
            updatePlotWith(scrubbedDutationMediaTime)
            audioPlayer.seek(to: scrubbedDutationMediaTime, completionHandler: { [weak self] (_) in
                self?.shouldAutoUpdateWaveform = true
            })
        default:
            break
        }
    }
    
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if audioPlayer.rate == 0 {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
    }



    @objc func sliderValueChanged(_ sender:UISlider!, event: UIEvent) {

        
        _ = sender.value.rounded()
        guard let touchEvent = event.allTouches?.first else { return }
        
        switch touchEvent.phase {
            
            case .began:
                audioPlayer.pause()
                //print("Began")
                
            case .moved:
                print("Slider moved")

            case .ended:
                guard let totalAudioDuration = audioPlayer.currentItem?.asset.duration else {
                    return
                }
                let roundedValue = sender.value.rounded()

                
                _ = CMTimeGetSeconds(totalAudioDuration)

                
                let scrubbedDutationMediaTime = CMTimeMakeWithSeconds(Float64(roundedValue), preferredTimescale: 1000)
                
                audioPlayer.seek(to: scrubbedDutationMediaTime, completionHandler: { [weak self] (_) in
                    self?.shouldAutoUpdateWaveform = true
                })
                audioPlayer.play()
            default: ()
        }
    }
    
    private func populateWithData() {
        clear()
        
        let barWidth: CGFloat
        if allowSpacing {
            barWidth = bounds.width / CGFloat(waveformDataArray.count) - 0.5
        } else {
            barWidth = bounds.width / CGFloat(waveformDataArray.count)
        }
        
        //Make initial offset equal to half width of bar.
        var offset: CGFloat = (bounds.width / CGFloat(waveformDataArray.count)) / 2
        
        //Iterate through waveformDataArray to calculate size and positions of waveform bars.
        waveformDataArray.forEach { value in
            
            let waveformBarRect = CGRect(x: offset,
                                         y: bounds.height / 2,
                                         width: barWidth,
                                         height: -CGFloat(value))
            
            let barLayer = CALayer()
            barLayer.drawsAsynchronously = true
            barLayer.bounds = waveformBarRect
            
            let x = offset + (bounds.width / CGFloat(waveformDataArray.count)) / 2
            barLayer.position = CGPoint(x: x,
                                        y: bounds.height / 2)
            
            barLayer.backgroundColor = normalColor.cgColor
            
            self.layer.addSublayer(barLayer)
            self.waveforms.append(barLayer)
            
            offset += frame.width / CGFloat(waveformDataArray.count)
        }
    }
    
    private func updatePlotWith(_ location: Float) {
        
        let percentageInSelf = location / Float(bounds.width)
        
        let waveformsToBeRecolored = Float(waveforms.count) * percentageInSelf
        
        for (i, item) in waveforms.enumerated() {
            if i >= 0 && i < lrintf(waveformsToBeRecolored){
            if (0..<lrintf(waveformsToBeRecolored)).contains(i) {
                item.backgroundColor = progressColor.cgColor
            } else {
                item.backgroundColor = normalColor.cgColor
            }
        }
        else{
            
        }
    }
    }
    
    private func updatePlotWith(_ currentTime: CMTime) {
        
        guard shouldAutoUpdateWaveform,
            let totalAudioDuration = audioPlayer.currentItem?.asset.duration else {
                return
        }
        
        let currentTimeSeconds = CMTimeGetSeconds(currentTime)
        print(currentTimeSeconds, "Current Time")
        
        self.currentPlaybackTime = currentTime // Track current time value. This is needed to keep waveform playback progress when device orientaion changes and waveform needs to be redrawn.
        self.delegate?.updateTime(time: Float(currentTimeSeconds))
        let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
        
        let percentagePlayed = currentTimeSeconds / totalAudioDurationSeconds
        
        let waveformBarsToBeUpdated = lrint(Double(waveforms.count) * percentagePlayed)
        
        for (i, item) in waveforms.enumerated() {
            if waveformBarsToBeUpdated > 0{
            if (0..<waveformBarsToBeUpdated).contains(i) {
                item.backgroundColor = progressColor.cgColor
            } else {
                item.backgroundColor = normalColor.cgColor
            }
            }
        }
        
//        DispatchQueue.main.async {
//            self.mySlider.setValue(Float(currentTimeSeconds), animated: true)
//        }

        
    }
    
    private func updateOriginalPlot(_ prevTime: CMTime) {
        
        guard shouldAutoUpdateWaveform,
            let totalAudioDuration = audioPlayer.currentItem?.asset.duration else {
                return
        }
        
        let prevTimeSeconds = CMTimeGetSeconds(prevTime)
        print(prevTimeSeconds, "Previous Time")
        
        //self.currentPlaybackTime = prevTime // Track current time value. This is needed to keep waveform playback progress when device orientaion changes and waveform needs to be redrawn.
        //self.delegate?.updateTime(time: Float(currentTimeSeconds))
        let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
        
        let percentagePlayed = prevTimeSeconds / totalAudioDurationSeconds
        
        let waveformBarsToBeUpdated = lrint(Double(waveforms.count) * percentagePlayed)
        
        for (i, item) in waveforms.enumerated() {
            print("In WaveForms")
            if (0..<waveformBarsToBeUpdated).contains(i) {
                item.backgroundColor = progressColor.cgColor
            } else {
                item.backgroundColor = normalColor.cgColor
            }
        }
    }
    //This function limits it to the small frame
    private func addOverlay() {
        
        let maskLayer = CALayer()
        print(" Self Bounds ", self.bounds)
        maskLayer.frame = self.bounds
        maskLayer.bounds = self.bounds
        print(" Mask Layer.frame ", maskLayer.frame, maskLayer.bounds)
        
        let upperOverlayLayer = CALayer()
        let bottomOverlayLayer = CALayer()
        let uppePrevLayer = CALayer()
        let bottomPrevLayer = CALayer()
        
        upperOverlayLayer.backgroundColor = UIColor.black.cgColor
        bottomOverlayLayer.backgroundColor = UIColor.black.cgColor
        uppePrevLayer.backgroundColor = UIColor.black.cgColor
        bottomPrevLayer.backgroundColor = UIColor.black.cgColor
        
        upperOverlayLayer.opacity = 1
        bottomOverlayLayer.opacity = 1
        uppePrevLayer.opacity = 0.5
        bottomPrevLayer.opacity = 0.5
        
//        maskLayer.addSublayer(upperOverlayLayer)
//        maskLayer.addSublayer(bottomOverlayLayer)
//        maskLayer.addSublayer(uppePrevLayer)
//        maskLayer.addSublayer(bottomPrevLayer)
        
                guard let totalAudioDuration = audioPlayer.currentItem?.asset.duration else {
                    return
                }
        if totalAudioDuration <= CMTime(value: 0, timescale: 1){
            return
        }
                let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
        print("prev playback ", CMTimeGetSeconds(prevPlaybackTime), totalAudioDurationSeconds)
                let percentagePlayed = CMTimeGetSeconds(prevPlaybackTime) / totalAudioDurationSeconds
        //TODO:::: percentage played is NAN
        let prevWidth = maskLayer.bounds.width * CGFloat(percentagePlayed)
        print(" Mask Layer bounds width ", maskLayer.bounds.width, CGFloat(percentagePlayed), " prev width ", prevWidth)
        let remainingWidth = maskLayer.bounds.width - prevWidth
        
        
        let height1 = (maskLayer.bounds.height / 2) - 0.25
        let origin1 = CGPoint(x: prevWidth, y: 0)
        let size1 = CGSize(width: remainingWidth,
                           height: height1)
        
        
        let origin2 = CGPoint(x: prevWidth, y: (maskLayer.bounds.height / 2) + 0.25)
        let size2 = CGSize(width: remainingWidth,
                           height: maskLayer.bounds.height / 2)
        
        print("ORIGIN, SIZE: ", origin1, "  ", size1, origin2, "  ", size2)
        upperOverlayLayer.frame = CGRect(origin: origin1,
                                         size: size1)
        bottomOverlayLayer.frame = CGRect(origin: origin2,
                                          size: size2)
        
        let size3 = CGSize(width: prevWidth, height: height1)
        uppePrevLayer.frame = CGRect(origin: .zero,
                                        size: size3)
        
        let size4 = CGSize(width: prevWidth, height: maskLayer.bounds.height / 2)
        let origin3 = CGPoint(x: 0, y: (maskLayer.bounds.height / 2) + 0.25)
        bottomPrevLayer.frame = CGRect(origin: origin3, size: size4)
        

//         mySlider = UISlider(frame:CGRect(x: bounds.minX, y: 100, width: bounds.width, height: 20))
//                mySlider.minimumValue = 0
//
//        if let duration = audioPlayer.currentItem?.asset.duration{
//            print("Next Changing Max Value")
//            mySlider.maximumValue = Float(CMTimeGetSeconds(duration))
//        }
//
//                mySlider.isContinuous = true
//                mySlider.tintColor = UIColor.orange
//
//        mySlider.addTarget(self, action: #selector(self.sliderValueChanged(_:event:)), for: .allEvents)
//                addSubview(mySlider)
        
        maskLayer.addSublayer(upperOverlayLayer)
        maskLayer.addSublayer(bottomOverlayLayer)
        maskLayer.addSublayer(uppePrevLayer)
        maskLayer.addSublayer(bottomPrevLayer)
        layer.mask = maskLayer
    }

    
    /// Reset progress of playback and waveform
    public func reset() {
        waveforms.forEach {
            $0.backgroundColor = normalColor.cgColor
        }
    }
    
    public func clear() {
        layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        waveforms = []
    }
}

enum WaveFormViewInitError: Error {
    case incorrectSampleCount
}
