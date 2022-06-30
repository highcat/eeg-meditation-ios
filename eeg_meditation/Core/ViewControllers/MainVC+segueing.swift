//
//  MainVC+segueing.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 22.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit


extension MainVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "manualOpenDistractionCounter":  // XXX identifier can be broken, use constants
            if let _ = segue.destination as? DistractionCounterVC {
                //
            }
        default: break
        }
    }

    // Back from distraction counter
    @IBAction func backTo(segue: UIStoryboardSegue) {
        if let _ = segue.source as? DistractionCounterVC {
            // clock_startUIUpdateTimer()  // starts anyway
        }

        if let _ = segue as? LaunchTutorialSegue {
            print(" --- Need Launch Tutorial  --- ")
            self.stopSession() // stop if something is running
            // TODO launch tutorial
            return
        }
    }
}



