//
//  MainVC+distractionCounterOnly.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 18.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//


extension MainVC {
    var clock_isRunning: Bool {
        clock_timer != nil
    }

    func clock_startUIUpdateTimer() {
        guard clock_timer == nil else {
            return
        }
        clock_timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(clock_onUIUpdateTimer),
            userInfo: nil,
            repeats: true
        )
    }

    func clock_Stopped() {
        clock_timer?.invalidate()
        clock_timer = nil
        sessionHasStopped()
    }

    func clock_Started() {
        clock_startUIUpdateTimer()
        sessionHasStarted()
    }

    @objc func clock_onUIUpdateTimer() {
        // Set feedback frequently, ahead of showing full statistics.
        setFeedback(session: MeditationSession.current)
        
        // run multiple times, and select the closest
        if clock_lastTimerHit == nil ||
            (
                !HeadsetController.shared.isActive ||
                MeditationSession.current?.lastPointReady() ?? false
            ) &&
            (-clock_lastTimerHit!.timeIntervalSinceNow >= 1)
        {
            clock_lastTimerHit = Date()
            sessionUpdateEvent()  // CPU-intensive task. Run only once a second.
        }
    }

    func clock_Paused() {
        clock_timer?.invalidate()
        clock_timer = nil
        MeditationSession.current?.addPause(at: Date())
        sessionHasPaused()
    }
    func clock_Resumed() {
        MeditationSession.current?.addResume(at: Date())
        clock_startUIUpdateTimer()
        sessionHasResumed()
    }
}
