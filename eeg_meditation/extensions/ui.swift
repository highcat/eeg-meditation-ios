//
//  ui.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 22/01/2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit

@IBDesignable
class StartStopButton: UIButton {
    let gradientLayer: CAGradientLayer = CAGradientLayer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        layer.borderWidth = 1.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 5.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let topGradientColor = UIColor(rgb: 0xeeeeee)
        let bottomGradientColor = UIColor(rgb: 0xdddddd)
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.3, y: 1.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = self.bounds
    }
}


class FeedbackControlButton: UIButton {
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        if #available(iOS 13.0, *) {
            // space between image and text
            self.imageEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -4,
                bottom: 0,
                right: 4
            )
        } else {
            // disable image - no SF symbols on old iOS
            setImage(nil, for: .normal)
        }

        if let layer = layer as? CAGradientLayer {
            layer.borderWidth = 0.0
            layer.borderColor = UIColor.darkGray.cgColor
            layer.cornerRadius = 10.0
            clipsToBounds = true
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

            let topGradientColor = UIColor(rgb: 0xeeeeee)
            let bottomGradientColor = UIColor(rgb: 0xdddddd)
            layer.frame = self.bounds
            layer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]

            layer.startPoint = CGPoint(x: 0.0, y: 0.0)
            layer.endPoint = CGPoint(x: 0.3, y: 1.0)

            setTitleColor(titleColor(for: .normal), for: .selected)
            setTitleShadowColor(titleShadowColor(for: .normal), for: .selected)
            showsTouchWhenHighlighted = true
        }
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        // this may be useful for sublayers
        // gradientLayer.frame = self.bounds

        // Maybe draw them here?
        // See https://stackoverflow.com/questions/57364895/drawrect-core-graphics-on-top-of-a-layer
    }

    override var isSelected: Bool {
        willSet {
            if newValue {
                layer.borderColor = UIColor.darkGray.cgColor
                layer.borderWidth = 1.0
            } else {
                layer.borderWidth = 0.0
            }
            setNeedsDisplay()
        }
    }
}


protocol TimerButtonDelegate {
    func timerButtonLongTap(buttonId: Int)
}

@IBDesignable
class TimerButton: UIButton {
    @IBInspectable
    var id: Int
    var delegate: TimerButtonDelegate?
    let gradientLayer: CAGradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        id = -1
        super.init(frame: frame)
        preconfigure()
    }

    required init?(coder aDecoder: NSCoder) {
        id = -1
        super.init(coder: aDecoder)
        preconfigure()
    }

    func preconfigure() {
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(recognizer:))))

        layer.borderWidth = 0.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 10.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let topGradientColor = UIColor(rgb: 0xeeeeee)
        let bottomGradientColor = UIColor(rgb: 0xdddddd)
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.3, y: 1.0)
        self.layer.insertSublayer(gradientLayer, at: 0)

        self.setTitleColor(self.titleColor(for: .normal), for: .selected)
        self.setTitleShadowColor(self.titleShadowColor(for: .normal), for: .selected)
        self.showsTouchWhenHighlighted = true
        self.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = self.bounds
    }

    @objc func longTap(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if let delegate = delegate {
                delegate.timerButtonLongTap(buttonId: self.id)
            }
	        default:
            break
        }
    }

    override var isSelected: Bool {
        willSet {
            if newValue {
                layer.borderColor = UIColor.darkGray.cgColor
                layer.borderWidth = 1.0
            } else {
                layer.borderWidth = 0.0
            }
            setNeedsDisplay()
        }
    }
}


class LevelButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 0.0
        layer.cornerRadius = 5
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        self.showsTouchWhenHighlighted = true
        self.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.setTitleColor(self.titleColor(for: .normal), for: .selected)
        self.setTitleShadowColor(self.titleShadowColor(for: .normal), for: .selected)
    }

    override var isSelected: Bool {
        willSet {
            if newValue {
                layer.borderColor = UIColor.darkGray.cgColor
                layer.borderWidth = 1.0
            } else {
                layer.borderWidth = 0.0
            }
            setNeedsDisplay()
        }
    }
}
