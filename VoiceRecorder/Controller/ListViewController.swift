//
//  ListViewController.swift
//  VoiceRecorder
//
//  Created by 陳信彰 on 2023/7/8.
//

import UIKit
import AVFoundation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    let audioSession = AVAudioSession.sharedInstance()
    
    var records = [Record]() {
        didSet {
            Record.saveRecord(records)
        }
    }

    var voiceRecorder: AVAudioRecorder?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        tableView.dataSource = self
        tableView.delegate = self
        
        audioSession.requestRecordPermission { granted in
            if granted {
                
                if let records = Record.loadRecord() {
                    self.records = records
                }

            } else {
                
                let alertVC = UIAlertController(title: "Permission Deny", message: "You don't granted the permission to record.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }

    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
        
    }
    
    @IBAction func addRecord(_ sender: UIButton) {
        
        try? audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        let id = UUID().uuidString

        if voiceRecorder == nil {
            
            // 建立錄音資料
            let settings: [String : Any] = [AVFormatIDKey : kAudioFormatAppleIMA4,
                                         AVSampleRateKey : 22050.0,
                                   AVNumberOfChannelsKey : 1,
                                  AVLinearPCMBitDepthKey : 16,
                                   AVLinearPCMIsFloatKey : false,
                               AVLinearPCMIsBigEndianKey : false]
            
            let recordUrl = Record.documentDir.appendingPathComponent(id).appendingPathExtension("caf")
            
            voiceRecorder = try? AVAudioRecorder(url: recordUrl, settings: settings)
            voiceRecorder?.delegate = self
            
            voiceRecorder?.record()
            sender.setImage(UIImage(systemName: "stop.circle"), for: .normal)
            
            // 新增資料
            let date = Date()
            let record = Record(id: id, date: date)
            records.insert(record, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            print(recordUrl)
            
        } else {

            voiceRecorder?.stop()
            voiceRecorder = nil
            sender.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
            
        }

    }
    
    
    // MARK: - DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        let record = records[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss a"
        let dateString = dateFormatter.string(from: record.date)
        
        cell.textLabel?.text = dateString
        cell.detailTextLabel?.text = record.description
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        records.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let record = records.remove(at: sourceIndexPath.row)
        records.insert(record, at: destinationIndexPath.row)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let playVC = segue.destination as? PlayViewController,
           let indexPath = self.tableView.indexPathForSelectedRow {
            
            playVC.record = records[indexPath.row]
            playVC.delegate = self
        }

    }
    
    
}

// MARK: - PlayViewControllerDelegate

extension ListViewController: PlayViewControllerDelegate  {
    
    func playViewController(_ controller: PlayViewController, didFinishedUpdate record: Record) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.records[indexPath.row] = record
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

    }
}

// MARK: - AVAudioRecorderDelegate

extension ListViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        let alertVC = UIAlertController(title: "是否保留錄音？", message: "若不保留請按取消", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            
            let record = self.records.remove(at: 0)
            let url = Record.documentDir.appendingPathComponent(record.id).appendingPathExtension("caf")
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true)
        
    }
    
}
