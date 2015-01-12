//
//  Announcer.swift
//  MemoryTraining
//
//  Created by Александр Подрабинович on 12/01/15.
//  Copyright (c) 2015 Alex Podrabinovich. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Announcer: NSObject {
    //Пллер
    var avPlayer: AVAudioPlayer!
    var fileToPlay: String = ""
    var fileExtensionToPlay: String = ""
    
    func readFileIntoAVPlayer() {
        var error: NSError?
        let fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(self.fileToPlay, ofType: self.fileExtensionToPlay)!)
        // the player must be a field. Otherwise it will be released before playing starts.
        self.avPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: &error)
        
        if avPlayer == nil {
            if let e = error {
                println("!!!")
                println(e.localizedDescription)
            }
        }
        
        avPlayer.delegate = self
        avPlayer.prepareToPlay()
        //        avPlayer.volume = 20.0
        avPlayer.play()
    }
    
    func stopAVPlayer() {
        if avPlayer.playing {
            avPlayer.stop()
        }
    }
    
    func toggleAVPlayer() {
        if avPlayer.playing {
            avPlayer.pause()
        }
        else {
            avPlayer.play()
        }
    }
}

extension Announcer : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
//        player.play()
    }
    
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
    
}