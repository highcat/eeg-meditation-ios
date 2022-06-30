//
//  MainVC+meditationSessionActions.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 18.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit
import RxSwift


extension MainVC {
    func connectSession() {
        if devices.count > 0 {
            // Session handled by HeadsetController
            MeditationSession.current = MeditationSession(context: AppDelegate.viewContext)
            // FIXME handle multiple devices in next versions

            // FIXME this conversion is too verbose
            var cutoff: HeadsetController.Cutoff = .dontChange
            if SettingsModel.shared.frequencyControlEnabled {
                switch SettingsModel.shared.frequencyCutoff {
                case .cutoff50:
                    cutoff = .hz50
                case .cutoff60:
                    cutoff = .hz60
                }
            }

            HeadsetController.shared.connect(
                to: devices[0].deviceID,
                setCutoff: cutoff
            )
            clock_Started()
        } else {
            let alert = UIAlertController(
                title: "No devices connected",
                message: "Please switch on your NeuroSky EEG headset.\n\nIf you don't have one, you can run distraction counter session!",
                preferredStyle: .alert
            )

            let action = UIAlertAction(
                title: "Start Distraction Counter",
                style: .default
            ) { (action: UIAlertAction) -> Void in
                self.clickerSwitch.setOn(true, animated: true)
                // Session with distraction controller only
                self.showClickerState() {
                    MeditationSession.current = MeditationSession(context: AppDelegate.viewContext)
                    self.headsetStateIcon.image = self.hi_noSignal
                    self.headsetStateText.text = "counter only"
                    self.clock_Started()
                }
            }
            alert.addAction(action)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            self.present(alert, animated: true)
        }
    }

    func pauseResumeToggle() {
        var paused = !clock_isRunning

        if HeadsetController.shared.isActive {
            if paused && devices.count > 0 {
                headsetStateIcon.image = hi_connecting
                headsetStateText.text = "connecting..."
                HeadsetController.shared.resume(with: devices[0].deviceID)
            } else {
                headsetStateIcon.image = hi_connecting
                headsetStateText.text = "paused"
                HeadsetController.shared.pause()
            }
        }
        if clock_isRunning {
            clock_Paused()
            paused = true
        } else {
            clock_Resumed()
            paused = false
        }

        if !paused {
            showChart(session: MeditationSession.current, forLastSeconds: 20)
            self.startFeedback()
            if timerSwitch.isOn {
                resumeTimer()
            }
        } else {
            showChart(session: MeditationSession.current)
            lineChart.backgroundColor = UIColor.white // FIXME system background
            SoundCenter.shared.stopFeedback()
            if timerSwitch.isOn {
                pauseTimer()
            }
        }
    }

    func stopSession() {
        if HeadsetController.shared.isActive {
            HeadsetController.shared.disconnect()
        }
        clock_Stopped()
    }


    func sessionHasStarted() {
        guard let session = MeditationSession.current, !session.isRunning else { return }
        // UI logic
        buttonConnect.isEnabled = false
        buttonPause.isEnabled = true
        buttonStop.isEnabled = true
        clearChart() // must have for counter-only sessions
        session.start()
        // initial user settings
        session.addLevelChange(newLevel: SettingsModel.shared.meditationLevel, at: Date())

        if clickerSwitch.isOn {
            // segue back with visual delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.performSegue(withIdentifier: "manualOpenDistractionCounter", sender: self)
            }
        }

        // Special logic
        if timerSwitch.isOn {
            startTimer()
        }
        UIApplication.shared.isIdleTimerDisabled = true // let the user stare into the screen while session is running
        print("startfeedback")
        startFeedback()
    }

    func sessionHasStopped() {
        // stop synchronously to neglect additional incoming data.
        MeditationSession.current?.stop()
        
        func _sessionHasStopped() {
            // UI logic
            buttonConnect.isEnabled = true
            buttonPause.isEnabled = false
            buttonStop.isEnabled = false

            // Special logic
            UIApplication.shared.isIdleTimerDisabled = false
            cancelTimer()
            lineChart.backgroundColor = UIColor.white // FIXME system background
            SoundCenter.shared.stopFeedback()
            try? MeditationSession.current?.save()  // TODO show alert on exception, send to Sentry

            // Show results
            lineChart.backgroundColor = UIColor.white // FIXME system background
            showChart(session: MeditationSession.current)
            showStatistics(session: MeditationSession.current)
            meditationLevelIndicator.text = "--" // no current value
        }
        //
        if let pvc = self.presentedViewController {
            pvc.dismiss(animated: true) {
                _sessionHasStopped()
            }
        } else {
            _sessionHasStopped()
        }
    }

    func sessionHasPaused() {
        buttonPause.setTitle("RESUME", for: .normal)
        buttonStop.isEnabled = false
        meditationLevelIndicator.text = "--"
    }
    func sessionHasResumed() {
        buttonPause.setTitle("PAUSE", for: .normal)
        buttonStop.isEnabled = true
    }


    // Run this every time something changed while session is running
    func sessionUpdateEvent() {
        setFeedback(session: MeditationSession.current)
        
        if view.window != nil && !view.isHidden {
            // showChart takes about 5% CPU speed
            // - if shown every second
            // - on iPhone 6 Plus
            showChart(session: MeditationSession.current, forLastSeconds: 20)
            // showStatistics is CPU-intense, as it runs over entire session data
            showStatistics(session: MeditationSession.current)
            
            updateTimerProgress()
        }
    }
    
    
    func setFeedback(session: MeditationSession?) {
        guard let session = session else {
            return
        }
        var meditation: Int?
        
        switch SettingsModel.shared.meditationAlgo {
        case .eSense:
            let merged = session.mergedData(forLastSeconds: 1)
            if merged.count > 0 {
                if let m: Int32 = merged[0].meditation {
                    meditation = Int(m)
                }
            }
        case .vasylVernyhora2021:
            let merged = session.mergedData(forLastSeconds: ALGO_ANALYSIS_TAIL_SIZE + 2)
            if merged.count > 0 {
                if let m = vasylMeditation(
                    sequence: merged,
                    offset: merged.count-1,
                    guruMode: SettingsModel.shared.algoModifier == .guruMode20
                ) {
                    meditation = m
                } else {
                    // try again, but treat last second issue
                    meditation = vasylMeditation(
                        sequence: merged,
                        offset: merged.count-2, // last second hack
                        guruMode: SettingsModel.shared.algoModifier == .guruMode20
                    )
                }
            }
        }

        guruModeIndicator.isHidden = !(
            SettingsModel.shared.algoModifier == .guruMode20 &&
            SettingsModel.shared.meditationAlgo == .vasylVernyhora2021
        )

        guard let meditation = meditation else {
            meditationLevelIndicator.text = "---"
            // TODO notify about "bad signal" instead
            SoundCenter.shared.setFeedbackVolume(volume: 0.0)
            self.lineChart.backgroundColor = UIColor.white // FIXME system background
            return
        }
        meditationLevelIndicator.text = "\(meditation)"

        // Visual feedback
        if meditation >= SettingsModel.shared.meditationLevel {
            UIView.animate(withDuration: 1.0) {
                self.lineChart.backgroundColor = #colorLiteral(red: 0.3254957199, green: 0.9272906184, blue: 1, alpha: 1)  // Fixme animation isn't working here
            }
        } else {
            UIView.animate(withDuration: 1.0) {
                self.lineChart.backgroundColor = UIColor.white // FIXME system background
            }
        }

#if DEBUG
        // SettingsModel.shared.meditationLevel = 40
#endif
                
                
        switch SettingsModel.shared.feedbackOn {
        case .exceeded:
            if meditation >= SettingsModel.shared.meditationLevel {
                SoundCenter.shared.setFeedbackVolume(volume: 1.0)
            } else {
                SoundCenter.shared.setFeedbackVolume(volume: 0.0)
            }
        case .notReached:
            if meditation >= SettingsModel.shared.meditationLevel {
                SoundCenter.shared.setFeedbackVolume(volume: 0.0)
            } else {
                SoundCenter.shared.setFeedbackVolume(volume: 1.0)
            }
        }
    }


    func showStatistics(session: MeditationSession?) {
        func setPlaceholder(_ label: UILabel) {
            label.text = "--"
        }

        averageLevelIndicator.text = "--"
        sessionTimeIndicator.text = "--"
        meditationTimeIndicator.text = "--"
        gte90TimeIndicator.text = "--"
        gte80MaxSolidTimeIndicator.text = "--"
        clickCount.text = ""
        clickCount.isHidden = true
        guard let stats = session?.calcStatistics() else {
            return
        }
        
        
        if stats.averageLevel > 0 {
            averageLevelIndicator.text = "\(stats.averageLevel)"
        }
        sessionTimeIndicator.text = secondsToHMS(stats.sessionTime)
        meditationTimeIndicator.text = secondsToHMS(stats.meditationTimeForThreshold)
        gte90TimeIndicator.text = secondsToHMS(stats.gte90Time)
        gte80MaxSolidTimeIndicator.text = secondsToHMS(stats.gte80MaxSolidTime)
        if stats.tapsCount > 0, SettingsModel.shared.counterOn {
            self.clickCount.text = "\(stats.tapsCount)"
            self.clickCount.isHidden = false
        }
    }
}
