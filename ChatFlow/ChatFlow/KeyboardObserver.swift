// Copyright © 2018 Tellus, Inc. All rights reserved.

final class KeyboardObserver : NSObject {

    /// This class only serves as a UIKeyboard position tracker on the screen, when the UIScrollView is dragging and dismissing the keyboard
    /// These observers get notified and we follow that change
    private class KeyboardTrackingView: UIView {

        var positionChangedCallback: (() -> Void)?
        var observedView: UIView?

        deinit { observedView?.removeObserver(self, forKeyPath: "center") }

        override func willMove(toSuperview newSuperview: UIView?) {
            observedView?.removeObserver(self, forKeyPath: "center")
            observedView = newSuperview
            observedView?.addObserver(self, forKeyPath: "center", options: [ .new, .old ], context: nil)
            super.willMove(toSuperview: newSuperview)
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let object = object as? UIView, let superview = superview, object === superview, let change = change else { return }

            let oldCenter = (change[.oldKey] as! NSValue).cgPointValue
            let newCenter = (change[.newKey] as! NSValue).cgPointValue

            if oldCenter != newCenter { positionChangedCallback?() }
        }
    }

    private lazy var keyboardTrackerView: KeyboardTrackingView = {
        let trackingView = KeyboardTrackingView()
        trackingView.positionChangedCallback = { [weak self] in
            self?.onChangePosition?()
        }
        return trackingView
    }()

    /// A view which purpose is to track the keyboard position in the screen
    var trackingView: UIView { return self.keyboardTrackerView }

    private let notifications = Observers()
    private var keyboardHeight: CGFloat = 0

    typealias KeyboardChangeFrameType = (CGRect) -> Void
    typealias KeyboardChangePositionType = () -> Void

    /// Use this closure to make the changes before the animation take place, the endFrame is provided
    var onKeyboardWillChange: KeyboardChangeFrameType?

    /// This closure will be animated alongside the keyboard changes
    var animationBlock: (() -> Void)?

    /// This closure gets called everytime the keyboard changes position
    var onChangePosition: KeyboardChangePositionType?

    /// This closure gets called everytime the keyboard gets hidden
    var keyboardWillHide: (() -> Void)?

    deinit { notifications.removeAll() }

    override init() {
        super.init()
        // This frame's used to guard against unnecessary changes.
        var lastFrame: CGRect?

        // When switching between apps, if the previous app had the keyboard active when comming back to this one it would have strange behaviour where it would pop up an empty keyboard and move it down again
        // This happens because of the UIKeyboardWillChangeFrame notification, hence the verification if there is a first responder on the current view
        notifications.when(UITextInputMode.currentInputModeDidChangeNotification) { [unowned self] in
            self.emojiKeyboardNotification(notification: $0)
        }
        notifications.when(UIResponder.keyboardWillChangeFrameNotification) { [unowned self] in
            lastFrame = self.keyboardNotification(notification: $0, lastFrame: lastFrame)
        }
        notifications.when(UIResponder.keyboardWillHideNotification) { [unowned self] in
            lastFrame = self.keyboardNotification(notification: $0, lastFrame: lastFrame)
            self.keyboardWillHide?()
        }
    }

    private func keyboardNotification(notification: Notification, lastFrame: CGRect?) -> CGRect {
        guard let userInfo = notification.userInfo else { return .zero }

        let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        guard lastFrame != endFrame else { return endFrame }

        keyboardHeight = endFrame.height
        onKeyboardWillChange?(endFrame)

        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        if let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int, let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve) {
            UIView.animate(withDuration: duration, delay: 0, options: [ .beginFromCurrentState, .allowUserInteraction ], animations: {
                UIView.setAnimationCurve(animationCurve)
                self.animationBlock?()
            })
        } else {
            self.animationBlock?()
        }
        return endFrame
    }
}

extension KeyboardObserver {

    // Fix for the iOS 11 issue https://github.com/lionheart/openradar-mirror/issues/18220
    private func emojiKeyboardNotification(notification: Notification) {
        let previousKeyboardHeight = currentKeyboardHeight
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newKeyboardHeight = self.currentKeyboardHeight
            guard abs(previousKeyboardHeight - newKeyboardHeight) > .ulpOfOne else { return }

            let screenSize = UIScreen.main.bounds
            let fakeUserInfo: [AnyHashable:Any] = [
                UIResponder.keyboardAnimationDurationUserInfoKey : 0,
                UIResponder.keyboardFrameEndUserInfoKey : CGRect(x: 0, y: screenSize.height-newKeyboardHeight, width: screenSize.width, height: newKeyboardHeight)
            ]
            NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: fakeUserInfo)
        }
    }

    private var currentKeyboardHeight: CGFloat {
        guard let window = UIApplication.shared.windows.last, let kbView = window.subviews.first?.subviews.first else { return keyboardHeight }
        return kbView.frame.height
    }
}
