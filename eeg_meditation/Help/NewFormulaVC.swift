//
//  NewFormulaVC.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 23.12.2021.
//  Copyright © 2021 Alex Lokk. All rights reserved.
//

import UIKit

class NewFormulaVC: UIViewController {
    @IBAction func onShowAgainTap(_ sender: Any) {
        SettingsModel.shared.presentNewAlgo = true
        SettingsCareTaker.shared.save()
        dismissRequiredWay()
    }
    @IBAction func onGotItTap(_ sender: Any) {
        SettingsModel.shared.presentNewAlgo = false
        SettingsCareTaker.shared.save()
        dismissRequiredWay()
    }
    func dismissRequiredWay() {
        if let nc = self.navigationController {
            nc.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}
