//
//  MeditationSession+API.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 23.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation

// MARK: generic API
extension MeditationSession {
    func start() {
        guard !isRunning else { return }
        cleanup()
        startTime = Date()
        isRunning = true
    }
    func stop() {
        guard isRunning else { return }
        endTime = Date()
        isRunning = false
    }

    func cleanup() {
        // FIXME don't cleanup, always use a new session.
        assert(levelChanges.count == 0)
        assert(pauses.count == 0)
        assert(taps.count == 0)
        assert(eSense.count == 0)
        assert(eegPowerDelta.count == 0)
        assert(eegPowerLowBeta.count == 0)
    }

    func save() throws {
        sessionData = try JSONEncoder().encode(mergedData())
        do {
            try AppDelegate.viewContext.save()
            print("+++ session saved.")
        } catch let error as NSError {
            print("Unable to save: \(error), \(error.userInfo)")
        }
    }
}


// MARK: domain-specific API
//
// Note: `at` parameter is used everywhere to pass values from other threads storing real-time timestamp.
extension MeditationSession {
    func addLevelChange(newLevel: Int, at: Date) {
        guard let startTime = startTime, endTime == nil else { return /* not running */ }
        levelChanges.append(LevelChangePoint(
            at: at.timeIntervalSince(startTime),
            newLevel: newLevel
        ))
    }

    func addTap(at: Date) {
        guard let startTime = startTime, endTime == nil else { return /* not running */ }
        taps.append(TapPoint(
            at: at.timeIntervalSince(startTime)
        ))
    }

    func addESense(poorSignal: Int32, attention: Int32, meditation: Int32, at: Date) {
        // Android Bluetooth 5.0 bug emulation (don't delete, comment out)
        // guard Int.random(in: 0..<3) > 0 else { return }

        guard let startTime = startTime, endTime == nil else { return /* not running */ }
        // print("eSense: poorSignal:\(poorSignal), att:\(attention) med:\(meditation)")
        eSense.append(ESensePoint(
            at: at.timeIntervalSince(startTime),
            poorSignal: poorSignal,
            attention: attention,
            meditation: meditation
        ))
    }

    func addPowerDelta(delta: Int32, theta: Int32, lowAlpha: Int32, highAlpha: Int32, at: Date) {
        guard let startTime = startTime, endTime == nil else { return /* not running */ }
        eegPowerDelta.append(EEGPowerDeltaPoint(
            at: at.timeIntervalSince(startTime),
            delta: delta,
            theta: theta,
            lowAlpha: lowAlpha,
            highAlpha: highAlpha
        ))
    }

    func addPowerLowBeta(lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32, at: Date) {
        guard let startTime = startTime, endTime == nil else { return /* not running */ }
        eegPowerLowBeta.append(EEGPowerLowBetaPoint(
            at: at.timeIntervalSince(startTime),
            lowBeta: lowBeta,
            highBeta: highBeta,
            lowGamma: lowGamma,
            midGamma: midGamma
        ))
    }

    func addPause(at: Date) {
        guard let startTime = startTime, endTime == nil else { return /* not running */ }
        print("  --> add pause")
        pauses.append(PauseMark(
            at: at.timeIntervalSince(startTime),
            pause: true,
            resume: false
        ))
    }

    func addResume(at: Date) {
        guard let startTime = startTime, endTime == nil else { return /* not running */ }
        print("  --> add resume")
        pauses.append(PauseMark(
            at: at.timeIntervalSince(startTime),
            pause: false,
            resume: true
        ))
    }
}

