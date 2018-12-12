// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit
import pop

final class ZLChatStackView : UIView, UIScrollViewDelegate {
    private var animationQueue: [Animation] = []
    weak var delegate: ZLChatStackViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let result = UIStackView(axis: .vertical, spacing: ZLChatStackView.spacingBetweenViews)
        result.clipsToBounds = false
        return result
    }()
    
    lazy var scrollView: ScrollView = {
        let result = ScrollView()
        result.clipsToBounds = false
        result.showsVerticalScrollIndicator = false
        result.delegate = self
        return result
    }()
    
    private enum Animation { case push(UIView), popLast }
    
    class ScrollView : UIScrollView {
        var ignoreContentOffsetUpdates = true
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if ignoreContentOffsetUpdates {
                contentOffset = CGPoint(x: 0, y: contentSize.height - frame.height)
            }
        }
    }
    
    // MARK: Settings
    private static let spacingBetweenViews: CGFloat = 8
    var delayBetweenForwardAnimations: TimeInterval = 0.33
    var delayBetweenBackwardAnimations: TimeInterval = 0
    
    // MARK: Initialization
    override init(frame: CGRect) { super.init(frame: frame); initialize() }
    required init?(coder: NSCoder) { super.init(coder: coder); initialize() }
    
    private func initialize() {
        clipsToBounds = false
        addSubview(scrollView, pinningEdges: .all)
        scrollView.addSubview(stackView, pinningEdges: .all)
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }

    // MARK: Updating
    func push(_ view: UIView) {
        if animationQueue.isEmpty { performPushAnimation(with: view) }
        animationQueue.append(.push(view))
    }
    
    func popLast() {
        if animationQueue.isEmpty { performPopLastAnimation() }
        animationQueue.append(.popLast)
    }
    
    // MARK: Animation
    private func performPushAnimation(with view: UIView) {
        // Calculate old & new content heights
        let oldContentHeight = scrollView.contentSize.height
        stackView.addArrangedSubview(view)
        scrollView.layoutIfNeeded()
        let newContentHeight = scrollView.contentSize.height
        // Calculate animation to & from values
        let fromValue = CGPoint(x: 0, y: oldContentHeight - scrollView.frame.height)
        let toValue = CGPoint(x: 0, y: newContentHeight - scrollView.frame.height)
        // Perform animation
        scrollView.ignoreContentOffsetUpdates = false
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)!
        scaleAnimation.fromValue = CGSize(width: 0.8, height: 0.8)
        scaleAnimation.toValue = CGSize(width: 1, height: 1)
        scaleAnimation.springBounciness = 3
        scaleAnimation.velocity = CGPoint(x: 5, y: 5) // Scale fraction per second
        view.layer.pop_add(scaleAnimation, forKey: "pushScaleAnimation")
        let scrollAnimation = POPSpringAnimation(propertyNamed: kPOPScrollViewContentOffset)!
        scrollAnimation.fromValue = fromValue
        scrollAnimation.toValue = toValue
        scrollAnimation.springBounciness = 5
        scrollAnimation.velocity = CGPoint(x: 0, y: UIScreen.main.bounds.height * 1.3) // Animation Duration - Points per second
        scrollAnimation.completionBlock = { [weak self] _,_ in
            guard let strongSelf = self else { return }
            strongSelf.scrollView.ignoreContentOffsetUpdates = true
            strongSelf.performNextAnimationIfNeeded()
        }
        scrollView.pop_add(scrollAnimation, forKey: "pushScrollAnimation")
    }
    
    private func performPopLastAnimation() {
        guard let view = stackView.arrangedSubviews.last else { preconditionFailure("Can't pop past last view.") }
        let scrollDistance = view.frame.height + ZLChatStackView.spacingBetweenViews
        // Calculate old & new content heights
        let oldContentHeight = scrollView.contentSize.height
        let newContentHeight = scrollView.contentSize.height - scrollDistance
        // Calculate animation to & from values
        let fromValue = CGPoint(x: 0, y: oldContentHeight - scrollView.frame.height)
        let toValue = CGPoint(x: 0, y: newContentHeight - scrollView.frame.height)
        // Perform animation
        DispatchQueue.main.async {
            self.scrollView.ignoreContentOffsetUpdates = false
        }
        let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)!
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.completionBlock = { [weak self] _,_ in
            guard let strongSelf = self else { return }
            strongSelf.scrollView.ignoreContentOffsetUpdates = true
            view.removeFromSuperview()
            let scrollView = strongSelf.scrollView
            scrollView.layoutIfNeeded()
            strongSelf.performNextAnimationIfNeeded()
        }
        scrollView.pop_add(animation, forKey: "popAnimation")
    }
    
    private func performNextAnimationIfNeeded() {
        animationQueue.removeFirst()
        if let nextAnimation = animationQueue.first {
            switch nextAnimation {
            case .push(let view): DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenForwardAnimations) { self.performPushAnimation(with: view) }
            case .popLast: DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenBackwardAnimations) { self.performPopLastAnimation() }
            }
        } else {
            delegate?.chatStackViewDidFinishAnimating(self)
        }
    }
    
    // MARK: Interaction
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollView.ignoreContentOffsetUpdates = false
    }
}

protocol ZLChatStackViewDelegate : class {
    func chatStackViewDidFinishAnimating(_ chatStackView: ZLChatStackView)
}
