//
//  BTPlayerView.swift
//  PortalHdafHyomi
//
//  Created by Binyamin Trachtman on 01/08/2016.
//
//

import UIKit
import AVFoundation
import MediaPlayer

protocol BTPlayerViewDelegate: class {
    
    func didPause(player:BTPlayerView)
    func didPlay(player:BTPlayerView)
    func playerLoadingStatusChanged(player:BTPlayerView, isLoading:Bool)
    func playerView(_ player:BTPlayerView, didChangeDuration duration:Int)
    func didFinishPlaying(_ player:BTPlayerView)
}

class BTPlayerView: UIView,IPlayerProtocolDelegate, BTPlayerRateSpeedViewDelegate {
    
    weak var delegate: BTPlayerViewDelegate?
    
    @IBOutlet weak var iconImageView:UIImageView?
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var pauseButton:UIButton!
    @IBOutlet weak var loadingActivityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var subTitleLabel:UILabel?
    @IBOutlet weak var progressSlider:UISlider!
    @IBOutlet weak var timePassedLabel:UILabel!
    @IBOutlet weak var timeLeftLabel:UILabel!
    @IBOutlet weak var errorLabel:UILabel!
    
    @IBOutlet weak var rateSpeedButton:UIButton?
    
    @IBOutlet weak var jumpForwardButton:UIButton?
    @IBOutlet weak var jumpBackButton:UIButton?
    
    var onReadyToPlay:(() -> Void)?
    var onLessonNotFound:(() -> Void)?
    
    var isPaused = false
    var isloading = false
    var startAutomatically = false
    
    var isPlaying:Bool{
        get{
            return self.player.isPlaying()
        }
    }
    
    var desiredStartDuration:Float = 0.0
    
    var player:IPlayerProtocol!
    {
        get{
            var player = BTPlayerManager.sharedManager.player!
            player.delegate = self
            
            
            return player
        }
    }
    
    var title:String = "" {
        didSet{
            self.player.setTitle(self.title)
          
            self.titleLabel?.text = self.title
        }
    }
    
    var subTitle:String = "" {
        didSet{
           self.player.setSubTitle(self.subTitle)
            
            self.subTitleLabel?.text = self.subTitle
        }
    }
    
    
    var getAudioDurationOperation = OperationQueue()
    
    var timeObserver:Any!
    
    var playingItem:AVPlayerItem!
    var playerUrl:URL!{
        
        didSet{
            
            if self.player != nil
            {
                self.desiredStartDuration = 0.0
                
                if timeObserver != nil
                {
                    self.player.removeTimeObserver(observer: timeObserver!)
                    self.timeObserver = nil
                }
                self.player.pause()
                self.isPaused = false
                //self.player.setPlayerItemPath(itemPathUrl: nil)
                
                self.pauseButton.isHidden = true
                self.playButton.isHidden = false
            }
            
            self.getAudioDurationOperation.cancelAllOperations()
            
            self.errorLabel.isHidden = true
            
            self.saveDurratoin(0)
            self.timeLeftLabel.text = self.timeDisplayForSeconds(seconds: 0)
            self.timePassedLabel.text = self.timeDisplayForSeconds(seconds: 0)
            
            if self.playerUrl == nil
            {
                self.setLessonNotFoundLayout()
                
                return
            }
            
            self.updatePlayer()
            
           self.setPalyerNotifications()
        }
    }
    
    func setPalyerNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.itemDidFinishPlaying(notification:)),name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setPlayerUrl(_ url:URL?, durration:Int, onReadyToPlay:@escaping () -> Void, onLessonNotFound:@escaping () -> Void)
    {
        self.onReadyToPlay = onReadyToPlay
        self.onLessonNotFound = onLessonNotFound
        
        self.setPlayerUrl(url, durration: durration)
    }
   
    func setPlayerUrl(_ url:URL?, durration:Int)
    {
        if durration > 0
        {
            self.desiredStartDuration = Float(durration)
        }
        
        self.setPlayerUrl(url)

       
    }
    
    func setPlayerUrl(_ url:URL?)
    {
        //If the url is the sampe as the current url, do not update player
        if let newUrl = url
            ,let currentPlayerUrl = self.playerUrl
        , currentPlayerUrl.absoluteString == newUrl.absoluteString
        {
            self.play()
        }
        
        let selectedUrl = url
        // selectedUrl = URL(string: "https://lakewoodafyomi.appspot.com/api/tractate/2741094af73bf03da69f9da78bcb067a/shabbos-100.m4a")!
        
        
        if selectedUrl != nil
        {
             print ("SelectedAudioUrl:\(selectedUrl!.absoluteString)")
        }
        else{
             print ("setAudioUrlForLesson failed")
        }
        
        self.playerUrl = selectedUrl
    }
    
    
    func setReadyToPlayLayout()
    {
        if let duration = self.player.duration()
        {
            self.updatePlayerWithDurationSeconds(seconds: CMTimeGetSeconds(duration))
        }
        
        if self.startAutomatically
        {
            if let enablesAutomaticPlaying = UserDefaults.standard.object(forKey: "setableItem_EnablesAutomaticPlaying") as? Bool
            ,enablesAutomaticPlaying == false
            {
                 self.setPrepareToPlayLayout()
            }
            else{
               
                self.play()
            }
        }
        else{
            self.setPrepareToPlayLayout()
        }
    }
    
    func setLessonNotFoundLayout()
    {
        self.loadingActivityIndicator.isHidden = true
        self.isloading = false
        self.delegate?.playerLoadingStatusChanged(player: self, isLoading: false)
        self.loadingActivityIndicator.stopAnimating()
        self.playingItem = nil
        
        self.playButton.isHidden = true
        self.errorLabel.isHidden = false
        self.errorLabel.text = "Lesson Not Found".localize()
        
        self.jumpForwardButton?.isHidden = true
        self.jumpBackButton?.isHidden = true
        
        self.updatePlayerWithDurationSeconds(seconds: 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadingActivityIndicator.isHidden = true
        self.pauseButton.isHidden = true
        self.errorLabel.isHidden = true
        
        self.progressSlider.setThumbImage(UIImage(named:"inner_ipad.png"), for: .normal)
        self.progressSlider.setThumbImage(UIImage(named:"inner_ipad.png"), for: .highlighted)
        
        self.progressSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BTPlayerView.sliderTappedAction(_:))))
        
        self.errorLabel.textColor = UIColor.white
        
        self.iconImageView?.layer.cornerRadius = self.iconImageView!.frame.size.width/2
        
        self.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
    }
  
    
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else {
            return
        }
        switch event.subtype {
        case .remoteControlPlay:
            self.play()
            break
            
        case .remoteControlPause:
            self.pause()
            
            break
        case .remoteControlStop:
            ///
            break
            
        default:
            print("default action")
        }
    }
    
    func showLessonNotFoundAlert()
    {
        let title = "st_lesson_not_found".localize()
        let msg = "st_lesson_not_found_message".localize()
        let cancelButton = "st_cancel".localize()
        BTAlertView.show(title: title, message: msg, buttonKeys: [cancelButton], onComplete:{ (dismissButtonKey) in
        })
    }
    
    @IBAction func jumpForwardButtonClicked(_ sedner:UIButton)
    {
        if player != nil
        {
            var newDuratoin = self.progressSlider.value + 15
            
            if newDuratoin > self.progressSlider.maximumValue
            {
                newDuratoin = self.progressSlider.maximumValue
            }
            
            self.setDuration(Int(newDuratoin))
        }
    }
    
    @IBAction func jumpBackButtonClicked(_ sedner:UIButton)
    {
        if player != nil
        {
            var newDuratoin = self.progressSlider.value - 30
            
            if newDuratoin < self.progressSlider.minimumValue
            {
                newDuratoin = self.progressSlider.minimumValue
            }
            
            self.setDuration(Int(newDuratoin))
        }
    }
    
    @IBAction func rateSpeedButtonClicked(_ sender:UIButton)
    {
        if let playerRateSpeedView = UIView.viewWithNib("BTPlayerRateSpeedView") as? BTPlayerRateSpeedView
        {
            playerRateSpeedView.delegate = self
            
            let options = [
                .type(.down)
                ] as [PopoverOption]
            
            let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
            
            var inView:UIView = self
             if let rootNavController = UIApplication.shared.keyWindow?.rootViewController
             {
                inView = rootNavController.view
            }
            popover.show(playerRateSpeedView, fromView: self.rateSpeedButton!, inView: inView)
            
            playerRateSpeedView.rateSpeedSlider?.setValue(player.rate(), animated: false)
        }
    }
    
    @IBAction func sliderTappedAction(_ sender: UITapGestureRecognizer)
    {
        if let slider = sender.view as? UISlider {
            
            if slider.isHighlighted { return }
            
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            
            
            self.sliderChanged(self.progressSlider)
            
            if player != nil && self.player.isActive()
            {
                if self.playButton.isHidden
                {
                    self.player.play()
                }
            }
        }
    }
    
    @IBAction func sliderChanged(_ slider:UISlider)
    {
        if slider == progressSlider
        {
            self.setDuration(Int(self.progressSlider.value))
        }
    }
    
    func setDuration(_ duration:Int)
    {
        self.updateDurationLayout(duration:duration)
        
        if player == nil || self.player.isActive()
        {
            self.moveToDesiredStartDuration(Float(duration))
            
            return
        }
        if let duratoin = self.player.duration()
        {
            let timeScale = duratoin.timescale
            let time = CMTimeMakeWithSeconds(Double(duration), preferredTimescale: timeScale);
            
            if self.isPaused
            {
                self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
                }
                
            }
            else
            {
                self.player.pause()
                self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
                }
            }
        }
        
        self.delegate?.playerView(self, didChangeDuration: duration)
    }
    
    func updateDurationLayout(duration:Int)
    {
        self.saveDurratoin(duration)
        
        self.progressSlider.value = Float(duration)
        
        self.timePassedLabel.text = self.timeDisplayForSeconds(seconds: duration)
        
        let timeLeft = Int( self.progressSlider.maximumValue) - duration
        self.timeLeftLabel.text = self.timeDisplayForSeconds(seconds: timeLeft)

    }
    
    @IBAction func sliderDidFinishSliding(_ sender:AnyObject)
    {
        print ("sliderDidFinishSliding")
        if self.player != nil && self.player.isActive()
        {
            if self.isPaused == false //the slider should playing
            {
                if self.playButton.isHidden
                {
                    self.player.play()
                }
            }
        }
        else{
            
            self.moveToDesiredStartDuration(self.progressSlider.value)
            
        }
        
    }
    
    @IBAction func playButtonClicked(_ sender:AnyObject)
    {
        self.play()        
    }
    
    func play()
    {
        if self.playerUrl == nil
        {
            return
        }
        
        if true//self.playerUrl != NSURLPreferredIOBlockSizeKey
        {
            self.playingItem = AVPlayerItem(url: self.playerUrl)
        }
        
        if self.playingItem == nil
        {
            return
        }
        
        self.player.play()
         self.setIsPlayingLayout()
    }
    
    func updatePlayer()
    {
       self.playingItem = AVPlayerItem(url: self.playerUrl)
        
        self.playButton.isHidden = true
        self.loadingActivityIndicator.isHidden = false
        self.loadingActivityIndicator.startAnimating()
        self.isloading = true
        self.delegate?.playerLoadingStatusChanged(player: self, isLoading: true)
        
        self.player.setPlayerItemPath(itemPathUrl: self.playerUrl)
        
        self.jumpForwardButton?.isHidden = true
        self.jumpBackButton?.isHidden = true

    }
    
    func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func updatePlayerWithDurationSeconds(seconds:Float64)
    {
        self.saveDurratoin(Int(seconds))
        
        let timeNow = self.timeNow()
        
        if timeNow > 0
        {
            if loadingActivityIndicator.isAnimating
            {
                self.setPrepareToPlayLayout()
                self.setIsPlayingLayout()
            }
        }
    
        self.timePassedLabel.text = self.timeDisplayForSeconds(seconds: timeNow)
        
        self.progressSlider.value = Float(timeNow)
        
        let timeLeft = Int(seconds) - Int(timeNow)
        self.timeLeftLabel.text = self.timeDisplayForSeconds(seconds: timeLeft)
        
        self.progressSlider.minimumValue = 0.0
        self.progressSlider.maximumValue = Float(seconds)
        
        self.delegate?.playerView(self, didChangeDuration: Int(timeNow))
    }
    
    func timeNow() -> Int
    {
        var timeNow = Int(0.0)
        
        if self.player != nil && self.player.isActive()
        {
            timeNow = Int(Double(self.player.currentTime().value) / Double(self.player.currentTime().timescale))
        }
        
        return timeNow
    }
    
    func saveDurratoin(_ durration:Int) {
        
        if durration%10 == 0 {
            var savedAudioDurrations = UserDefaults.standard.object(forKey: "savedAudioDurrations") as? [(path:String,duration:Int)] ??  [(path:String,duration:Int)]()
            
            for index in 0..<savedAudioDurrations.count{
               let audioInfo = savedAudioDurrations[index]
                
                if audioInfo.path == self.playerUrl.absoluteString {
                    savedAudioDurrations.remove(at: [index])
                    break
                }
            }
            
            savedAudioDurrations.append((path: self.playerUrl.absoluteString, duration: durration))
        }
    }
    
    func timeDisplayForSeconds(seconds:Int) -> String
    {
        let mins = seconds / 60
        let sec = seconds % 60
        
        let minsDisplay = mins > 9 ? "\(mins)" : "0\(mins)"
        let secDisplay = sec > 9 ? "\(sec)" : "0\(sec)"
        
        return "\(minsDisplay):\(secDisplay)"
        
    }
    
    @IBAction func pauseButtonClicked(_ sender:AnyObject)
    {
        self.pause()
        
        self.delegate?.didPause(player: self)
    }
    
    func pause()
    {
        self.player.pause()
        self.playerDidStop()
    }
    
    func playerDidStop()
    {
        self.isPaused = true
        self.pauseButton.isHidden = true
        self.playButton.isHidden = false
    }

    func moveToDesiredStartDuration(_ desiredStartDuration:Float)
    {
        self.desiredStartDuration = desiredStartDuration
        
        if self.player.status() == "ReadyToPlay"
        {
            if self.desiredStartDuration > 0.0
            {
                
                let timeScale = self.player.duration()!.timescale;
                let time = CMTimeMakeWithSeconds(Double(self.desiredStartDuration), preferredTimescale: timeScale);
                
                self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
                    
                self.updateDurationLayout(duration:Int(desiredStartDuration))

                     self.desiredStartDuration = 0.0
                }
            }
        }
    }
    
    @objc func itemDidFinishPlaying(notification:NSNotification)  {
        
        let timeScale = self.player.duration()!.timescale;
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: timeScale);
        
        self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){ (Bool) in
            
            self.desiredStartDuration = 0.0
        }
        
        self.playerDidStop()
        
        self.delegate?.didFinishPlaying(self)
    }
    
    func setPrepareToPlayLayout()
    {
        self.loadingActivityIndicator.isHidden = true
        self.isloading = false
         self.delegate?.playerLoadingStatusChanged(player: self, isLoading: false)
        self.loadingActivityIndicator.stopAnimating()
        
        self.pauseButton.isHidden = true
        self.playButton.isHidden = false
        self.errorLabel.isHidden = true
        
        self.jumpForwardButton?.isHidden = false
        self.jumpBackButton?.isHidden = false
    }
    
    func setIsPlayingLayout()
    {
        self.pauseButton.isHidden = false
        self.playButton.isHidden = true
        
        self.delegate?.didPlay(player: self)
    }
    
    func setNotPlayingLayout()
    {
        self.playerDidStop()
    }
    
    
    func playerIsReadyToPlay(player:IPlayerProtocol)
    {
        if let duration = self.player.duration()
        {
            self.moveToDesiredStartDuration(self.desiredStartDuration)

            let seconds = CMTimeGetSeconds(duration)
            
            if seconds > 0
            {
                self.setReadyToPlayLayout()
               self.addPeriodicTimeObserver()
                self.setBackgourndPlayer()
                
                //This is a callback if some one is listing to this
                self.onReadyToPlay?()
                
                return
            }
        }
        
        self.onLessonNotFound?()
        self.setLessonNotFoundLayout()
    }
    
    func addPeriodicTimeObserver()
    {
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] time in
            
            if (self?.player.isActive())!
            {
                if let duration = self?.player.duration()
                {
                    let seconds = CMTimeGetSeconds(duration)
                    
                    self?.updatePlayerWithDurationSeconds(seconds:seconds)
                }
            }
        }
    }
    
    func setBackgourndPlayer()
    {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyArtist: self.titleLabel?.text ?? "",
            MPMediaItemPropertyTitle: self.subTitleLabel?.text ?? "",
            // MPMediaItemPropertyArtwork: UIImage(named: "defualt.png")!,
            MPMediaItemPropertyPlaybackDuration: NSNumber(value: CMTimeGetSeconds(self.playingItem.asset.duration)),
            MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1)
        ]

    }
    
     func playerFailed(player:IPlayerProtocol)
     {
       self.onLessonNotFound?()
         self.setLessonNotFoundLayout()
    }
    
    func playerDidUpdateInfo(player: IPlayerProtocol) {
        
    }
    
    //Mark BTPlayerRateSpeedView Delegate methods
    
    func rateSpeedView(_ rateSpeedView:BTPlayerRateSpeedView, valueChanged value:Float)
    {
        self.rateSpeedButton?.setTitle( String(format: "%.1f", value), for: .normal)
        
        self.player.setRate(value)
    }
}

