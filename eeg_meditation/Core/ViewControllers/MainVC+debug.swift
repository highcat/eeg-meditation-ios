//
//  MainVC+debug.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 28.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation

// For making screenshots from simulators
extension MainVC {
    func showDebugState() {
        print("DEVICE IS STUB: debug mode")
        let session = MeditationSession.createExample()
        try? session.save()
        
        showChart(session: session)
        showStatistics(session: session)
    }
}
