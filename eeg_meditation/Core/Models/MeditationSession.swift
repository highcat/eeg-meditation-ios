//
//  MeditationSession.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 28.03.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import CoreData

class MeditationSession: NSManagedObject {
    // Currently running session
    static var current: MeditationSession?

    // declared in extension
    //    @NSManaged var startTime: Date?
    //    @NSManaged var stopTime: Date?
    //    @NSManaged var sessionData: Date?
    // ...etc

    // Ancillary:
    var isRunning: Bool = false
    var isSaved: Bool { sessionData != nil }
    //
    // Data
    var taps: [TapPoint] = []
    var eSense: [ESensePoint] = []
    var eegPowerDelta: [EEGPowerDeltaPoint] = []
    var eegPowerLowBeta: [EEGPowerLowBetaPoint] = []
    //
    var levelChanges: [LevelChangePoint] = []
    var pauses: [PauseMark] = []
}


// MARK: data types
extension MeditationSession {
    // Income data, saved as-is
    struct TapPoint {
        var at: TimeInterval
    }
    struct LevelChangePoint {
        var at: TimeInterval
        var newLevel: Int
    }
    struct ESensePoint {
        var at: TimeInterval  // since session start
        var poorSignal: Int32
        var attention: Int32
        var meditation: Int32
    }
    struct EEGPowerDeltaPoint {
        var at: TimeInterval
        //
        var delta: Int32
        var theta: Int32
        var lowAlpha: Int32
        var highAlpha: Int32
    }
    struct EEGPowerLowBetaPoint {
        var at: TimeInterval
        //
        var lowBeta: Int32
        var highBeta: Int32
        var lowGamma: Int32
        var midGamma: Int32
    }
    struct PauseMark {
        var at: TimeInterval
        let pause: Bool
        let resume: Bool
    }
    
    func lastPointReady() -> Bool {
        guard eSense.count > 0, eegPowerDelta.count > 0, eegPowerLowBeta.count > 0 else {
            return false
        }
        let (a, b, c) = (
            eSense[eSense.count-1].at,
            eegPowerDelta[eegPowerDelta.count-1].at,
            eegPowerLowBeta[eegPowerLowBeta.count-1].at
        )
        let gap = max(a, b, c) - min(a, b, c)
        return gap < 0.1
    }
    

    // Processed data
    struct EEGDataPoint: Codable {
        var at: Int  // seconds since session start
        var pauseMark: Bool = false
        var resumeMark: Bool = false
        //
        var tap: Bool = false
        //
        var poorSignal: Int32?
        var attention: Int32?
        var meditation: Int32?  // 0..100
        var meditationVasyl2021: Int32?
        //
        var delta: Int32?
        var theta: Int32?
        var lowAlpha: Int32?
        var highAlpha: Int32?
        //
        var lowBeta: Int32?
        var highBeta: Int32?
        var lowGamma: Int32?
        var midGamma: Int32?
        // user settings
        var level: Int?
    }
}
