//
//  secondsToHMS.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 20.05.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation

func secondsToHMS(_ seconds : Int) -> String {
    let hms: [Int] = [seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60]
    var hmsStripped: [Int] = []

    var removing: Bool = true
    for i in hms {
        if i > 0 {
            removing = false
        }
        if !removing {
            hmsStripped.append(i)
        }
    }
    let hmsStrings = hmsStripped.map { i in String(format: "%02d", i) }
    if hmsStrings.count == 0 {
        return "0"
    }
    var out = hmsStrings.joined(separator: ":")
    let startIdx = out.startIndex
    if out[startIdx] == "0" {
        out = String(out[out.index(out.startIndex, offsetBy: 1)...])  // remove 1st zero
    }
    return out
}
