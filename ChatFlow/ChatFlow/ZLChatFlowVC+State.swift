// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

extension ZLChatFlowVC {

    final class State { // NOTE: A reference type because we need reference equality.
        let events: [Event]
        let progress: Float
        let accessory: UIView?
        let completion: ActionClosure?
        
        init(events: [Event], progress: Float, accessory: UIView? = nil, completion: ActionClosure? = nil) {
            (self.events, self.progress, self.accessory, self.completion) = (events, progress, accessory, completion)
        }
    }
    
    enum MessageSender {
        case other(name: String?, icon: UIImage?), user, none

        func messageColor(for style: MessageStyle) -> UIColor {
            switch self {
            case .other:
                switch style {
                case .lightGrayBackground: return .zillyWhite()
                case .whiteBackground: return .zillyBackground()
                }
            case .user:
                switch style {
                case .lightGrayBackground: return .zillyDarkGray()
                case .whiteBackground: return .zillyBlue()
                }
            case .none: return .clear
            }
        }

        var messageTextColor: UIColor {
            switch self {
            case .other: return .zillyDarkText()
            case .user: return .zillyWhite()
            case .none: return .clear
            }
        }
    }
    
    enum Event {
        case textMessage(sender: MessageSender, text: String)
        case customMessage(sender: MessageSender, view: UIView)

        var sender: MessageSender {
            switch self {
            case .textMessage(let sender, _): return sender
            case .customMessage(let sender, _): return sender
            }
        }
    }
}

extension ZLChatFlowVC.MessageSender : Equatable {
    static func == (lhs: ZLChatFlowVC.MessageSender, rhs: ZLChatFlowVC.MessageSender) -> Bool {
        switch (lhs, rhs) {
        case (.other(let nameOne, _), .other(let nameTwo, _)): return nameOne == nameTwo
        case (.user, .user): return true
        default: return false
        }
    }
}

extension ZLChatFlowVC.MessageSender {

    var backgroundColor: UIColor {
        switch self {
        case .user: return UIColor.zillyDarkGray()
        case .other: return UIColor.zillyWhite()
        case .none: return .clear
        }
    }
}
