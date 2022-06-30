//
//  MainVC+sharing.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 22.06.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import UIKit

extension MainVC {
    @IBAction func tapShare(_ sender: Any) {
        if let topImage = UIImage.captureImage(withView: sessionStats),
            let bottomImage = UIImage.captureImage(withView: graphView) {

            let vc = UIActivityViewController(
                activityItems: [
                    UIImage.stackVertically(topImage, bottomImage),
            ], applicationActivities: nil)

            // TODO test sharing on iPad
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.addToReadingList,
             ]
            // iPad: show the popup near the button:
            vc.popoverPresentationController?.sourceView = shareButton
            // iPad: make sure the popup arrow placed properly:
            vc.popoverPresentationController?.sourceRect = shareButton.frame
            present(vc, animated: true)
        }
    }
}


// TODO move to different place / refactor
extension UIImage {
    class func captureImage(withView view: UIView) -> UIImage? {
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.opaque = view.isOpaque
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size, format: rendererFormat)

        let snapshotImage = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        }
        return snapshotImage
    }
}

// TODO move to different place / refactor
extension UIImage {
    class func stackVertically(_ topImage: UIImage, _ bottomImage: UIImage) -> UIImage {
        let scale = topImage.scale  // because the size is in logical pixels

        let labelExtraSpace = CGFloat(30)
        let size = CGSize(
            width: topImage.size.width * scale,
            height: (topImage.size.height + bottomImage.size.height + labelExtraSpace) * scale
        )

        UIGraphicsBeginImageContext(size)
        var areaSize = CGRect(x: 0, y: 0, width: topImage.size.width * scale, height: topImage.size.height * scale)
        topImage.draw(in: areaSize)
        areaSize = CGRect(x: 0, y: topImage.size.height * scale, width: bottomImage.size.width * scale, height: bottomImage.size.height * scale)
        bottomImage.draw(in: areaSize)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)

        return newImage.drawText("\(dateStr), by EEG Meditation for iPhone", atPoint: CGPoint(x: 15, y: size.height - 30))
    }

    func drawText(_ text: String, atPoint point: CGPoint) -> UIImage {
        let image = self
        let textColor = UIColor.gray
        let textFont = UIFont(name: "Helvetica", size: 18)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
