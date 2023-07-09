//
//  PlayViewController.swift
//  VoiceRecorder
//
//  Created by 陳信彰 on 2023/7/8.
//

import UIKit
import AVFoundation


protocol PlayViewControllerDelegate: AnyObject {
    func playViewController(_ controller: PlayViewController, didFinishedUpdate record: Record)
}


class PlayViewController: UIViewController {
    
    weak var delegate: PlayViewControllerDelegate?
    
    var record: Record!
    var player = AVPlayer()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateUI()
        
        // 當播放完成時透過通知中心變更按鈕圖示
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] (notification) in
            
            guard let self = self else { return }
            
            self.playPauseButton.configuration?.image = UIImage(systemName: "play.circle.fill")
            
        }
        
    }
    
    func updateUI() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss a"
        dateLabel.text = dateFormatter.string(from: record.date)
        descriptionTextView.text = record.description
        
        // Read recordingItem
        let recordUrl = Record.documentDir.appendingPathComponent(record.id).appendingPathExtension("caf")
        
        if FileManager.default.fileExists(atPath: recordUrl.path) {
            let playerItem = AVPlayerItem(url: recordUrl)
            player.replaceCurrentItem(with: playerItem)
        }
    }
    
    @IBAction func playAndPause(_ sender: UIButton) {
        
        if player.timeControlStatus == .playing {
            
            player.pause()
            sender.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            
        } else {
            
            player.play()
            sender.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        
        record.description = descriptionTextView.text
        
        delegate?.playViewController(self, didFinishedUpdate: record)
        self.navigationController?.popViewController(animated: true)
    }
}
