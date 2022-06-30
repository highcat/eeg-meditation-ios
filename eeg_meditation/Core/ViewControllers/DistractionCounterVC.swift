//
//  DistractionCounterVC.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 03/02/2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit


class DistractionCounterVC: UIViewController {
    @IBOutlet var buttonPause: StartStopButton!
    @IBOutlet var buttonStop: StartStopButton!
    @IBOutlet var buttonBack2: UIButton!
    @IBOutlet var insctructionText: UILabel!

    @IBOutlet var tapCircle: UIView!
    @IBOutlet var tapCircleHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tapCircleAnimated: UIView!
    @IBOutlet var tapCircleAnimatedHeightConstraint: NSLayoutConstraint!
    var tapIsAnimating = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MeditationSession.current?.isRunning ?? false {
            buttonPause.isEnabled = true
            buttonStop.isEnabled = true
            buttonBack2.isHidden = true
        } else {
            buttonPause.isEnabled = false
            buttonStop.isEnabled = false
            buttonBack2.isHidden = false
        }

        // set up circles
        animationToInitialPosition()
    }

    private func animationToInitialPosition() {
        self.tapCircle.layer.opacity = 1.0
        self.tapCircle.layer.cornerRadius = self.tapCircleHeightConstraint.constant / 2

        self.tapCircleAnimated.isHidden = true
        self.tapCircleAnimated.layer.opacity = 0.0
        self.tapCircleAnimatedHeightConstraint.constant = self.tapCircleHeightConstraint.constant
        self.tapCircleAnimated.layer.cornerRadius = self.tapCircle.layer.cornerRadius

        self.tapIsAnimating = false
    }

    let ANIMATION_MAX_SIZE = CGFloat(2000)
    let ANIMATION_SPEED = CGFloat(4000)  // points/second


    @IBAction func touchHappened(_ sender: Any) {
        guard let sender = sender as? UIGestureRecognizer else { return }
        guard sender.state == .ended else { return } // FIXME only .ended state recieved. But we better act on initial touch.
        guard !tapIsAnimating else { return }
        // animation should take no more than 1 second
        MeditationSession.current?.addTap(at: Date())

        // note: this won't work on iPhone 6 Plus and earlier
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        tapIsAnimating = true
        tapCircle.isHidden = true
        tapCircleAnimated.isHidden = false
        tapCircleAnimated.layer.opacity = 0.8
        view.layoutIfNeeded()

        UIView.animate(withDuration: TimeInterval(ANIMATION_MAX_SIZE / ANIMATION_SPEED), delay: 0, options: .curveEaseIn, animations: {
            self.tapCircleAnimatedHeightConstraint.constant = self.ANIMATION_MAX_SIZE
            self.tapCircleAnimated.layer.cornerRadius = self.ANIMATION_MAX_SIZE / 2
            self.view.layoutIfNeeded()
        }, completion: { animationFinished in
            self.tapIsAnimating = false  // won't work here?
            self.tapCircle.layer.opacity = 0.0
            self.tapCircle.isHidden = false

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.tapCircleAnimated.layer.opacity = 0.0
                self.tapCircle.layer.opacity = 1.0
                self.view.layoutIfNeeded()
            }, completion: { animationFinished in
                self.animationToInitialPosition()
            })
        })
    }

    @IBAction func tapPause(_ sender: Any) {
    }
    @IBAction func tapStop(_ sender: Any) {
    }
}
