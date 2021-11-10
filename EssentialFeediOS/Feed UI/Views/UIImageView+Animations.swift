//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Pankaj Mangotra on 02/11/21.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage

        guard newImage != nil else { return }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
