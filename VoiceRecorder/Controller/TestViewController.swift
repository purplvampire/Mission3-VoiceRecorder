//
//  TestViewController.swift
//  VoiceRecorder
//
//  Created by 陳信彰 on 2023/7/8.
//

import UIKit
import AVFoundation

class TestViewController: UIViewController {
    
    let audioSession = AVAudioSession.sharedInstance()
    var voiceRecorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        audioSession.requestRecordPermission { granted in
            if granted {
                
                self.updateUI()
                
            } else {
                
                print("Not granted")
                
            }
        }
    }
    
    func updateUI() {
        
        recordButton.configuration?.image = UIImage(systemName: "record.circle")
        
        let settings: [String : Any] = [AVFormatIDKey: kAudioFormatAppleIMA4,
                                      AVSampleRateKey: 22050.0,
                                AVNumberOfChannelsKey: 1,
                               AVLinearPCMBitDepthKey: 16,
                                AVLinearPCMIsFloatKey: false,
                            AVLinearPCMIsBigEndianKey: false
        ]
        let url = documentUrl.appendingPathComponent("record.caf")
        print(url)
        
        voiceRecorder = try? AVAudioRecorder(url: url, settings: settings)
        voiceRecorder?.prepareToRecord()
        
        try? audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        
    }
    
    @IBAction func record(_ sender: UIButton) {

        if voiceRecorder!.isRecording {
            
            voiceRecorder?.stop()
            recordButton.configuration?.image = UIImage(systemName: "record.circle")
            print("Record Stop")
            
        } else {
            
            voiceRecorder?.record()
            recordButton.configuration?.image = UIImage(systemName: "stop.circle.fill")
            print("Record Start")

        }

    }
    
    
    @IBAction func play(_ sender: UIButton) {
        
        let url = documentUrl.appendingPathComponent("record.caf")
        if FileManager.default.fileExists(atPath: url.path) {
            
            player = try? AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        }
        try? audioSession.setCategory(AVAudioSession.Category.playback)

        if player!.isPlaying {
            player?.pause()
            playButton.setTitle("暫停", for: .normal)
        } else {
            player?.play()
            playButton.setTitle("播放", for: .normal)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
