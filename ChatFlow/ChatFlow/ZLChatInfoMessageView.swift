// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

final class ZLChatInfoMessageView : UIView {
    private let attributedText: NSAttributedString
    private let action: ActionClosure
    
    // MARK: Initialization
    init(attributedText: NSAttributedString, action: @escaping ActionClosure) {
        (self.attributedText, self.action) = (attributedText, action)
        super.init(frame: .zero)
        // Style
        backgroundColor = .zillyWhite()
        applyChatFlowBorderStyle()
        // Label
        let label = ZLLabel()
        label.attributedText = attributedText
        label.numberOfLines = 0
        addSubview(label, constrainedToFillWith: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        // Tap Recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapRecognizer)
    }
    
    override init(frame: CGRect) { preconditionFailure() }
    required init(coder: NSCoder) { preconditionFailure() }
    
    @objc private func handleTap() { action() }
}
