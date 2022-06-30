//
//  SessionChart.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 20.05.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Charts

//
// A sort of simplified ViewModel pattern.
//
class SessionChartVM {
    class func show(_ session: MeditationSession, on lineChart: LineChartView, forLastSeconds maxSeconds: Int? = nil) {

        let analyzedLength: Int? = (maxSeconds != nil) ? (maxSeconds! + ALGO_ANALYSIS_TAIL_SIZE) : nil

        // Get records, restrict by maxSeconds
        var medRecords: [MeditationSession.EEGDataPoint] = {
            let medRecords = session.storedData()
            guard medRecords.count == 0 else {
                if let analyzedLength = analyzedLength {
                    let cropIndex = analyzedLength < medRecords.count ? (medRecords.count - analyzedLength) : medRecords.count
                    return Array(medRecords[cropIndex ..< medRecords.count])
                }
                return medRecords
            }
            return session.mergedData(forLastSeconds: analyzedLength)
        }()

        guard medRecords.count >= 1 else {
            return
        }

        // *** Convert to ChartData ***

        // dataset that forces constant number of seconds on the screen
        var shadowGraphEntries: [ChartDataEntry] = []
        if let maxSeconds = maxSeconds {
            for sec in 0..<maxSeconds {
                shadowGraphEntries.insert(ChartDataEntry(x: Double(-sec), y: 0.0, icon: nil), at: 0)
            }
        }

        // ******* Meditation Data - eSense algorithm
        var eegFound_eSense = false
        var medEntries: [ChartDataEntry] = []
        if SettingsModel.shared.meditationAlgo == .eSense || SettingsModel.shared.showSecondaryAlgo {
            medEntries = medRecords.enumerated().map { i -> ChartDataEntry in
                let med = i.element.meditation ?? -100
                if med != -100 { eegFound_eSense = true }
                var offset = i.offset
                if analyzedLength != nil { // backwards counting
                    offset = -(medRecords.count - (i.offset+1))
                }
                return ChartDataEntry(x: Double(offset), y: Double(med), icon: nil)
            }
            // crop algorithm-related tail
            if let maxSeconds = maxSeconds, let _ = analyzedLength {
                let tailLength = medEntries.count - maxSeconds;
                if tailLength >= 0 {
                    medEntries = Array(medEntries[tailLength...])
                }
            }
            // crop zeroes from beginning/ending
            while let first = medEntries.first, first.y == -100 {
                medEntries.removeFirst()
            }
            while let last = medEntries.last, last.y == -100 {
                medEntries.removeLast()
            }
            // FIXME split the dataset to multiple, or change some settings (if possible)
            // to create visible gaps in data sets.
            // quick fix with zeroes:
            medEntries = medEntries.map { i -> ChartDataEntry in
                ChartDataEntry(x: i.x, y: i.y == -100 ? 0 : i.y, icon: i.icon)
            }
        }



        // ******* Meditation Data - Vasyl Vernyhora's algorithm
        // Requires tail of a sequence.
        var eegFound_vasyl = false
        var vasylMedEntries: [ChartDataEntry] = []
        if SettingsModel.shared.meditationAlgo == .vasylVernyhora2021 || SettingsModel.shared.showSecondaryAlgo {
            vasylMedEntries = medRecords.enumerated().map { i -> ChartDataEntry in
                let med = vasylMeditation(
                    sequence: medRecords,
                    offset: i.offset,
                    guruMode: SettingsModel.shared.algoModifier == .guruMode20
                ) ?? -100 // a mark
                if med > -100 { eegFound_vasyl = true }
                var offset = i.offset
                if analyzedLength != nil { // backwards counting
                    offset = -(medRecords.count - (i.offset+1))
                }
                return ChartDataEntry(x: Double(offset), y: Double(med), icon: nil)
            }
            // crop algorithm-related tail
            if let maxSeconds = maxSeconds, let _ = analyzedLength {
                let tailLength = vasylMedEntries.count - maxSeconds;
                if tailLength >= 0 {
                    vasylMedEntries = Array(vasylMedEntries[tailLength...])
                }
            }
            // crop zeroes from beginning/ending
            while let first = vasylMedEntries.first, first.y == -100 {
                vasylMedEntries.removeFirst()
            }
            while let last = vasylMedEntries.last, last.y == -100 {
                vasylMedEntries.removeLast()
            }
            // FIXME split the dataset to multiple, or change some settings (if possible)
            // to create visible gaps in data sets.
            // quick fix with zeroes:
            vasylMedEntries = vasylMedEntries.map { i -> ChartDataEntry in
                ChartDataEntry(x: i.x, y: i.y == -100 ? 0 : i.y, icon: i.icon)
            }
        }


        // ******* Taps Data
        var tapsFound = false
        var tapEntries: [ChartDataEntry] = medRecords.enumerated().map { i -> ChartDataEntry in
            let tap = i.element.tap ? 30 : -5.0  // quick hack
            if i.element.tap { tapsFound = true }
            var offset = i.offset
            if analyzedLength != nil { // backwards counting
                offset = -(medRecords.count - (i.offset+1))
            }
            return ChartDataEntry(x: Double(offset), y: Double(tap), icon: nil)
        }
        // fill records with zeroes, to keep constant number of seconds on the screen
        if let analyzedLength = analyzedLength, tapEntries.count <= analyzedLength {
            let toAdd = analyzedLength-tapEntries.count + 1
            var lastReverseOffset = tapEntries.count > 0 ? Int(tapEntries[0].x) : 0
            for _ in 0..<toAdd {
                lastReverseOffset -= 1
                tapEntries.insert(ChartDataEntry(x: Double(lastReverseOffset), y: 0.0, icon: nil), at: 0)
            }
        }
        // crop tail
        if let maxSeconds = maxSeconds, let analyzedLength = analyzedLength {
            let tailLength = tapEntries.count - maxSeconds;
            tapEntries = Array(tapEntries[tailLength...])
        }


        let shadowGraphDataSet = LineChartDataSet(entries: shadowGraphEntries, label: "")
        shadowGraphDataSet.drawIconsEnabled = false
        shadowGraphDataSet.drawCirclesEnabled = false
        // Line color
        shadowGraphDataSet.setColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.0))

        // *** eSense Meditation chart
        let dataSet = LineChartDataSet(entries: medEntries, label: "Meditation")
        // Line style
        dataSet.drawIconsEnabled = false
        dataSet.drawCirclesEnabled = false
        // Line color
        dataSet.setColor(UIColor(red: 80.0/255, green: 80.0/255, blue: 200.0/255, alpha: 1.0))
        // Gradient fill - for main algorithm only
        if SettingsModel.shared.meditationAlgo == .eSense {
            dataSet.fillAlpha = 1
            dataSet.drawFilledEnabled = true
            let gradientColors = [
                ChartColorTemplates.colorFromString("#006699ff").cgColor, // argb
                ChartColorTemplates.colorFromString("#ff6699ff").cgColor,
            ]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
            dataSet.fill = Fill(linearGradient: gradient, angle: 90)
        }


        // *** Vasyl Meditation chart
        let vasylDataSet = LineChartDataSet(entries: vasylMedEntries, label: "Vasyl Meditation")
        // Line style
        vasylDataSet.drawIconsEnabled = false
        vasylDataSet.drawCirclesEnabled = false
        // Line color
        vasylDataSet.setColor(UIColor(red: 201.0/255, green: 80.0/255, blue: 200.0/255, alpha: 1.0))
        // Gradient fill - for main algorithm only
        if SettingsModel.shared.meditationAlgo == .vasylVernyhora2021 {
            vasylDataSet.fillAlpha = 1
            vasylDataSet.drawFilledEnabled = true
            let gradientColors = [
                UIColor(red: 201.0/255, green: 80.0/255, blue: 200.0/255, alpha: 0.0).cgColor,
                UIColor(red: 201.0/255, green: 80.0/255, blue: 200.0/255, alpha: 1.0).cgColor,
            ]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
            vasylDataSet.fill = Fill(linearGradient: gradient, angle: 90)
        }


        // *** Setup clicks chart
        let tapsDataSet = LineChartDataSet(entries: tapEntries, label: "Clicks")
        // Line style
        tapsDataSet.drawIconsEnabled = false
        tapsDataSet.drawCirclesEnabled = false
        // Line color
        tapsDataSet.setColor(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
        tapsDataSet.fillAlpha = 1
        tapsDataSet.drawFilledEnabled = true
        tapsDataSet.fill = Fill(CGColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))

        
        var dataSets: [ChartDataSet] = []
        // Order matters
        dataSets.append(shadowGraphDataSet)
        if tapsFound {
            dataSets.append(tapsDataSet)
        }
        switch SettingsModel.shared.meditationAlgo {
        case .eSense:
            if SettingsModel.shared.showSecondaryAlgo {
                if eegFound_vasyl {
                    dataSets.append(vasylDataSet)
                }
            }
            if eegFound_eSense {
                dataSets.append(dataSet)
            }
        case .vasylVernyhora2021:
            if SettingsModel.shared.showSecondaryAlgo {
                if eegFound_eSense {
                    dataSets.append(dataSet)
                }
            }
            if eegFound_vasyl {
                dataSets.append(vasylDataSet)
            }
        }


        guard dataSets.count > 0 else { return }
        let data = LineChartData(dataSets: dataSets)
        data.setDrawValues(false)

        setChartStyle(on: lineChart)
        lineChart.data = data
    }


    class func clear(_ lineChart: LineChartView) {
        lineChart.data = nil
        lineChart.zoom(scaleX: 0, scaleY: 0, x: 0, y: 0)
    }


    private class func setChartStyle(on lineChart: LineChartView) {
        // Interactions
        lineChart.isUserInteractionEnabled = true
        lineChart.highlightPerTapEnabled = false
        lineChart.highlightPerDragEnabled = false
        lineChart.scaleXEnabled = true
        lineChart.scaleYEnabled = false

        //
        lineChart.legend.enabled = false
        // axis config
        lineChart.xAxis.enabled = true
        lineChart.leftAxis.enabled = true
        lineChart.rightAxis.enabled = true

        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.granularity = 1.0

        lineChart.leftAxis.axisMaximum = 100
        lineChart.leftAxis.axisMinimum = 0
        lineChart.leftAxis.setLabelCount(5, force: false)
        lineChart.leftAxis.granularityEnabled = true
        lineChart.leftAxis.granularity = 1.0
        lineChart.rightAxis.axisMaximum = 100
        lineChart.rightAxis.axisMinimum = 0
        lineChart.rightAxis.setLabelCount(5, force: false)
        lineChart.rightAxis.granularityEnabled = true
        lineChart.rightAxis.granularity = 1.0

        //
        // formatting values: https://weeklycoding.com/mpandroidchart-documentation/formatting-data-values/

        lineChart.notifyDataSetChanged()
    }

}
