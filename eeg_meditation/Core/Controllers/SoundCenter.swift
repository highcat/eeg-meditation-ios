//
//  SoundCenter.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 14.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import AVKit

class SoundCenter: NSObject {
    static var shared = SoundCenter()
    private override init() {
        super.init()
        setSoundVolume()
    }

    // Players ownership
    private var actionPlayers: [ObjectIdentifier: AVAudioPlayer] = [:]
    private var feedbackPlayer: AVAudioPlayer?
    //
    // FIXME better use AVAudioNode for mixing audios
    //

    private var stoppingSound: Bool = false

    //
    // NOTE: Assets can be put into a simple directory (instead of Assets.xcassets)
    // and loaded via Bundle.main.url(fromResource: "sound_connected", withExtension: "mp3")
    //
    private var assets: [String: Data] = [
        "connected": loadAsset("sound_connected"),
        "signalLost": loadAsset("sound_signalLost"),
        // session endings
        "sessionEnd": loadAsset("sound_endBell"),
        "vasyl_bells": loadAsset("sound_vasyl_bells"),
        //
        "whiteNoise": loadAsset("sound_whiteNoise"),
        "tone": loadAsset("sound_tone"),
    ]

    private func setSoundVolume() {
        // Set playback volume for speaker. FXIME is this the best way?
        let avSession = AVAudioSession.sharedInstance()
        try? avSession.setCategory(.playback, options: [.defaultToSpeaker])
    }

    private static func loadAsset(_ name: String) -> Data {
        if let asset = NSDataAsset(name: name) {
            return asset.data
        }
        abort()
    }

    //
    // FIXME better use AVAudioNode for mixing audios
    //
    private func playAsset(_ name: String) {
        if let assetData = assets[name] {
            guard let player = try? AVAudioPlayer(data: assetData) else {
                return
            }
            player.delegate = self
            actionPlayers[ObjectIdentifier(player)] = player
            // player.numberOfLoops = -1 // indefinitely
            player.play()
        }
    }

    public func stopSounds() {
        for case let (_, player) in actionPlayers {
            player.stop()
        }
        actionPlayers.removeAll()
    }
}


// MARK: Sound Center API
extension SoundCenter {
    func playConnected() {
        playAsset("connected")
    }
    func playSignalLost() {
        playAsset("signalLost")
    }
    func playTimerEnded() {
        switch SettingsModel.shared.endSound {
        case .chineseHong:
            playAsset("sessionEnd")
        case .vasylSound:
            playAsset("vasyl_bells")
        case .custom:
            break
        }
    }

    enum FeedbackType {
        case tone
        case whiteNoise
        case slient
    }

    func startFeedback(type: FeedbackType) {
        stopFeedback() {
            let data: Data?
            switch type {
            case .tone:
                data = self.assets["tone"]!
            case .whiteNoise:
                data = self.assets["whiteNoise"]!
            case .slient:
                data = nil
            }
            if let data = data {
                self.feedbackPlayer = try? AVAudioPlayer(data: data)
                self.feedbackPlayer?.numberOfLoops = -1  // forever
                self.feedbackPlayer?.volume = 0.0  // controlled by setFeedbackVolume()
                self.feedbackPlayer?.play()
            }
        }
    }

    func setFeedbackVolume(volume: Float) {
        guard stoppingSound == false else { return }
        feedbackPlayer?.setVolume(volume, fadeDuration: 0.6)
    }

    func stopFeedback(complete: @escaping ()->Void = {}) {
        stoppingSound = true
        guard let _ = feedbackPlayer else {
            stoppingSound = false
            complete()
            return
        }
        let FADE_INTERVAL: TimeInterval = 0.4
        // Fade to avoid clicks
        feedbackPlayer?.setVolume(0.0, fadeDuration: FADE_INTERVAL)
        DispatchQueue.main.asyncAfter(deadline: .now()+FADE_INTERVAL) {
            self.feedbackPlayer?.stop()
            self.feedbackPlayer = nil
            self.stoppingSound = false
            complete()
        }
    }
}


extension SoundCenter: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        actionPlayers.removeValue(forKey: ObjectIdentifier(player))
    }
}
