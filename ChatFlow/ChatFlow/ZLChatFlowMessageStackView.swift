// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

final class ZLChatFlowMessageStackView : UIView {

    enum Direction { case incoming(requiresExtraSpacing: Bool), outgoing, none }

    // Sender Avatar
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var avatarLeftConstraint: NSLayoutConstraint!
    @IBOutlet private var avatarTopConstraint: NSLayoutConstraint!
    @IBOutlet private var avatarRightConstraint: NSLayoutConstraint!

    // Sender Name
    @IBOutlet private var senderNameLabel: ZLLabel!
    @IBOutlet private var senderNameLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var senderNameLabelBottomConstraint: NSLayoutConstraint!

    // Info Icon
    @IBOutlet private var infoIconImageView: UIImageView!
    @IBOutlet private var infoButton: UIButton!

    // Chat StackView
    @IBOutlet private var chatMessageStackView: UIStackView!
    @IBOutlet private var chatMessageStackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private var chatMessageStackViewBottomConstraint: NSLayoutConstraint!

    var infoAction: ActionClosure? {
        didSet {
            infoIconImageView.image = infoAction != nil ? #imageLiteral(resourceName: "row-help") : nil
            infoIconImageView.isHidden = infoAction == nil
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // clear out placeholders
        avatarImageView.image = nil
        senderNameLabel.text = nil
        infoIconImageView.image = nil
    }

    @IBAction private func infoButtonPressedAction(_ sender: UIButton) { infoAction?() }

    // TODO: improve the way these are done
    func setAsConsecutiveMessage(_ consecutive: Bool) {
        avatarTopConstraint.constant = consecutive ? 0 : 8
        avatarImageView.isHidden = consecutive
        senderNameLabelHeightConstraint.constant = consecutive ? 0 : 16
        senderNameLabelBottomConstraint.constant = consecutive ? 0 : 2
    }

    func setShortTopMargin(_ short: Bool) {
        avatarTopConstraint.constant = short ? 0 : 8
    }

    func setShortBottomMargin(_ short: Bool) {
        chatMessageStackViewBottomConstraint.constant = short ? 0 : 8
    }

    static private func message(with direction: Direction, view: UIView, from name: String? = nil, avatar: UIImage? = nil, style: ZLChatFlowVC.MessageStyle)  -> ZLChatFlowMessageStackView  {
        let message = ZLChatFlowMessageStackView.loadFromNib()

        switch direction {
        case .outgoing:
            message.avatarImageView.isHidden = true
            message.infoIconImageView.isHidden = true
            message.chatMessageStackViewRightConstraint.constant = 16
            message.chatMessageStackView.alignment = .trailing
            message.senderNameLabelHeightConstraint.constant = 0
            message.senderNameLabelBottomConstraint.constant = 0
        case .incoming(let requiresExtraSpacing):
            message.infoIconImageView.isHidden = true
            if requiresExtraSpacing { message.chatMessageStackViewRightConstraint.constant = 16 }
            if let name = name {
                message.senderNameLabel.text = name
                message.senderNameLabel.textColor = {
                    switch style {
                    case .lightGrayBackground: return .zillyGray()
                    case .whiteBackground: return .zillyDarkText()
                    }
                }()
            } else {
                message.senderNameLabelHeightConstraint.constant = 0
                message.senderNameLabelBottomConstraint.constant = 0
            }
            if let avatar = avatar {
                message.avatarImageView.image = avatar
            } else {
                // Note only for debugging
                //                message.avatarWidthConstraint.constant = 0
                //                message.avatarRightConstraint.constant = 0
                message.avatarImageView.isHidden = true
            }
        case .none:
            message.avatarTopConstraint.constant = 0
            message.avatarLeftConstraint.constant = 0
            message.avatarWidthConstraint.constant = 0
            message.avatarRightConstraint.constant = 0
            message.senderNameLabelHeightConstraint.constant = 0
            message.senderNameLabelBottomConstraint.constant = 0
            message.chatMessageStackViewRightConstraint.constant = 0
            message.chatMessageStackView.distribution = .fill
            message.chatMessageStackView.alignment = .fill
        }

        switch direction {
        case .none: break
        case .incoming, .outgoing: view.widthAnchor.constraint(lessThanOrEqualToConstant: 271).isActive = true
        }

        message.chatMessageStackView.addArrangedSubview(view)
        message.layoutIfNeeded()

        return message
    }
}

// MARK: ZLChatFlow
extension ZLChatFlowMessageStackView {

    static private func createMessage(from sender: ZLChatFlowVC.MessageSender, with view: UIView, style: ZLChatFlowVC.MessageStyle, requiresExtraSpacing: Bool) -> ZLChatFlowMessageStackView {
        switch sender {
        case .user: return message(with: .outgoing, view: view, style: style)
        case .other(let name, let avatar): return message(with: .incoming(requiresExtraSpacing: requiresExtraSpacing), view: view, from: name, avatar: avatar, style: style)
        case .none: return message(with: .none, view: view, style: style)
        }
    }

    static fileprivate func createTextMessage(from sender: ZLChatFlowVC.MessageSender, with text: String, style: ZLChatFlowVC.MessageStyle, textFont: UIFont = .zillyFont(size: .size14)) -> ZLChatFlowMessageStackView {
        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.backgroundColor = sender.messageColor(for: style)
        wrapperView.addSubview(ZLLabel(message: text, textColor: sender.messageTextColor, textFont: textFont), constrainedToFillWith: UIEdgeInsets(horizontal: 16, vertical: 8))
        if case .user = sender {
            wrapperView.cornerRadius = cornerMcCornerfaceLargeCornerRadius
        } else {
            wrapperView.applyChatFlowBorderStyle()
        }
        return createMessage(from: sender, with: wrapperView, style: style, requiresExtraSpacing: false)
    }

    static func message(with event: ZLChatFlowVC.Event, style: ZLChatFlowVC.MessageStyle) -> ZLChatFlowMessageStackView {
        switch event {
        case .textMessage(let sender, let text): return createTextMessage(from: sender, with: text, style: style)
        case .customMessage(let sender, let view): return createMessage(from: sender, with: view, style: style, requiresExtraSpacing: false)
        }
    }
}

extension ZLLabel {

    convenience init(message: String, textColor: UIColor = .zillyWhite(), textFont: UIFont = .zillyFont(size: .size14)) {
        self.init(text: message)
        self.textColor = textColor
        font = textFont
        translatesAutoresizingMaskIntoConstraints = false
        numberOfLines = 0
    }
}

extension UIView {

    func applyChatFlowBorderStyle() {
        cornerRadius = cornerMcCornerfaceLargeCornerRadius
        borderWidth = 1
        borderColor = .zillySeparator()
    }
}
