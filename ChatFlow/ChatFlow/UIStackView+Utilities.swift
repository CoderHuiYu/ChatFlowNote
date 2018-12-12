// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

extension UIStackView {
    @objc convenience init(axis: NSLayoutConstraint.Axis, distribution: Distribution = .fill, alignment: Alignment = .fill, spacing: CGFloat = 0, arrangedSubviews: [UIView] = []) {
        self.init(arrangedSubviews: arrangedSubviews)
        (self.axis, self.distribution, self.alignment, self.spacing) = (axis, distribution, alignment, spacing)
    }
}
