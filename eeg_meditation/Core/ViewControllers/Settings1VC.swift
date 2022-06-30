//
//  Settings1VC.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 24.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit

class SettingsV1VC: UITableViewController {
    @IBOutlet var frequencySwitch: UISegmentedControl!
    @IBOutlet var frequencyControlSwitch: UISwitch!
    @IBOutlet var timerSoundSwitch: UISegmentedControl!
    @IBOutlet var algoSwitch: UISegmentedControl!
    @IBOutlet var guruModeSwitch: UISwitch!
    @IBOutlet var compareFormulasSwitch: UISwitch!

    @IBOutlet var guruModeCell: UITableViewCell!
    

    override func viewWillAppear(_ animated: Bool) {
        switch SettingsModel.shared.frequencyCutoff {
        case .cutoff50:
            frequencySwitch.selectedSegmentIndex = 0
        case .cutoff60:
            frequencySwitch.selectedSegmentIndex = 1
        }
        frequencyControlSwitch.isOn = SettingsModel.shared.frequencyControlEnabled
        frequencySwitch.isEnabled = SettingsModel.shared.frequencyControlEnabled

        switch SettingsModel.shared.endSound {
        case .chineseHong:
            timerSoundSwitch.selectedSegmentIndex = 0
        case .vasylSound:
            timerSoundSwitch.selectedSegmentIndex = 1
        default:
            timerSoundSwitch.selectedSegmentIndex = 0
        }
        
        switch SettingsModel.shared.meditationAlgo {
        case .vasylVernyhora2021:
            algoSwitch.selectedSegmentIndex = 0
            guruModeCell.isHidden = false
        case .eSense:
            algoSwitch.selectedSegmentIndex = 1
            guruModeCell.isHidden = true
        }
        
        switch SettingsModel.shared.algoModifier {
        case .normal:
            guruModeSwitch.isOn = false
        case .guruMode20:
            guruModeSwitch.isOn = true
        }
        compareFormulasSwitch.isOn = SettingsModel.shared.showSecondaryAlgo
    }

    @IBAction func frequencyChanged(_ sender: Any) {
        switch frequencySwitch.selectedSegmentIndex {
        case 0:
            SettingsModel.shared.frequencyCutoff = .cutoff50
            HeadsetController.shared.setCutoff(cutoff: .hz50) // set while running session
        case 1:
            SettingsModel.shared.frequencyCutoff = .cutoff60
            HeadsetController.shared.setCutoff(cutoff: .hz60) // set while running session
        default:
            assert(false)
        }
        SettingsCareTaker.shared.save()
    }

    @IBAction func frequencyControlChanged(_ sender: Any) {
        SettingsModel.shared.frequencyControlEnabled = frequencyControlSwitch.isOn
        frequencySwitch.isEnabled = frequencyControlSwitch.isOn
        SettingsCareTaker.shared.save()

        // set while running session
        if frequencyControlSwitch.isOn {
            switch SettingsModel.shared.frequencyCutoff {
            case .cutoff50:
                HeadsetController.shared.setCutoff(cutoff: .hz50)
            case .cutoff60:
                HeadsetController.shared.setCutoff(cutoff: .hz60)
            }
        }
    }
    
    @IBAction func guruModeChanged(_ sender: Any) {
        if guruModeSwitch.isOn {
            SettingsModel.shared.algoModifier = .guruMode20
        } else {
            SettingsModel.shared.algoModifier = .normal
        }
        SettingsCareTaker.shared.save()
    }
    
    @IBAction func compareFormulasChanged(_ sender: Any) {
        SettingsModel.shared.showSecondaryAlgo = compareFormulasSwitch.isOn
        SettingsCareTaker.shared.save()
    }
    
    
    @IBAction func timerSoundChanged(_ sender: Any) {
        switch timerSoundSwitch.selectedSegmentIndex {
        case 0:
            SettingsModel.shared.endSound = .chineseHong
        case 1:
            SettingsModel.shared.endSound = .vasylSound
        default:
            SettingsModel.shared.endSound = .chineseHong
        }
        SettingsCareTaker.shared.save()

        SoundCenter.shared.stopSounds() // stop previous sound
        SoundCenter.shared.playTimerEnded()
    }
    
    @IBAction func algoChanged(_ sender: Any) {
        switch algoSwitch.selectedSegmentIndex {
        case 0:
            SettingsModel.shared.meditationAlgo = .vasylVernyhora2021
            guruModeCell.isHidden = false
        case 1:
            SettingsModel.shared.meditationAlgo = .eSense
            guruModeCell.isHidden = true
        default:
            SettingsModel.shared.meditationAlgo = .vasylVernyhora2021
            guruModeCell.isHidden = false
        }
        SettingsCareTaker.shared.save()
    }
    

    @IBAction func showStatistics(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Stats", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        // vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    @IBAction func tapReadAboutAlgorithm(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewFormulaVC") as! NewFormulaVC
        present(vc, animated: true, completion: nil)
    }
}
