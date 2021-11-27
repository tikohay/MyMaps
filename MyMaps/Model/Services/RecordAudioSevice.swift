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
    
    private var recorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    var delegate: RecordAudioServiceDelegate?
    var isPlaying = false
    
    func recordNewAudio() {
        prepareRecordNewAudio()
        recorder?.record()
    }
    
    func stopRecord() {
        if recorder?.isRecording == true {
            recorder?.stop()
        }
    }
    
    func playRecord() {
        if FileManager.default.fileExists(atPath: getUrl(for: "newRecord.m4a").path) {
            preparePlay()
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    func stopPlayingRecord() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    private func prepareRecordNewAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            recorder = try AVAudioRecorder(url: getUrl(for: "newRecord.m4a"),
                                           settings: [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                      AVSampleRateKey: 44100.0,
                                                      AVNumberOfChannelsKey: 2])
        } catch {
            print(error.localizedDescription)
        }
        recorder?.delegate = self
        recorder?.prepareToRecord()
    }
    
    
    private func preparePlay() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getUrl(for: "newRecord.m4a"))
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        }
        catch {
            print("Error")
        }
    }
    
    private func getUrl(for file: String) -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent(file)
        return url
    }
}

extension RecordAudioService: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        self.recorder = nil
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        delegate?.recordDidFinishPlaying()
    }
}
