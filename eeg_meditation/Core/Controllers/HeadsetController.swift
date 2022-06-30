//
//  HeadsetController.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 12/02/2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit
import CoreBluetooth


class HeadsetController: NSObject,
    CBCentralManagerDelegate
{
    static var shared = HeadsetController()  // lazy by default
    public weak var delegate: HeadsetControllerDelegate?

    private var centralManager: CBCentralManager!
    private var lastBluetoothState: CBManagerState = CBManagerState.unknown

    private let mwDevice: MWMDevice = MWMDevice.sharedInstance()
    private(set) var isPaused: Bool = false
    var isRunning: Bool {
        backgroundTaskId != .invalid
    }
    var isActive: Bool {
        isRunning || isPaused
    }
    var manualDisconnect: Bool = false

    // Debug mode mark for simulators
    var deviceIsStub: Bool { mwDevice.getVersion() == "STUB" }

    enum Cutoff {
        case hz50
        case hz60
        case dontChange
    }
    var cutoff: Cutoff = .dontChange

    enum SignalStrength {
        case ok
        case yellow3
        case yellow2
        case yellow1
        case noSignal
    }
    private var lastPoorSignalValue: SignalStrength = .noSignal
    private var lastPoorSignalTimestamp: Date = Date(timeIntervalSince1970: 0)

    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        mwDevice.delegate = self
        print("MW SDK: \(mwDevice.getVersion() ?? "none")")
    }

    func searchAgain() {
        // Quick fix to search devices again after some has disconnected
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        lastBluetoothState = central.state
        EEGM_handleBluetoothPermissions(central)
        switch central.state {
        case .poweredOn:
            print("++++ Start scanning")
            // FIXME:
            // after this line, accidentially gives error "[CoreBluetooth] API MISUSE: <CBCentralManager: 0x28167ca10> can only accept this command while in the powered on state"
            // try restarting the app from XCode many times to get this error.
            // - This happens even w/o Neurosky connected
            // - depends on phone/OS:
            // - - reproduced on iOS 13.3.1, iPhone 7 plus
            // - - not happens on iOS 12.4.5, iPhone 6 plus
            //
            // + NeuroSky can be held by another device

            // Workaround: small delay helps
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.mwDevice.scanDevice()
            }
        default:
            print("---- NEED stop scanning")
        }

    }

    func setCutoff(cutoff: Cutoff) {
        // TODO what is baud rate ??? does it affect anything?
        // FIXME what happens if device is not connected?
        switch cutoff {
        case .hz50:
            mwDevice.writeConfig(TGMWMConfigCMD._ChangeNotchTo_50)
            print(" notch set to 50 -")
        case .hz60:
            mwDevice.writeConfig(TGMWMConfigCMD._ChangeNotchTo_60)
            print(" notch set to 60 -")
        case .dontChange:
            break
        }
    }

    // never calls? FIXME remove
    func mwmBaudRate(_ baudRate: Int32, notchFilter: Int32) {
        print("mwmBaudRate: \(baudRate), notch: \(notchFilter)")
    }

    func connect(to deviceID: String, setCutoff: Cutoff = .dontChange) {
        guard !isRunning else { return }
        manualDisconnect = false
        isPaused = false
        self.cutoff = setCutoff
        mwDevice.connect(deviceID)
    }

    func pause() {
        endBackgroundTask()
        isPaused = true // disables "disconnect" call delegation
        mwDevice.disconnectDevice()
        centralManager.stopScan()
    }
    func resume(with deviceID: String) {
        startBackgroundTask()
        mwDevice.connect(deviceID)
        centralManager.scanForPeripherals(withServices: [])
    }

    func disconnect() {
        manualDisconnect = true
        mwDevice.disconnectDevice()
        // TODO store the data to session,
        // and end BG task synchronously
        endBackgroundTask()
    }
}


// MARK: MWM's delegate
// XXX these can run in any thread.
// BLE devices may run these in main thread, while older NeuroSky headsets won't.
extension HeadsetController: MWMDelegate {

    func deviceFound(_ devName: String!, mfgID: String!, deviceID: String!) {
        print("MindWave: DEVICE FOUND: \(devName ?? "nil")")
        DispatchQueue.main.async {
            self.delegate?.headsetController_DeviceFound(devName: devName, mfgID: mfgID, deviceID: deviceID)
        }
    }

    // XXX can run in any thread
    func didConnect() {
        if self.isPaused {
            let at = Date()
            DispatchQueue.main.async {
                MeditationSession.current?.addResume(at: at)
                self.delegate?.headsetController_Resumed()
            }
            self.isPaused = false
            return
        }
        self.setCutoff(cutoff: self.cutoff)
        DispatchQueue.main.async {
            self.delegate?.headsetController_Connected()
        }
        self.startBackgroundTask()
    }

    // XXX can run in any thread
    func didDisconnect() {
        // dispatch not always needed,
        // FIXME check: this very method caused issue if device disconnected
        if self.isPaused {
            let at = Date()
            DispatchQueue.main.async {
                MeditationSession.current?.addPause(at: at)
                self.delegate?.headsetController_Paused()
            }
            return
        }
        if !self.manualDisconnect {
            DispatchQueue.main.async {
                self.delegate?.headsetController_DisconnectForcedByHeadsetController()
            }
        }
        DispatchQueue.main.async {
            self.delegate?.headsetController_Disconnected()
        }
        self.endBackgroundTask()

    }

    // XXX can run in any thread
    func eSense(_ poorSignal: Int32, attention: Int32, meditation: Int32) {

        // poorSignal: from 0 to 200, according to documentation.
        // practically: 200 after few seconds of forehead contact full disconnection.
        let at = Date()
        DispatchQueue.main.async {
            MeditationSession.current?.addESense(poorSignal: poorSignal, attention: attention, meditation: meditation, at: at)
            self.delegate?.headsetController_MeditationChanged() // FIXME use simple timer instead
        }
        
        var ss: SignalStrength = .noSignal
        switch poorSignal {
        case Int32.min...5:
            ss = .ok
        case 5..<50:
            ss = .yellow3
        case 50..<100:
            ss = .yellow2
        case 100..<200:
            ss = .yellow1
        case 200...Int32.max:
            ss = .noSignal
        default:
            ss = .noSignal
        }

        // TODO if signal level is low, don't take meditation levels into account!
        //   - MWM just returns old values, which is inappropriate.

        DispatchQueue.main.async {
            self.delegate?.headsetController_SignalStrengthChanged(signalStrength: ss)
        }
        if ss == .noSignal {
            if -lastPoorSignalTimestamp.timeIntervalSinceNow > 10 { // 10 seconds till force disconnect
                endBackgroundTask()
                mwDevice.disconnectDevice()
            }
        }
        if lastPoorSignalValue != ss {
            lastPoorSignalTimestamp = Date()
            lastPoorSignalValue = ss
        }

        // debug
        if UIApplication.shared.applicationState == .background {
            if UIApplication.shared.backgroundTimeRemaining > 24.0 * 60 * 60 {
                print("Background remaining seconds:  **A LOT**")
            } else {
                print("Background remaining seconds: \(UIApplication.shared.backgroundTimeRemaining)")
            }
        }
    }

    // XXX can run in any thread
    func eegPowerDelta(_ delta: Int32, theta: Int32, lowAlpha: Int32, highAlpha: Int32) {
        let at = Date()
        DispatchQueue.main.async {
            MeditationSession.current?.addPowerDelta(delta: delta, theta: theta, lowAlpha: lowAlpha, highAlpha: highAlpha, at: at)
            self.delegate?.headsetController_MeditationChanged() // FIXME use simple timer instead
        }

    }

    // XXX can run in any thread
    func eegPowerLowBeta(_ lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32) {
        let at = Date()
        DispatchQueue.main.async {
            MeditationSession.current?.addPowerLowBeta(lowBeta: lowBeta, highBeta: highBeta, lowGamma: lowGamma, midGamma: midGamma, at: at)
            self.delegate?.headsetController_MeditationChanged() // FIXME use simple timer instead
        }
        // TODO detect noise by midGamma.
        // 1. Ignore errorneous values <1'000 and >5'000'000
        // 2. Collect average value for 1, 2, and 3 seconds
        // 3. If sum of them is >200'000, then show danger beakon,
        //    and ask to user change location or switch device configuration.

        // // noise removal changing
        // mwDevice.writeConfig(._ChangeNotchTo_50)
        // mwDevice.writeConfig(._ChangeNotchTo_60)
    }

    // Bluetooth exception event by MWM
    // XXX can run in any thread
    func exceptionMessage(_ eventType: TGBleExceptionEvent) {
        print("Bluetooth exception \(eventType)")
        // TODO show some message to user / send to Sentry
        switch eventType {
        case .unexpectedEvent:
            break
        case .configurationModeCanNotBeChanged:
            break
        case .failedOtherOperationInProgress:
            break
        case .connectFailedSuspectKeyMismatch:
            break
        case .possibleResetDetect:
            break
        case .newConnectionEstablished:
            break
        case .storedConnectionInvalid:
            break
        case .connectHeadSetDirectoryFailed:
            break
        case .bluetoothModuleError:
            break
        case .noMfgDatainAdvertisement:
            break
        @unknown default:
            break
        }
    }
}


// MARK: Background task stuff.
extension HeadsetController {
    private func startBackgroundTask() {
        print("START BG Task")
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "EEG meditation data capture", expirationHandler: appEndBackgroundTaskHandler)
        assert(backgroundTaskId != .invalid)
    }
    private func endBackgroundTask() {
        print("END BG Task")
        if backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = .invalid
        }
    }

    private func appEndBackgroundTaskHandler(){
        print("BG Task had EXPIRED")
        endBackgroundTask()
        DispatchQueue.main.async {
            self.delegate?.headsetController_DisconnectForcedByHeadsetController()
        }
    }
}
