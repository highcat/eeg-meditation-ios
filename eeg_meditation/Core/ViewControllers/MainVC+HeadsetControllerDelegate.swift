//
//  MainVC+HeadsetControllerDelegate.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 18.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit


extension MainVC: HeadsetControllerDelegate {
    func headsetController_DeviceFound(devName: String, mfgID: String, deviceID: String) {
        devices.insert(DeviceInfo(devName: devName, mfgID: mfgID, deviceID: deviceID), at: 0)
        print(devName, mfgID, deviceID)
        headsetStateText.text = "device found"
    }

    func headsetController_Connected() {
        headsetStateIcon.image = hi_connecting
        headsetStateText.text = "connecting..."
        lastPoorSignalValue = .noSignal  // force initial, to pay signal when first connected

        buttonConnect.isEnabled = false
        buttonPause.isEnabled = false
        buttonStop.isEnabled = true
    }

    func headsetController_SignalStrengthChanged(signalStrength: HeadsetController.SignalStrength) {
        buttonPause.isEnabled = true
        switch signalStrength {
        case .ok:
            headsetStateIcon.image = hi_ok
            headsetStateText.text = "connected"
            if lastPoorSignalValue == .noSignal {
                SoundCenter.shared.playConnected()
            }
        case .yellow3:
            headsetStateIcon.image = hi_yellow3
            headsetStateText.text = "connected..."
        case .yellow2:
            headsetStateIcon.image = hi_yellow2
            headsetStateText.text = "poor signal"
        case .yellow1:
            headsetStateIcon.image = hi_yellow1
            headsetStateText.text = "poor signal"
        case .noSignal:
            headsetStateIcon.image = hi_noSignal
            headsetStateText.text = "no signal"
        }
        lastPoorSignalValue = signalStrength
    }

    func headsetController_MeditationChanged() {
    }

    func headsetController_Paused() {
        clock_Paused()
    }

    func headsetController_Resumed() {
        clock_Resumed()
    }

    func headsetController_Disconnected() {
        print("Disconnected.")

        // TODO XXX this may run from different thread
        headsetStateIcon.image = hi_noSignal
        headsetStateText.text = "disconnected"
        clock_Stopped()

        // Quick fix to search devices again after some has disconnected
        self.devices.removeAll()
        HeadsetController.shared.searchAgain()
    }
    
    func headsetController_DisconnectForcedByHeadsetController() {
        // FIXME this callback occasinally & repeatedly happends in background.
        // Try to reproduce later:
        // 0. Debug cable should be disconnected
        // 1. take a session, 1 minute
        // 2. Switch off the headset ???
        // ???
        // 4. Wait.

        // Quick fix:
        // play disconnection only if session running
        // or if the stage is active (i.e. session not started yet, but assumed to start)
        if MeditationSession.current?.isRunning ?? false || UIApplication.shared.applicationState == .active {
            SoundCenter.shared.playSignalLost()
        }
        clock_Stopped()
    }
}
