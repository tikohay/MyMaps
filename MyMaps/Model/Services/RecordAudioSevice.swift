//
//  RecordAudioSevice.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 27.11.2021.
//

import Foundation
import AVFoundation
import UIKit

class RecordAudioService: NSObject {
    
    var recorder: AVAudioRecorder?
    
    func recordNewAudio() {
        let documentsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = documentsUrl.appendingPathComponent("newRecord.m4a")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            recorder = try AVAudioRecorder(url: url,
                                           settings: [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                      AVSampleRateKey: 44100.0,
                                                      AVNumberOfChannelsKey: 2])
        } catch {
            print(error.localizedDescription)
        }
        recorder?.delegate = self
        recorder?.prepareToRecord()
        recorder?.record()
    }
    
    func stopRecord() {
        if recorder?.isRecording == true {
            recorder?.stop()
        }
    }
}

extension RecordAudioService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        self.recorder = nil
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
}
