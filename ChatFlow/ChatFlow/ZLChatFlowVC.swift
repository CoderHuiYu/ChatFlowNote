// Copyright © 2017 Tellus, Inc. All rights reserved.

import pop

struct Stack<T> {
    private var array = [T]()
    var isEmpty: Bool { return array.isEmpty }
    var count: Int { return array.count }
    var peek: T? { return array.last }
    mutating func push(_ element: T) { array.append(element) }
    mutating func pop() -> T? { return array.popLast() }
}

class ZLChatFlowVC : ZLViewController, ZLOnboardingProgressViewDelegate, ZLAdventureProgressViewDelegate {
    private let containerView = UIView()
    let messageStackView = ZLChatStackView()
    private let accessoryContainerView = UIView()
    private var states: Stack<State> = Stack<State>()
    private var lastEvent: Event?
    private var lastMessage: ZLChatFlowMessageStackView?

    var forceHideUndo: Bool = false
    var delayBetweenForwardAnimations: TimeInterval {
        get { return messageStackView.delayBetweenForwardAnimations }
        set { messageStackView.delayBetweenForwardAnimations = newValue }
    }
    var delayBetweenBackwardAnimations: TimeInterval {
        get { return messageStackView.delayBetweenBackwardAnimations }
        set { messageStackView.delayBetweenBackwardAnimations = newValue }
    }

    // Quickfix: iPhone X support
    var bottomContainerAnchor: NSLayoutYAxisAnchor { return containerView.bottomAnchor }

    override var navBarStyle: ZLNavBarStyle { return .transparent } // We also hide the bar, but this will make it also hide the whisper
    class var needsProgressBar: Bool { return true }
    class var navigationViewStyle: NavigationViewStyle { return .onboarding }
    class var messageStyle: MessageStyle { return .lightGrayBackground }

    enum NavigationViewStyle { case onboarding, adventure }
    enum MessageStyle { case lightGrayBackground, whiteBackground }

    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zillyWhite()
        containerView.backgroundColor = type(of: self).messageStyle == .lightGrayBackground ? .zillyBackground() : .zillyWhite()
        containerView.clipsToBounds = true
        messageStackView.delegate = self
        setUpViewHierarchy()
    }
    
    //deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        navigationController?.isNavigationBarHidden = false
    }

    private func setUpViewHierarchy() {
        // Container View
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topAnchor: NSLayoutYAxisAnchor
        let topConstant: CGFloat
        if #available(iOS 11, *), type(of: self).navigationViewStyle != .adventure {
            topAnchor = view.safeAreaLayoutGuide.topAnchor; topConstant = -20
        } else {
            topAnchor = view.topAnchor; topConstant = 0
        }
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerViewBottomConstraint
        ])

        // Progress View
        if (type(of: self).needsProgressBar) {
            containerView.addSubview(progressView)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                progressView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                progressView.topAnchor.constraint(equalTo: containerView.topAnchor),
                progressView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
            ])
        }

        // Message Stack View
        containerView.addSubview(messageStackView)
        messageStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageStackView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            messageStackView.topAnchor.constraint(equalTo: type(of: self).needsProgressBar ? progressView.bottomAnchor : containerView.topAnchor, constant: 0),
            messageStackView.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        ])
        messageStackView.clipsToBounds = false

        // Accessory Container View
        containerView.addSubview(accessoryContainerView)
        accessoryContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            accessoryContainerView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            accessoryContainerView.topAnchor.constraint(equalTo: messageStackView.bottomAnchor, constant: 16),
            accessoryContainerView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            accessoryContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            accessoryContainerViewHeightConstraint
        ])
        containerView.sendSubviewToBack(messageStackView)
    }
    
    // MARK: Keyboard Handling
    private lazy var containerViewBottomConstraint: NSLayoutConstraint = {
        let bottomAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11, *) { bottomAnchor = self.view.safeAreaLayoutGuide.bottomAnchor } else { bottomAnchor = self.view.bottomAnchor }
        return bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
    }()
    
    @objc private func handleKeyboardWillShowNotification(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let targetHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = UIView.AnimationOptions(rawValue: (notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue)
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.containerViewBottomConstraint.constant = targetHeight - (UIDevice.isIPhoneX ? 34 : 0)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc private func handleKeyboardWillHideNotification(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = UIView.AnimationOptions(rawValue: (notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue)
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.containerViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: Accessory Handling
    private lazy var accessoryContainerViewHeightConstraint: NSLayoutConstraint = {
        return self.accessoryContainerView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    // MARK: Progress Handling
    lazy var progressView: UIView = {
        let result: UIView = {
            switch type(of: self).navigationViewStyle {
            case .onboarding:
                let result = ZLOnboardingProgressView.loadFromNib()
                result.delegate = self
                return result
            case .adventure:
                let result = ZLAdventureProgressView.loadFromNib()
                result.delegate = self
                return result
            }
        }()
        result.layoutIfNeeded()
        return result
    }()
    
    func handleUndoButtonPressed() {
        guard let removeState = states.pop() else { return }
        UIApplication.shared.beginIgnoringInteractionEvents()
        UIResponder.currentFirst()?.resignFirstResponder()
        hideAccessoryViewIfNeeded() {
            for _ in 0..<removeState.events.count {
                self.messageStackView.popLast()
            }
        }
        if let progress = self.states.peek?.progress {
            if let progressView = self.progressView as? ZLOnboardingProgressView {
                progressView.setProgress(progress)
            } else if let progressView = self.progressView as? ZLAdventureProgressView {
                progressView.progress = progress
            }
        }
        if let progressView = self.progressView as? ZLOnboardingProgressView { progressView.showTellusCash = false }
    }
    
    func shouldIncludeFinishLaterButton() -> Bool { return false }
    func handleBackButtonPressed() { } // To be overridden by subclasses
    func handlePreviousButtonPressed() { handleUndoButtonPressed() }
    func handleFinishLaterButtonPressed() { } // To be overridden by subclasses
    
    // MARK: Transitioning
    final func preState(to state: State) {
        guard states.isEmpty else { return }
        transition(to: state, managed: false)
    }

    func transition(to state: State) {
        transition(to: state, managed: true)
    }

    private func transition(to state: State, managed: Bool) {
        if !UIApplication.shared.isIgnoringInteractionEvents { UIApplication.shared.beginIgnoringInteractionEvents() }
        if managed { states.push(state) }
        var messages: [ZLChatFlowMessageStackView] = []
        for i in 0..<state.events.count {
            messages.append(ZLChatFlowMessageStackView.message(with: state.events[i], style: type(of: self).messageStyle))
            if let lastEvent = lastEvent, lastEvent.sender != .none, lastEvent.sender == state.events[i].sender {
                messages[i].setAsConsecutiveMessage(true)
                lastMessage?.setShortBottomMargin(true)
            }
            lastEvent = state.events[i]
            lastMessage = messages.last
            guard i > 0 else { continue }
            if state.events[i].sender == state.events[i-1].sender {
                messages[i].setAsConsecutiveMessage(true)
                messages[i-1].setShortBottomMargin(true)
            }
        }
        hideAccessoryViewIfNeeded() {
            guard !messages.isEmpty else { state.completion?(); return UIApplication.shared.endIgnoringInteractionEvents() }
            messages.forEach { self.messageStackView.push($0) }
        }
        if let progressView = self.progressView as? ZLOnboardingProgressView {
            progressView.setProgress(state.progress)
        } else if let progressView = self.progressView as? ZLAdventureProgressView {
            progressView.progress = state.progress
        }
    }
    
    // Use with caution
    final func popToPreviousActionableState() {
        if !UIApplication.shared.isIgnoringInteractionEvents { UIApplication.shared.beginIgnoringInteractionEvents() }
        hideAccessoryViewIfNeeded() {
            let count = self.states.count

            while self.states.peek != nil && self.states.peek?.accessory == nil {
                let removeState = self.states.pop()!
                for _ in 0..<removeState.events.count {
                    self.messageStackView.popLast()
                }
            }
            // If this is false then there was no removal, we must re-enable the interactions
            guard count != self.states.count else { return UIApplication.shared.endIgnoringInteractionEvents() }
        }
        if let progress = self.states.peek?.progress {
            if let progressView = self.progressView as? ZLOnboardingProgressView {
                progressView.setProgress(progress)
            } else if let progressView = self.progressView as? ZLAdventureProgressView {
                progressView.progress = progress
            }
        }
        if let progressView = self.progressView as? ZLOnboardingProgressView {
            progressView.showTellusCash = false
        }
    }

    private func showAccessoryViewIfNeeded(_ completion: @escaping ()->Void) {
        guard let accessoryView = states.peek?.accessory else { return completion() }
        accessoryContainerView.addSubview(accessoryView, constrainedToFillWith: .zero)
        let targetHeight = accessoryView.systemLayoutSizeFitting(CGSize(width: accessoryContainerView.frame.width, height: .greatestFiniteMagnitude)).height
        view.layoutIfNeeded()
        accessoryView.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.accessoryContainerViewHeightConstraint.constant = targetHeight
            self.view.layoutIfNeeded()
            accessoryView.alpha = 1
        }, completion: { _ in
            completion()
        })
    }
    
    private func hideAccessoryViewIfNeeded(_ completion: @escaping ()->Void) {
        guard let accessoryView = accessoryContainerView.subviews.first else { return completion() }
        UIView.animate(withDuration: 0.25, animations: {
            self.accessoryContainerViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
            accessoryView.alpha = 0
        }, completion: { _ in
            accessoryView.removeFromSuperview()
            completion()
        })
    }

    final func hideAccessoryView(_ hide: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.accessoryContainerView.alpha = hide ? 0 : 1
        }
    }
}

extension ZLChatFlowVC : ZLChatStackViewDelegate {
    func chatStackViewDidFinishAnimating(_ chatStackView: ZLChatStackView) {
        runOnMainQueueAsyncDelayed(0.25) {
            self.showAccessoryViewIfNeeded {
                if let progressView = self.progressView as? ZLOnboardingProgressView {
                    progressView.showUndoButton = !self.forceHideUndo && self.states.count > 1
                } else if let progressView = self.progressView as? ZLAdventureProgressView {
                    progressView.showButtons = !self.forceHideUndo && self.states.count > 1
                }
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            self.states.peek?.completion?()
        }
    }
}
