//
//  MainVC+showChart.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 18.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit
import Charts
import CoreData


extension MainVC {
    func showChart(session: MeditationSession?, forLastSeconds maxSeconds: Int? = nil) {
        guard let session = session else { return }
        SessionChartVM.show(session, on: lineChart, forLastSeconds: maxSeconds)
        shareResultsPanel.isHidden = false
    }

    func clearChart() {
        SessionChartVM.clear(lineChart)
        shareResultsPanel.isHidden = true
    }
}
