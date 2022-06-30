//
//  vasyl.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 24.11.2021.
//  Copyright © 2021 Alex Lokk. All rights reserved.
//


// Vasyl formula https://scriptures.ru/yoga/eeg_voprosy_i_otvety.htm#formula2
// min(avg(
//     (a1+(0.8*a2))/(b2+b1+(0.4*t)+(0.08*d)),
//     LAST_4_SECONDS)/1.5,
//     1
// )
//
// Vasyl 2nd formula:
// min(avg(
//     75 * (a1+(0.8*a2))/(b2+b1+(0.4*t)+(0.08*d)) - 10,
//     LAST_4_SECONDS),
//     100
// )

let ALGO_ANALYSIS_TAIL_SIZE = 4  // number or extra records to keep for algorithms


func vasylMeditation(sequence: [MeditationSession.EEGDataPoint], offset: Int, guruMode: Bool) -> Int? {
    let AVG_SECONDS = 4
    assert(ALGO_ANALYSIS_TAIL_SIZE >= AVG_SECONDS)

    guard offset - (AVG_SECONDS-1) >= 0 && sequence.count > offset else {
        return nil  // not enough data collected yet.
    }
    // Note that the sequence can contain gaps, where no data returned, e.g. because of hardware failure.
    // We just get average neglecting gaps.
    var momentalValues: [Double] = []
    for i in 0..<AVG_SECONDS {
        guard let momentalValue = _vasylMeditationMomental(point: sequence[offset-i]) else {
            return nil  // entries contain not enough data
        }
        momentalValues.append(momentalValue)
    }

    var meditation = avg(momentalValues)
    if guruMode {
        meditation -= 20
        if meditation < 0 {
            meditation = 0
        }
    }
    
    if meditation > 100.0 {
        meditation = 100.0
        // Can be bigger, up to 200 and more.
        // But we consider cropping to 100 to give good enough meditation value.
    }
    return Int(meditation)
}


func _vasylMeditationMomental(point: MeditationSession.EEGDataPoint) -> Double? {
    guard let _lowAlpha = point.lowAlpha,
          let _highAlpha = point.highAlpha,
          let _lowBeta = point.lowBeta,
          let _highBeta = point.highBeta,
          let _theta = point.theta,
          let _delta = point.delta,
          let _lowGamma = point.lowGamma,
          let _midGamma = point.midGamma
          else {
        return nil
    }
    var lowAlpha = Double(_lowAlpha)
    var highAlpha = Double(_highAlpha)
    var lowBeta = Double(_lowBeta)
    var highBeta = Double(_highBeta)
    var theta = Double(_theta)
    var delta = Double(_delta)
    var lowGamma = Double(_lowGamma)
    var midGamma = Double(_midGamma)

    let totalPower: Double = delta + theta + lowAlpha + highAlpha + lowBeta + highBeta + lowGamma + midGamma
    // (возможно, гаммы лучше не учитывать, так как они могут достигать 500 000 при неправильно установленной частоте фильтра)

    lowAlpha = sqrt(lowAlpha/totalPower)
    highAlpha = sqrt(highAlpha/totalPower)
    lowBeta = sqrt(lowBeta/totalPower)
    highBeta = sqrt(highBeta/totalPower)
    theta = sqrt(theta/totalPower)
    delta = sqrt(delta/totalPower)
    lowGamma = sqrt(lowGamma/totalPower)
    midGamma = sqrt(midGamma/totalPower)

    return 75 * (
        lowAlpha + 0.8*highAlpha
    ) / (
        lowBeta +
        highBeta +
        0.4*theta +
        0.08*delta
    ) - 10
}


fileprivate func avg(_ numbers: [Double]) -> Double {
    var sum: Double = 0
    for number in numbers {
        sum += number
    }
    return sum / Double(numbers.count)
}

