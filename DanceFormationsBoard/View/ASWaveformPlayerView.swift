import UIKit
import AVFoundation

protocol TimeDelegate{
    func updateTime(time: Float64)
}

public class ASWaveformPlayerView: UIView {
        
    public var normalColor = #colorLiteral(red: 0.7568627451, green: 0.8392156863, blue: 0.8980392157, alpha: 1)
    
    public var progressColor = UIColor.orange
    
    public var allowSpacing = true
    
    
    //MARK: Private properties
    
    private var playerToken: Any?
    
    private var audioPlayer: AVPlayer!
    
    private var audioAnalyzer = AudioAnalyzer()
    
    private var waveformDataArray = [Float]()
    
    private var waveforms = [CALayer]()
    
    private var currentPlaybackTime: CMTime?
    
    private var shouldAutoUpdateWaveform = true
    var delegate: TimeDelegate?
    
    
    
    //MARK: -
    
    public init(audioURL: URL,
                sampleCount: Int,
                amplificationFactor: Float) throws {
        
        //Throws error if sample count isn't greater than 0
        guard sampleCount > 0 else {
            throw WaveFormViewInitError.incorrectSampleCount
        }
        
        let rawWaveformDataArray = try audioAnalyzer.analyzeAudioFile(audioURL)
        
        let resampledDataArray = audioAnalyzer.resample(rawWaveformDataArray, to: sampleCount)
        
        waveformDataArray = audioAnalyzer.amplify(resampledDataArray, by: amplificationFactor)
        
        audioPlayer = AVPlayer(url: audioURL)
        
        super.init(frame: .zero)
        
        playerToken = audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 60),queue: .main) { [weak self] time in
            
            // Update waveform with current playback time value.
            
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
        
        if audioPlayer.rate == 0 && currentPlaybackTime != nil {
            // When orientation changes, update plot with currentPlaybackTime value.
            updatePlotWith(currentPlaybackTime!)
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
            
            let scrubbedDutationMediaTime = CMTimeMakeWithSeconds(scrubbedDutation, preferredTimescale: 1000)
            
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
        
        self.currentPlaybackTime = currentTime // Track current time value. This is needed to keep waveform playback progress when device orientaion changes and waveform needs to be redrawn.
        self.delegate?.updateTime(time: currentTimeSeconds)
        let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
        
        let percentagePlayed = currentTimeSeconds / totalAudioDurationSeconds
        
        let waveformBarsToBeUpdated = lrint(Double(waveforms.count) * percentagePlayed)
        
        for (i, item) in waveforms.enumerated() {
            
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
        maskLayer.frame = bounds
        
        let upperOverlayLayer = CALayer()
        let bottomOverlayLayer = CALayer()
        
        upperOverlayLayer.backgroundColor = UIColor.black.cgColor
        bottomOverlayLayer.backgroundColor = UIColor.black.cgColor
        
        upperOverlayLayer.opacity = 1
        bottomOverlayLayer.opacity = 0.75
        
        maskLayer.addSublayer(upperOverlayLayer)
        maskLayer.addSublayer(bottomOverlayLayer)
        
        let height1 = (maskLayer.bounds.height / 2) - 0.25
        let size1 = CGSize(width: maskLayer.bounds.width,
                           height: height1)
        upperOverlayLayer.frame = CGRect(origin: .zero,
                                         size: size1)
        
        let origin2 = CGPoint(x: 0, y: (maskLayer.bounds.height / 2) + 0.25)
        let size2 = CGSize(width: maskLayer.bounds.width,
                           height: maskLayer.bounds.height / 2)
        bottomOverlayLayer.frame = CGRect(origin: origin2,
                                          size: size2)
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
