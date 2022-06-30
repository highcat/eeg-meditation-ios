//
//  PlainStatsCell.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 20.05.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Charts
import UIKit


class PlainStatsCell: UITableViewCell {
    @IBOutlet var info: UILabel!
    @IBOutlet var avg: UILabel!
    @IBOutlet var lineChart: LineChartView!

    func setData(model: MeditationSession) {
        guard let startTime = model.startTime else { return }
        let dateFormatter = DateFormatter()
        // dateFormatter.locale = Locale.init(identifier: "en_US_POPSIX")
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let time = dateFormatter.string(from: startTime)

        let stats = model.calcStatistics()
        
        info.text = "\(time) - session time: \(secondsToHMS(stats.sessionTime))"
        avg.text = "avg: \(stats.averageLevel)"

        
        SessionChartVM.show(model, on: lineChart)
    }

    override func prepareForReuse() {
        info.text = ""
        SessionChartVM.clear(lineChart)
    }
}

