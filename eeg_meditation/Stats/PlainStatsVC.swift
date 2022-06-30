//
//  PlainStatsVC.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 20.05.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit
import CoreData


class PlainStatsVC: UITableViewController {
    typealias ISODate = String
    var statDays: [ISODate: [MeditationSession]] = [:]
    var statSections: [ISODate] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // load sessions

        let fetchRequest = NSFetchRequest<MeditationSession>(entityName: "MeditationSession")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        let objs = try! AppDelegate.viewContext.fetch(fetchRequest)
        for o in objs {
            print("--------------------------------")
            guard let startTime = o.startTime, let _ = o.endTime else { continue }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let isoDate: ISODate = dateFormatter.string(from: startTime)

            if statDays[isoDate] == nil {
                statDays[isoDate] = []
                statSections.append(isoDate)
            }
            statDays[isoDate]!.append(o)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainStatsCell") as! PlainStatsCell

        let (isoDay, recordIdx) = (indexPath[0], indexPath[1])
        cell.setData(model: statDays[statSections[isoDay]]![recordIdx])
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}


// MARK: Header style
extension PlainStatsVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return statSections.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Day \(statSections[section])"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statDays[statSections[section]]?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
