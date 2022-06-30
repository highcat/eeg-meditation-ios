//
//  Permissions.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 13/02/2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit


func EEGM_handleBluetoothPermissions(_ central: CBCentralManager) {
    switch central.state {
    case .unknown:  // State unknown, update imminent.
        break
    case .resetting:  // The connection with the system service was momentarily lost, update imminent.
        break
    case .unsupported:  // The platform doesn't support the Bluetooth Low Energy Central/Client role.
        NotificationHelper.modal(title: "Bluetooth required", message: "Your device appears to be missing Bluetooth support. =( It's needed to connect EEG headsets.", actionTitle: "Ok")
        break
    case .unauthorized:  // The application is not authorized to use the Bluetooth Low Energy role.
        // TODO: point user to settings from here
        func promptToSettings() {
            let alertController = UIAlertController(
                title: "Bluetooth access required",
                message: "You denied Bluetooth access for this app before. To use EEG headsets, please go to settings and allow Bluetooth connections to this app.",
                preferredStyle: .alert
            )                                                                                                                                                              
            alertController.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                // The app would be killed by iOS on permission change.
                // => EXIT.
            }))
            NotificationHelper.visibleVC?.present(alertController, animated: true, completion: nil)
        }
        if #available(iOS 13.0, *) {
            switch central.authorization {
            case .notDetermined:  // User has not yet made a choice with regards to this application.
                break
            case .restricted:  // This application is not authorized to use bluetooth. The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place.
                NotificationHelper.modal(title: "Bluetooth required", message: "Your Bluetooth appears to be restricted. Please make sure you have access to it on your device.", actionTitle: "Ok")
            case .denied: // User has explicitly denied this application from using bluetooth.

                promptToSettings()
            case .allowedAlways:  // User has authorized this application to use bluetooth always.
                break
            @unknown default:
                break
            }
        } else {
            // < iOS 13.0
            promptToSettings()
        }
    case .poweredOff:  // Bluetooth is currently powered off.
        NotificationHelper.modal(title: "Please enable Bluetooth", message: "Your Bluetooth appears to be off. Please enable it to use EEG headset.", actionTitle: "Ok")
    case .poweredOn:  // Powered on and ready to connect
        break
    @unknown default:
        break
    }
}
