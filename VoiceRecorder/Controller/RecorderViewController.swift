//
//  RecorderViewController.swift
//  VoiceRecorder
//
//  Created by 陳信彰 on 2023/7/8.
//

import UIKit
import AVFoundation


class RecorderViewController: UIViewController {
    
    let audioSession = AVAudioSession.sharedInstance()
    var voiceRecorder: AVAudioRecorder?
    var musicPlayer: AVAudioPlayer?
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        audioSession.requestRecordPermission { granted in
            if granted {
                // Present recording interface.
            } else {
                // Present message to user indicating that recording
                // can't be performed until they change their preference.
            }
        }
        
        
        
    }
    
    @IBAction func recordVoice(_ sender: Any) {
        
        // 設定錄音格式與取樣率
        let settings: [String:Any] = [AVFormatIDKey: kAudioFormatAppleIMA4,
                                    AVSampleRateKey: 22050.0,
                              AVNumberOfChannelsKey: 1,
                             AVLinearPCMBitDepthKey: 16,
                              AVLinearPCMIsFloatKey: false,
                          AVLinearPCMIsBigEndianKey: false
        ]
        // 錄音檔存放位置
        let recordFile = documentsUrl.appendingPathComponent("record.caf")
        print(recordFile)
        
        // 建立錄音元件
        voiceRecorder = try? AVAudioRecorder(url: recordFile, settings: settings)
        voiceRecorder?.prepareToRecord()
        
        // 改變AVAudioSession的設定
        try? audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        
        // 開始錄音
        voiceRecorder?.record()
    }
    
    
    @IBAction func pause(_ sender: Any) {
        
        voiceRecorder?.pause()
        print("Pause")
        
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        
        voiceRecorder?.stop()
        print("Stop")
        
    }
    
    @IBAction func play(_ sender: Any) {
        
        let fileUrl = documentsUrl.appendingPathComponent("record.caf")
        
//        guard let url = Bundle.main.url(forResource: "Let You Down", withExtension: "mp3") else { return }
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            
            musicPlayer = try? AVAudioPlayer(contentsOf: fileUrl)
            musicPlayer?.prepareToPlay()
        }
        
        try? audioSession.setCategory(AVAudioSession.Category.playback)

        musicPlayer?.play()

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
