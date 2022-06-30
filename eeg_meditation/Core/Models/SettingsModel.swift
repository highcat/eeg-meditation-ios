//
//  SettingsCenter.swift
//  eegmeditation
//
//  Created by Alex Lokk on 14.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import RxRelay
import UIKit


enum SettingsVersion: String, Codable {
    case v0_0 = "0.0"
    case v1_0 = "1.0"
}
class VersionOnlySettingsModel: Codable {
    // If field is missing in JSON, you'll get an error.
    // So,
    // 1. Keep version the same if number of fields increase with the new app versions.
    //   Assume users only upgrading, not downgrading.
    // 2. If the config changed drastically, fetch a version first, and decode to different model.
    let version: SettingsVersion
}


// Note: Codable autogeneration doesn't work with subclasses.
// Use separate class each time.

// Example of old version settings model
class old_v0_0_SettingsModel: Codable {
    var thresholdMeditationLevel: Int = 70
}


//
// Current version of settings.
// "originator" in Memento pattern.
//
class SettingsModel: Codable {
    // XXX this can be replaced. But in only should happen on app initialization.
    static var shared = SettingsModel()
    static var relay = BehaviorRelay(value: shared)
    let version: SettingsVersion = .v1_0

    // MARK: The settings
    var meditationLevel: Int = 70

    var signalType = SignalType.whiteNoise
    var signalTypeCustom: String?

    var feedbackOn = FeedbackOn.exceeded

    var timerButton1: Int = 1
    var timerButton2: Int = 3
    var timerButton3: Int = 5
    var timerButton4: Int = 10
    var timerButton5: Int = 15
    var timerButton6: Int = 20
    var timerButton7: Int = 30
    var timerButton8: Int = 60


    var timerButtonSelected: TimerButtonEnum = .btn1

    var counterOn: Bool = false
    var timerOn: Bool = false

    var frequencyControlEnabled: Bool = false
    var frequencyCutoff: FrequencyCutoff = .cutoff50

    var endSound: EndSound = .chineseHong
    var endSoundCustom: String?
    
    var meditationAlgo: MeditationAlgo = .vasylVernyhora2021
    var algoModifier: AlgoModifier = .normal
    var showSecondaryAlgo: Bool = true
    
    var presentNewAlgo: Bool = true
}



// MARK: Enums
extension SettingsModel {
    enum SignalType: String, Codable {
        case tonal
        case whiteNoise
        case silent
        case custom
    }

    enum FeedbackOn: String, Codable {
        case exceeded
        case notReached
    }

    enum TimerButtonEnum: String, Codable {
        case btn1
        case btn2
        case btn3
        case btn4
        case btn5
        case btn6
        case btn7
        case btn8
    }

    enum FrequencyCutoff: String, Codable {
        case cutoff50
        case cutoff60
    }

    enum EndSound: String, Codable {
        case chineseHong
        case vasylSound
        case custom
    }
    
    enum MeditationAlgo: String, Codable {
        case eSense
        case vasylVernyhora2021
    }
    enum AlgoModifier: String, Codable {
        case normal
        case guruMode20
    }
}
