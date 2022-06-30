//
//  ViewController.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 04/11/2019.
//  Copyright © 2019 Alex Lokk. All rights reserved.
//

import UIKit
import Charts
import CoreData
import RxSwift


// MARK: All simple UI stuff

class MainVC: UIViewController, TimerButtonDelegate {
    @IBOutlet var lineChart: LineChartView!
    @IBOutlet var headsetStateIcon: UIImageView!
    @IBOutlet var headsetStateText: UILabel!
    @IBOutlet var shareResultsPanel: UIView!
    @IBOutlet var shareButton: UIButton!
    let disposeBag = DisposeBag()

    // Views to snapshot image from
    @IBOutlet var sessionStats: UIView!
    @IBOutlet var graphView: UIView!

    @IBOutlet var buttonConnect: StartStopButton!
    @IBOutlet var buttonPause: StartStopButton!
    @IBOutlet var buttonStop: StartStopButton!

    @IBOutlet var buttonLevel60: LevelButton!
    @IBOutlet var buttonLevel70: LevelButton!
    @IBOutlet var buttonLevel75: LevelButton!
    @IBOutlet var buttonLevel80: LevelButton!
    @IBOutlet var buttonLevel85: LevelButton!
    @IBOutlet var buttonLevel90: LevelButton!

    @IBOutlet var buttonTimer1: TimerButton! { didSet { buttonTimer1.delegate = self } }
    @IBOutlet var buttonTimer2: TimerButton! { didSet { buttonTimer2.delegate = self } }
    @IBOutlet var buttonTimer3: TimerButton! { didSet { buttonTimer3.delegate = self } }
    @IBOutlet var buttonTimer4: TimerButton! { didSet { buttonTimer4.delegate = self } }
    @IBOutlet var buttonTimer5: TimerButton! { didSet { buttonTimer5.delegate = self } }
    @IBOutlet var buttonTimer6: TimerButton! { didSet { buttonTimer6.delegate = self } }
    @IBOutlet var buttonTimer7: TimerButton! { didSet { buttonTimer7.delegate = self } }
    @IBOutlet var buttonTimer8: TimerButton! { didSet { buttonTimer8.delegate = self } }

    @IBOutlet var buttonThresholdExceeded: FeedbackControlButton!
    @IBOutlet var buttonThresholdNotReached: FeedbackControlButton!

    @IBOutlet var buttonFeedbackTonalSignal: FeedbackControlButton!
    @IBOutlet var buttonFeedbackWhiteNoise: FeedbackControlButton!
    @IBOutlet var buttonFeedbackSilent: FeedbackControlButton!

    @IBOutlet var clickerSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!

    @IBOutlet var meditationLevelIndicator: UILabel!
    @IBOutlet var guruModeIndicator: UILabel!

    @IBOutlet var averageLevelIndicator: UILabel!
    @IBOutlet var sessionTimeIndicator: UILabel!
    @IBOutlet var meditationTimeIndicator: UILabel!
    @IBOutlet var gte90TimeIndicator: UILabel!
    @IBOutlet var gte80MaxSolidTimeIndicator: UILabel!

    @IBOutlet var clickerButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var clickCount: UILabel!

    // FIXME move to headset controller or bluetooth device manager class
    struct DeviceInfo {
        let devName: String
        let mfgID: String
        let deviceID: String
    }
    var devices: [DeviceInfo] = []
    var lastPoorSignalValue: HeadsetController.SignalStrength = .noSignal

    // Meditation session timer, set by user
    var timer: Timer?
    var timerObjectStartTime: Date?
    var timePassed: TimeInterval = 0  // cumulative passed, pauses excluded
    @IBOutlet var timerProgressBar: UIProgressView!

    // Main clock timer for UI updates and sometimes data collecting.
    var clock_timer: Timer?
    var clock_lastTimerHit: Date?

    // initialize from beginning, to auto-test that named image xists
    let hi_ok = UIImage(named: "connection_ok")
    let hi_connecting = UIImage(named: "connection_connecting")
    let hi_yellow3 = UIImage(named: "connection_3dots")
    let hi_yellow2 = UIImage(named: "connection_2dots")
    let hi_yellow1 = UIImage(named: "connection_1dot")
    let hi_noSignal = UIImage(named: "connection_nosignal")

    @IBAction func timerToggle(_ sender: Any) {
        SettingsModel.shared.timerOn = timerSwitch.isOn
        SettingsCareTaker.shared.save()

        if MeditationSession.current?.isRunning ?? false {
            if timerSwitch.isOn {
                startTimer()
            } else {
                cancelTimer()
            }
        }
    }

    @IBAction func tapThresholdExceeded(_ sender: Any) {
        buttonThresholdExceeded.isSelected = true
        buttonThresholdNotReached.isSelected = false
        SettingsModel.shared.feedbackOn = .exceeded
        SettingsCareTaker.shared.save()

        restartFeedback()
    }
    @IBAction func tapThresholdNotReached(_ sender: Any) {
        buttonThresholdExceeded.isSelected = false
        buttonThresholdNotReached.isSelected = true
        SettingsModel.shared.feedbackOn = .notReached
        SettingsCareTaker.shared.save()

        restartFeedback()
    }

    @IBAction func tapFeedbackTonalSignal(_ sender: Any) {
        buttonFeedbackTonalSignal.isSelected = true
        buttonFeedbackWhiteNoise.isSelected = false
        buttonFeedbackSilent.isSelected = false
        SettingsModel.shared.signalType = .tonal
        SettingsCareTaker.shared.save()

        restartFeedback()
    }
    @IBAction func tapFeedbackWhiteNoise(_ sender: Any) {
        buttonFeedbackTonalSignal.isSelected = false
        buttonFeedbackWhiteNoise.isSelected = true
        buttonFeedbackSilent.isSelected = false
        SettingsModel.shared.signalType = .whiteNoise
        SettingsCareTaker.shared.save()

        restartFeedback()
    }
    @IBAction func tapFeedbackSilent(_ sender: Any) {
        buttonFeedbackTonalSignal.isSelected = false
        buttonFeedbackWhiteNoise.isSelected = false
        buttonFeedbackSilent.isSelected = true
        SettingsModel.shared.signalType = .silent
        SettingsCareTaker.shared.save()

        restartFeedback()
    }

    func restartFeedback() {
        startFeedback()
    }
    func startFeedback() {
        switch SettingsModel.shared.signalType {
        case .tonal:
            SoundCenter.shared.startFeedback(type: .tone)
        case .whiteNoise:
            SoundCenter.shared.startFeedback(type: .whiteNoise)
        case .silent:
            SoundCenter.shared.startFeedback(type: .slient)
        case .custom:
            SoundCenter.shared.stopFeedback()
        }
    }

    func deselectTimerButtons() {
        buttonTimer1.isSelected = false
        buttonTimer2.isSelected = false
        buttonTimer3.isSelected = false
        buttonTimer4.isSelected = false
        buttonTimer5.isSelected = false
        buttonTimer6.isSelected = false
        buttonTimer7.isSelected = false
        buttonTimer8.isSelected = false
    }

    @IBAction func tapTimerButton1(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer1.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn1
        SettingsCareTaker.shared.save()
    }
    @IBAction func tapTimerButton2(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer2.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn2
        SettingsCareTaker.shared.save()
    }
    @IBAction func tapTimerButton3(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer3.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn3
        SettingsCareTaker.shared.save()
    }
    @IBAction func tapTimerButton4(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer4.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn4
        SettingsCareTaker.shared.save()
    }
    @IBAction func tapTimerButton5(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer5.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn5
        SettingsCareTaker.shared.save()
    }
    @IBAction func tapTimerButton6(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer6.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn6
    }
    @IBAction func tapTimerButton7(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer7.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn7
        SettingsCareTaker.shared.save()
    }
    @IBAction func tapTimerButton8(_ sender: Any) {
        deselectTimerButtons()
        buttonTimer8.isSelected = true
        updateTimerTime()
        SettingsModel.shared.timerButtonSelected = .btn8
        SettingsCareTaker.shared.save()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.noDataText = "Start session to see the meditation timeline."

        HeadsetController.shared.delegate = self

        applyAppSettings()
        showClickerState()
        shareResultsPanel.isHidden = true

        SettingsModel.relay.subscribe(onNext: {[weak self] settings in
            // Show/hide elements according to Settings.
            //
            // Example:
            // self?.shareResultsPanel.isHidden = !settings.sharingPanelEnabled
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if HeadsetController.shared.deviceIsStub {
            showDebugState()
        }
        if SettingsModel.shared.presentNewAlgo {
            let storyboard = UIStoryboard(name: "Help", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NewFormulaVC") as! NewFormulaVC
            present(vc, animated: true)
        }
    }

    func applyAppSettings() {
        let settings = SettingsModel.shared
        switch settings.feedbackOn {
        case .exceeded:
            buttonThresholdExceeded.isSelected = true
        case .notReached:
            buttonThresholdNotReached.isSelected = true
        }

        switch settings.signalType {
        case .whiteNoise:
            buttonFeedbackWhiteNoise.isSelected = true
        case .tonal:
            buttonFeedbackTonalSignal.isSelected = true
        case .silent:
            buttonFeedbackSilent.isSelected = true
        default:
            // FIXME custom
            buttonFeedbackTonalSignal.isSelected = true
        }

        buttonTimer1.setTitle("\(settings.timerButton1)", for: .normal)
        buttonTimer2.setTitle("\(settings.timerButton2)", for: .normal)
        buttonTimer3.setTitle("\(settings.timerButton3)", for: .normal)
        buttonTimer4.setTitle("\(settings.timerButton4)", for: .normal)
        buttonTimer5.setTitle("\(settings.timerButton5)", for: .normal)
        buttonTimer6.setTitle("\(settings.timerButton6)", for: .normal)
        buttonTimer7.setTitle("\(settings.timerButton7)", for: .normal)
        buttonTimer8.setTitle("\(settings.timerButton8)", for: .normal)

        deselectTimerButtons()
        switch settings.timerButtonSelected {
        case .btn1:
            buttonTimer1.isSelected = true
        case .btn2:
            buttonTimer2.isSelected = true
        case .btn3:
            buttonTimer3.isSelected = true
        case .btn4:
            buttonTimer4.isSelected = true
        case .btn5:
            buttonTimer5.isSelected = true
        case .btn6:
            buttonTimer6.isSelected = true
        case .btn7:
            buttonTimer7.isSelected = true
        case .btn8:
            buttonTimer8.isSelected = true
        }

        deselectLevelButtons()
        switch settings.meditationLevel {
        case 60:
            buttonLevel60.isSelected = true
        case 70:
            buttonLevel70.isSelected = true
        case 75:
            buttonLevel75.isSelected = true
        case 80:
            buttonLevel80.isSelected = true
        case 85:
            buttonLevel85.isSelected = true
        case 90:
            buttonLevel90.isSelected = true
        default:
            settings.meditationLevel = 75
            buttonLevel75.isSelected = true
        }

        clickerSwitch.isOn = settings.counterOn
        timerSwitch.isOn = settings.timerOn
    }

    func showClickerState(completion: @escaping () -> Void = {}) {
        if clickerSwitch.isOn {
            SettingsModel.shared.counterOn = true
            // perform this by listening to settings instead?
            UIView.animate(withDuration: 0.2, animations: {
                self.clickerButtonWidthConstraint.constant = 40.0
                if self.clickCount.text != "0" {
                    self.clickCount.isHidden = false
                }
                self.view.layoutIfNeeded()
            }, completion: { animationDone in
                completion()
            })
            if MeditationSession.current?.isRunning ?? false           {
                self.performSegue(withIdentifier: "manualOpenDistractionCounter", sender: self)
            }
        } else {
            SettingsModel.shared.counterOn = false
            UIView.animate(withDuration: 0.2, animations: {
                self.clickerButtonWidthConstraint.constant = 0.0
                self.clickCount.isHidden = true
                self.view.layoutIfNeeded()
            }, completion: { animationDone in
                completion()
            })
        }
    }



    @IBAction func clickerToggle(_ sender: Any) {
        guard let _ = sender as? UISwitch else { return }
        showClickerState()
        SettingsModel.shared.counterOn = clickerSwitch.isOn
        SettingsCareTaker.shared.save()
    }


    private func deselectLevelButtons() {
        buttonLevel60.isSelected = false
        buttonLevel70.isSelected = false
        buttonLevel75.isSelected = false
        buttonLevel80.isSelected = false
        buttonLevel85.isSelected = false
        buttonLevel90.isSelected = false
    }

    @IBAction func buttonLevel60Tap(_ sender: Any) {
        let the_level = 60
        deselectLevelButtons()
        buttonLevel60.isSelected = !buttonLevel60.isSelected
        SettingsModel.shared.meditationLevel = the_level
        MeditationSession.current?.addLevelChange(newLevel: the_level, at: Date())
        SettingsCareTaker.shared.save()
    }
    @IBAction func buttonLevel70Tap(_ sender: Any) {
        let the_level = 70
        deselectLevelButtons()
        buttonLevel70.isSelected = !buttonLevel70.isSelected
        SettingsModel.shared.meditationLevel = the_level
        MeditationSession.current?.addLevelChange(newLevel: the_level, at: Date())
        SettingsCareTaker.shared.save()
    }
    @IBAction func buttonLevel75Tap(_ sender: Any) {
        let the_level = 75
        deselectLevelButtons()
        buttonLevel75.isSelected = !buttonLevel75.isSelected
        SettingsModel.shared.meditationLevel = the_level
        MeditationSession.current?.addLevelChange(newLevel: the_level, at: Date())
        SettingsCareTaker.shared.save()
    }
    @IBAction func buttonLevel80Tap(_ sender: Any) {
        let the_level = 80
        deselectLevelButtons()
        buttonLevel80.isSelected = !buttonLevel80.isSelected
        SettingsModel.shared.meditationLevel = the_level
        MeditationSession.current?.addLevelChange(newLevel: the_level, at: Date())
        SettingsCareTaker.shared.save()

    }
    @IBAction func buttonLevel85Tap(_ sender: Any) {
        let the_level = 85
        deselectLevelButtons()
        buttonLevel85.isSelected = !buttonLevel85.isSelected
        SettingsModel.shared.meditationLevel = the_level
        MeditationSession.current?.addLevelChange(newLevel: the_level, at: Date())
        SettingsCareTaker.shared.save()
    }
    @IBAction func buttonLevel90Tap(_ sender: Any) {
        let the_level = 90
        deselectLevelButtons()
        buttonLevel90.isSelected = !buttonLevel90.isSelected
        SettingsModel.shared.meditationLevel = the_level
        MeditationSession.current?.addLevelChange(newLevel: the_level, at: Date())
        SettingsCareTaker.shared.save()
    }


    @IBAction func clickerHelpTap(_ sender: Any) {
        let ac = UIAlertController(
            title: "Distraction Counter",
            message: "Tap on the screen each time you feel distracted, or any thought appears during your meditation session. Compare distractions to the meditation level on the timeline.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Close", style: .cancel))
        self.present(ac, animated: true)
    }

    @IBAction func timerHelpTap(_ sender: Any) {
        let ac = UIAlertController(
            title: "Timer",
            message: "Set the timer, and don't worry about missing appointments diving deep into the meditation. Or set yourself an aim to achieve deep meditation level in a short period. This is a good exercise too!",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Close", style: .cancel))
        self.present(ac, animated: true)
    }


    @IBAction func clickConnect(_ sender: Any) {
        connectSession()
    }
    @IBAction func clickPause(_ sender: Any) {
        pauseResumeToggle()
    }
    @IBAction func clickStop(_ sender: Any) {
        stopSession()
    }

    @IBAction func tapHelp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        // vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
