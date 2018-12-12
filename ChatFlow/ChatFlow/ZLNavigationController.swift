// Copyright © 2018 Tellus, Inc. All rights reserved.

@objc final class ZLNavigationController : UINavigationController {
    var navBarStyle: ZLNavBarStyle = .white { didSet { handleNavBarStyleChanged() } }
    var statusBarStyle: UIStatusBarStyle = .default { didSet { handleStatusBarStyleChanged() } }
    private var isPushingViewController: Bool = false
//    private let observers = ObserverCollection()

    // MARK: Components
    private lazy var backgroundView: UIView = {
        let result = UIView()
        result.isUserInteractionEnabled = false // Required for iOS 10
        return result
    }()

    private lazy var shadowView: UIView = {
        let result = UIView()
        result.isUserInteractionEnabled = false // Required for iOS 10
        return result
    }()

    private lazy var internetStatusLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.zillyFont(size: .size12, weight: .bold)
        label.textColor = .zillyWhite()
        label.textAlignment = .center
        label.backgroundColor = .zillyRed()
        label.text = NSLocalizedString("No Internet Connection", comment: "")
        NSLayoutConstraint.activate([ label.heightAnchor.constraint(equalToConstant: 36) ])
//        observers.addObserver(for: ZLServer.isReachableChanged) { isReachable in
//            label.isHidden = (isReachable != false) // Hide if nil (unknown)
//        }
//        label.isHidden = (ZLServer.isReachable != false)
        return label
    }()
    
    // MARK: Settings
    override var preferredStatusBarStyle: UIStatusBarStyle { return statusBarStyle }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zillyBackground() // Fix for glitches on legacy VCs
        let navBar = navigationBar
        // Background
        navBar.insertSubview(backgroundView, at: 0)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        let navBarHeight: CGFloat = UIDevice.isIPhoneX ? 88 : 64
        NSLayoutConstraint.activate([
            backgroundView.heightAnchor.constraint(equalToConstant: navBarHeight),
            backgroundView.leftAnchor.constraint(equalTo: navBar.leftAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
            backgroundView.rightAnchor.constraint(equalTo: navBar.rightAnchor)
        ])
        navBar.setBackgroundImage(UIImage(), for: .default)
        // Shadow
        navBar.addSubview(shadowView, pinningEdges: [ .left, .bottom, .right ])
        shadowView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        navBar.shadowImage = UIImage()
        // Internet Status
        view.addSubview(internetStatusLabel, pinningEdges: [ .left, .right, .top ], withInsets: UIEdgeInsets(top: navBarHeight, left: 0, bottom: 0, right: 0))
    }

//    deinit { observers.removeAll() }

    // MARK: Actions
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard !isPushingViewController else { return }
        isPushingViewController = true
        super.pushViewController(viewController, animated: animated)
        // `pushViewController(animated:)` happens async, so we can safely change the status of isPushingViewController if we dispatch async.
        DispatchQueue.main.async { [weak self] in
            self?.isPushingViewController = false
        }
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        if let previousVC = viewControllers.dropLast().last as? ZLViewController { // Workaround for title color not updating on pop
            navBarStyle.titleColor = previousVC.navBarStyle.titleColor
        }
        return super.popViewController(animated: animated)
    }

    // MARK: Updating
    override func viewDidLayoutSubviews() {
        navigationBar.sendSubviewToBack(backgroundView) // Required for iOS 10
    }

    private func handleNavBarStyleChanged() {
        let navBar = navigationBar
        // Background
        let backgroundColor = navBarStyle.backgroundColor
        animateAlongsideTransitionIfNeeded { [backgroundView] in
            backgroundView.backgroundColor = backgroundColor
        }
        // Buttons
        let buttonColor = navBarStyle.buttonColor
        animateAlongsideTransitionIfNeeded {
            navBar.tintColor = buttonColor
        }
        // Title
        let titleTextAttributes: [NSAttributedString.Key:Any] = [
            .foregroundColor : navBarStyle.titleColor,
            .font : navBarStyle.font
        ]
        navBar.titleTextAttributes = titleTextAttributes
        // Shadow
        let shadowColor = navBarStyle.hasShadow ? UIColor(white: 0, alpha: 0.125) : UIColor.clear
        animateAlongsideTransitionIfNeeded { [shadowView] in
            shadowView.backgroundColor = shadowColor
        }
        // Internet Status
        let internetStatusAlpha = navBarStyle.backgroundColor != .clear
        animateAlongsideTransitionIfNeeded { [internetStatusLabel] in
            internetStatusLabel.alpha = internetStatusAlpha ? 1 : 0
        }
    }
    
    private func handleStatusBarStyleChanged() {
        setNeedsStatusBarAppearanceUpdate()
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: animated, completion: completion)
        NotificationCenter.default.post(name: ZLViewController.didDismissViewControllerNotification, object: self, userInfo: nil)
    }
    
    // MARK: Convenience
    private func animateAlongsideTransitionIfNeeded(_ animation: @escaping () -> Void) {
        let navBar = navigationBar
        if let transitionCoordinator = transitionCoordinator, presentingViewController == nil {
            let didQueue = transitionCoordinator.animateAlongsideTransition(in: navBar, animation: { _ in animation() }, completion: nil)
            if !didQueue { // This happens when doing an interactive pop, but you don't go through with it
                animation()
            }
        } else {
            animation()
        }
    }
}
