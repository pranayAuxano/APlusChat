//
//  AudioPlayVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import AVKit
import MobileCoreServices
import AVFoundation
import Foundation

public class AudioPlayVC: UIViewController {
    
    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var lblDuration: UILabel!
    
    var audioPlayer : AVPlayer!
    var playButton:UIButton?
    var filePath : URL?
    var player: AVAudioPlayer?
    var timer = Timer()
    var time = -1
    var min = 0
    var sec = 0
    
    var duration: TimeInterval {
        get {
            return player!.duration
        }
        set {
            self.duration = newValue
        }
    }
    
    @IBOutlet weak var btnPlay: UIButton!
    
    public init()
    {
        super.init(nibName: "AudioPlayVC", bundle: Bundle(for: AudioPlayVC.self))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented AudioPlayVC")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewPlay.layer.cornerRadius = 5
        player?.delegate = self
    }

    public override func viewWillAppear(_ animated: Bool) {
        self.playSound()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        //audioPlayer!.pause()
        btnPlay.isSelected = false
        time = -1
        timer.invalidate()
        player?.stop()
    }
    
    @IBAction func btnPlayTap(_ sender: UIButton) {
        
        if sender.tag == 0
        {
            if !btnPlay.isSelected
            {
                btnPlay.isSelected = true
                player?.play()
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getTime), userInfo: nil, repeats: true)
            }
            else
            {
                btnPlay.isSelected = false
                player?.pause()
                timer.invalidate()
            }
        }
        else
        {
            self.player?.stop()
            self.dismiss(animated: true)
        }
    }
    
    func playSound()
    {
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(filePath!.lastPathComponent)
        
        do {
            player = try AVAudioPlayer(contentsOf: destinationUrl)
            player?.prepareToPlay()
            player?.enableRate = true
            player?.numberOfLoops = 1
            player?.play()
            btnPlay.isSelected = true
            audioSlider.maximumValue = Float(duration)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getTime), userInfo: nil, repeats: true)
            
            min = (Int(duration) % 3600) / 60
            sec = (Int(duration) % 3600) % 60
            lblDuration.text = "\(min):\(sec)"
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    @objc func getTime()
    {
        time += 1
        
        if Float(time) <= Float(duration)
        {
            audioSlider.setValue(Float(time), animated: true)
            sec -= 1
            
            if sec > -1
            {
                let s = sec < 10 ? "0" : ""
                lblDuration.text = "\(min):\(s)\(sec)"
            }
            else
            {
                min -= 1
                sec = 59
                lblDuration.text = "\(min):\(sec)"
            }
        }
        else
        {   }
    }
    
    @IBAction func sliderAudio(_ sender: UISlider)
    {
        print(duration) //  Time in second
        
        //audioSlider.minimumValue = 0.0
        //audioSlider.maximumValue = Float(duration)
        
        //let sec = Int(duration) % 60
        //let min = (Int(duration) - sec)/60
        //print("Time - \(min):\(sec)")
        //print(player?.rate)
        
        //let value = self.audioSlider.value
        //let durationToSeek = Float(duration) * value
        //audioPlayer.seek(to: CMTimeMakeWithSeconds(Float64(durationToSeek),player.currentItem!.duration.timescale)) { [weak self](state) in
            
        //}
    }

}

extension AudioPlayVC : AVAudioPlayerDelegate
{   }
