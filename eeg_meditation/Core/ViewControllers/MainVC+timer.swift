//
//  MainVC+timer.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 18.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation

extension MainVC {
    var timer_isRunning: Bool { timer != nil }

    func timerButtonLongTap(buttonId: Int) {
        print("timerButtonLongTap \(buttonId)")
        // TODO show UIPickerView for minutes and seconds
        // TODO get button ID, and save the value to settings
    }

    func updateTimerTime() {
        // timeLeft computed ditamically.
        // just restart the timer object.
        if timer_isRunning {
            pauseTimer() 
            resumeTimer()
        }
    }

    func getCurrentTimerSetting() -> TimeInterval {
        var time: Int = 1
        if buttonTimer1.isSelected { time = SettingsModel.shared.timerButton1 }
        if buttonTimer2.isSelected { time = SettingsModel.shared.timerButton2 }
        if buttonTimer3.isSelected { time = SettingsModel.shared.timerButton3 }
        if buttonTimer4.isSelected { time = SettingsModel.shared.timerButton4 }
        if buttonTimer5.isSelected { time = SettingsModel.shared.timerButton5 }
        if buttonTimer6.isSelected { time = SettingsModel.shared.timerButton6 }
        if buttonTimer7.isSelected { time = SettingsModel.shared.timerButton7 }
        if buttonTimer8.isSelected { time = SettingsModel.shared.timerButton8 }
        return TimeInterval(time) * 60.0 // minutes => seconds
    }

    var timeLeft: TimeInterval { getCurrentTimerSetting() - timePassed }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeLeft, target: self, selector: #selector(timerEnded), userInfo: nil, repeats: false)
        timePassed = 0
        timerObjectStartTime = Date()
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        timePassed = 0
        timerObjectStartTime = nil
    }

    func pauseTimer() {
        if let timerObjectStartTime = timerObjectStartTime {
            timePassed += -(timerObjectStartTime.timeIntervalSinceNow)
        }
        timer?.invalidate()
        timer = nil
        timerObjectStartTime = nil
    }

    func resumeTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: timeLeft,
            target: self,
            selector: #selector(timerEnded),
            userInfo: nil,
            repeats: false
        )
        timerObjectStartTime = Date()
    }

    @objc func timerEnded() {
        if let timerObjectStartTime = timerObjectStartTime {
            timePassed += -timerObjectStartTime.timeIntervalSinceNow
        }
        guard timeLeft < 1.0 else { // settings may change
            resumeTimer()
            return
        }

        cancelTimer()
        stopSession()
        timerProgressBar.setProgress(1.0, animated: true)
        SoundCenter.shared.playTimerEnded()
    }


    var progress: Double {
        guard timer_isRunning || timeLeft > 0 else { return 0 }
        let _timePassed = timePassed - (timerObjectStartTime?.timeIntervalSinceNow ?? 0)
        let timeTotal = getCurrentTimerSetting()
        return _timePassed / timeTotal
    }

    func updateTimerProgress() {
        timerProgressBar.setProgress(Float(progress), animated: true)
    }
}
