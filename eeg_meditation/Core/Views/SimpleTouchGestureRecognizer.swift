//
//  SimpleTouchGestureRecognizer.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 13.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class SimpleTouchGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .ended
    }
}
