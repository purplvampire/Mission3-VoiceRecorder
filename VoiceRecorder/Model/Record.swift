//
//  Record.swift
//  VoiceRecorder
//
//  Created by 陳信彰 on 2023/7/8.
//

import Foundation

class Record: Codable {
    
    var id: String
    var date: Date
    var description: String?
    
    init(id: String, date: Date, description: String? = nil) {
        self.id = id
        self.date = date
        self.description = description
    }
    
    static let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static func saveRecord(_ records: [Record]) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(records) else { return }
        let url = documentDir.appendingPathComponent("records")
        try? data.write(to: url)
    }
    
    static func loadRecord() -> [Record]? {
        let url = documentDir.appendingPathComponent("records")
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Record].self, from: data)
    }

}
