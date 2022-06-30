//
//  SplashScreenVC.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 22.06.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit


///
/// Simply allow the launch screen to hang around some more time.
///
class SplashScreenVC: UIViewController, UIViewControllerTransitioningDelegate {
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.openApp()
        }
    }

    func openApp() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.transitioningDelegate = self
        self.present(vc, animated: true)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePushAnimator()
    }
    
    // no for dismissed. Only presenting.
}


// see for custom animations:
// https://theswiftdev.com/ios-custom-transition-tutorial-in-swift/

fileprivate class FadePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var duration = 3.0

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toViewController.view.alpha = 1
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
