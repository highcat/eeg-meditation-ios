//
//  MeditationSession+calculations.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 23.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation

extension MeditationSession {
    func storedData() -> [EEGDataPoint] {
        guard let sessionData = sessionData else { return [] }
        do {
            return try JSONDecoder().decode([EEGDataPoint].self, from: sessionData)
        } catch {
            return []
        }
    }

    /// merge recieved values to continuous array
    func mergedData(forLastSeconds: Int? = nil, stripPauses: Bool = true) -> [EEGDataPoint] {
        guard let startTime = startTime else { return [] }
        var mergedData: [EEGDataPoint] = []

        // Can be calculated for ongoing session, so accepting null endTime
        let secondsTotal = Int((endTime ?? Date()).timeIntervalSince(startTime).rounded())
        var i_second = secondsTotal

        var zeroSecond: Int = { // can change if a pause found
            var zeroSecond = 0
            if let forLastSeconds = forLastSeconds {
                zeroSecond = secondsTotal - forLastSeconds
                zeroSecond = zeroSecond < 0 ? 0 : zeroSecond
            }
            return zeroSecond
        }()


        var isPaused = false
        var i_pauses = pauses.endIndex - 1
        var i_taps = taps.endIndex - 1
        var i_levelChanges = levelChanges.endIndex - 1
        var i_eSense = eSense.endIndex - 1
        var i_eegPowerDelta = eegPowerDelta.endIndex - 1
        var i_eegPowerLowBeta = eegPowerLowBeta.endIndex - 1

        let DELTA_FROM: Double = -0.5
        let DELTA_TO: Double = 0.5

        while i_second >= zeroSecond {
            var mergedPoint = EEGDataPoint(at: i_second)

            if stripPauses && isPaused && zeroSecond > 0 {
                zeroSecond -= 1
            }

            while i_pauses >= 0 {
                let delta = pauses[i_pauses].at - TimeInterval(i_second)
                if delta > DELTA_FROM && delta <= DELTA_TO {
                    let point = pauses[i_pauses]
                    mergedPoint.pauseMark = point.pause  // pauseMark will appear in stripPauses mode
                    mergedPoint.resumeMark = point.resume
                    // This shifts zeroSecond
                    if !isPaused && point.resume { // going backwards, you remember
                        isPaused = true
                    }
                    if isPaused && point.pause {
                        isPaused = false
                    }
                    break
                } else if delta >= DELTA_TO {
                    i_pauses -= 1
                } else {
                    break
                }
            }
            while i_taps >= 0 {
                let delta = taps[i_taps].at - TimeInterval(i_second)
                if delta > DELTA_FROM && delta <= DELTA_TO {
                    mergedPoint.tap = true
                    break
                } else if delta >= DELTA_TO {
                    i_taps -= 1
                } else {
                    break
                }
            }
            while i_levelChanges >= 0 {
                let delta = levelChanges[i_levelChanges].at - TimeInterval(i_second)
                if delta > DELTA_FROM && delta <= DELTA_TO {
                    mergedPoint.level = levelChanges[i_levelChanges].newLevel
                    // will fill levels in forwards processing.
                    break
                } else if delta >= DELTA_TO {
                    i_levelChanges -= 1
                } else {
                    break
                }
            }

            while i_eSense >= 0 {
                let point = eSense[i_eSense]
                let delta = point.at - TimeInterval(i_second)
                if delta > DELTA_FROM && delta <= DELTA_TO {
                    mergedPoint.poorSignal = point.poorSignal
                    mergedPoint.attention = point.attention
                    mergedPoint.meditation = point.meditation
                    break
                } else if delta >= DELTA_TO {
                    i_eSense -= 1
                } else {
                    break
                }
            }
            while i_eegPowerDelta >= 0 {
                let point = eegPowerDelta[i_eegPowerDelta]
                let delta = point.at - TimeInterval(i_second)
                if delta > DELTA_FROM && delta <= DELTA_TO {
                    mergedPoint.delta = point.delta
                    mergedPoint.theta = point.theta
                    mergedPoint.lowAlpha = point.lowAlpha
                    mergedPoint.highAlpha = point.highAlpha
                    break
                } else if delta >= DELTA_TO {
                    i_eegPowerDelta -= 1
                } else {
                    break
                }
            }
            while i_eegPowerLowBeta >= 0 {
                let point = eegPowerLowBeta[i_eegPowerLowBeta]
                let delta = point.at - TimeInterval(i_second)
                if delta > DELTA_FROM && delta <= DELTA_TO {
                    mergedPoint.lowBeta = point.lowBeta
                    mergedPoint.highBeta = point.highBeta
                    mergedPoint.lowGamma = point.lowGamma
                    mergedPoint.midGamma = point.midGamma
                    break
                } else if delta >= DELTA_TO {
                    i_eegPowerLowBeta -= 1
                } else {
                    break
                }
            }
            //
            if !(stripPauses && isPaused) {
                mergedData.insert(mergedPoint, at: 0)
            }
            //
            i_second -= 1
        }

        // forward processing
        fillLevels(mergedData: &mergedData)
        //
        return mergedData
    }

    
    fileprivate func fillLevels(mergedData: inout [EEGDataPoint]) {
        var currentLevel: Int? = nil
        for (num, point) in mergedData.enumerated() {
            if let level = point.level {
                currentLevel = level
            }
            // EEGDataPoint returned by value, so ve have to reference them again.
            // FIXME better way to do this?
            mergedData[num].level = currentLevel
        }
    }
}

