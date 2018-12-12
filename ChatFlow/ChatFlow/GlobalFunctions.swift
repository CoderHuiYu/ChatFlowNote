// Copyright © 2017 Tellus, Inc. All rights reserved.

/// Whether the current device has a compact height layout, that is, a screen less than 667 points tall.
let isCompactHeightDevice: Bool = UIScreen.main.bounds.height < 667
/// Whether the current device has a tall layout, that is, a screen height greater than 812 points (X devices).
let isTallDevice: Bool = UIScreen.main.bounds.height >= 812

/// Whether the current device has a compact width layout, that is, a screen less than 375 points wide, i.e. 3.5" and 4" screens.
let isCompactWidthDevice: Bool = UIScreen.main.bounds.width < 375
var is4Point7InchScreenOrLarger: Bool { return !isCompactWidthDevice }

let iPhoneXExtraMargins: UIEdgeInsets = {
    if #available(iOS 11, *) {
        let window = UIWindow(frame: UIScreen.main.bounds) // Only executed once, so OK
        return window.safeAreaInsets
    } else {
        return .zero
    }
}()
