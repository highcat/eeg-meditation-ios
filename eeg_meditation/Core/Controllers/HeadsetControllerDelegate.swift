//
//  HeadsetControllerDelegate.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 13/02/2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation

protocol HeadsetControllerDelegate: class {
    func headsetController_DeviceFound(devName: String, mfgID: String, deviceID: String)
    func headsetController_Connected()
    func headsetController_Disconnected()
    func headsetController_DisconnectForcedByHeadsetController()
    func headsetController_SignalStrengthChanged(signalStrength: HeadsetController.SignalStrength)
    func headsetController_MeditationChanged()

    func headsetController_Paused()
    func headsetController_Resumed()
}
