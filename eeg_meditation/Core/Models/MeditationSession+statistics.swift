//
//  MeditationSession+statistics.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 23.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation

// MARK: API
extension MeditationSession {
    struct Statistics {
        let sessionTime: Int
        let averageLevel: Int
        let meditationTimeForThreshold: Int
        let gte90Time: Int
        let gte80MaxSolidTime: Int
        let tapsCount: Int
    }


    func calcStatistics() -> MeditationSession.Statistics {
        var data: [EEGDataPoint]
        if isSaved {
            data = self.storedData()
        } else {
            data = self.mergedData()
        }
        // recalculate meditation formulas
        var newData: [EEGDataPoint] = []
        for (num, point) in data.enumerated() {
            var newPoint: EEGDataPoint = point
            if let m = vasylMeditation(
                sequence: data,
                offset: num,
                guruMode: SettingsModel.shared.algoModifier == .guruMode20  // FIXME don't use globals
            ) {
                newPoint.meditationVasyl2021 = Int32(m)
            }
            newData.append(newPoint)
        }
        data = newData
        
        func getMeditation(_ point: EEGDataPoint) -> Int32? {
            switch SettingsModel.shared.meditationAlgo {
            case .vasylVernyhora2021:
                return point.meditationVasyl2021
            case .eSense:
                return point.meditation
            }
        }


        let _sessionTime: Int
        var seconds: Int = 0
        for point in data {
            // Note: Pause marks does not matter, because pauses are stripped
            guard let poorSignal = point.poorSignal, poorSignal < 50 else { continue }
            guard let meditation = getMeditation(point), meditation > 0 else { continue }
            seconds += 1
        }
        // for EEG sessions
        if seconds > 0 {
            _sessionTime = seconds
        } else {
            // for distraction counter-only sessions:
            _sessionTime = data.count
        }

        
        let _averageLevel: Int
        var count: Int = 0
        var sum: Int = 0
        for point in data {
            guard let poorSignal = point.poorSignal, poorSignal < 50 else { continue }
            guard let meditation = getMeditation(point), meditation > 0 else { continue } // zero means no data
            count += 1
            sum += Int(meditation)
        }
        if count > 0 {
            _averageLevel = sum / count
        } else {
            _averageLevel = 0
        }
        
        
        let _meditationTimeForThreshold: Int
        var totalMeditation: Int = 0
        for point in data {
            guard let poorSignal = point.poorSignal, poorSignal < 50 else { continue }
            guard let meditation = getMeditation(point), meditation > 0 else { continue } // zero means no data
            guard let threshold = point.level else { continue }
            if meditation >= threshold {
                totalMeditation += 1
            }
        }
        _meditationTimeForThreshold = totalMeditation


        let _gte90Time: Int
        var totalGte90: Int = 0
        for point in data {
            guard let poorSignal = point.poorSignal, poorSignal < 50 else { continue }
            guard let meditation = getMeditation(point), meditation > 0 else { continue } // zero means no data
            if meditation >= 90 {
                totalGte90 += 1
            }
        }
        _gte90Time = totalGte90

        
        let _gte80MaxSolidTime: Int
        var maxGte80SolidTime = 0
        var gte80Accumulator = 0
        for point in data {
            guard let poorSignal = point.poorSignal, poorSignal < 50 else {
                gte80Accumulator = 0
                continue
            }
            guard let meditation = getMeditation(point), meditation > 0 else {
                gte80Accumulator = 0
                continue
            }
            if meditation >= 80 {
                gte80Accumulator += 1
                if maxGte80SolidTime < gte80Accumulator {
                    maxGte80SolidTime = gte80Accumulator
                }
                continue
            }
            gte80Accumulator = 0
        }
        _gte80MaxSolidTime = maxGte80SolidTime
        
        
        let _tapsCount: Int
        _tapsCount = data.filter({ point in point.tap }).count
        
        
        return Statistics(
            sessionTime: _sessionTime,
            averageLevel: _averageLevel,
            meditationTimeForThreshold: _meditationTimeForThreshold,
            gte90Time: _gte90Time,
            gte80MaxSolidTime: _gte80MaxSolidTime,
            tapsCount: _tapsCount
        )
    }
}
