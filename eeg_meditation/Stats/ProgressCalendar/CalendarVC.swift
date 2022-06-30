//
//  CalendarVC.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 10.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarVC: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // see this example https://github.com/patchthecode/JTAppleCalendar/blob/master/SampleJTAppleCalendar/Example%20Calendars/ViewController.swift
}

// See
// https://patchthecode.com/jtapplecalendar-home/calendar-from-scratch/

extension CalendarVC: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let testCalendar = Calendar.current
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale

        return ConfigurationParameters(
            startDate: formatter.date(from: "2020-01-01")!,  // FIXME 1st meditation
            endDate: Date(),
            numberOfRows: 6
        )
    }
}


extension CalendarVC: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CalendarDayCell
        configureCell(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! CalendarDayCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }


    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? CalendarDayCell  else { return }
        cell.title.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
    }

    func handleCellTextColor(cell: CalendarDayCell, cellState: CellState) {
       if cellState.dateBelongsTo == .thisMonth {
          cell.backgroundColor = UIColor.systemGreen
       } else {
          cell.backgroundColor = UIColor.systemGray
       }
    }
}
