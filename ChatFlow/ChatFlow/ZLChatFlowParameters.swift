// Copyright © 2017 Tellus, Inc. All rights reserved.

import Foundation

// On onboarding, only the LoadingMessage parameters take effect
enum ZLChatFlowParameters {
    // MARK: Layout parameters
    static let defaultTitle: String = "Tellus"
    static let messagesBottomMargin: CGFloat = 16
    static let spaceBetweenConsecutiveMessages: CGFloat = 8
    
    // MARK: Animation parameters
    static let messageAppearanceAnimationDuration: TimeInterval = 0.3
    static let delayBetweenMessages: TimeInterval = 0.0
    static let initialDelayBeforeShowingNextStepMessages: TimeInterval = 0.1
    
    // MARK: Loading Message
    /// Total number of characters will be divided by this number
    static let loadingMessageCharactersParameter: Double = 200
    /// Max variation between the minimum duration and the calculated duration (seconds)
    static let loadingMessageMaxVariation: TimeInterval = 0.6
    /// Absolute minimum duration of a loading message (seconds)
    static let loadingMessageMinimumDuration: TimeInterval = 0.5
    /// The initial scale of width of the message, before the animation
    static let loadingMessageAnimationScaleX: CGFloat = 0.1
    /// The initial scale of height of the message, before the animation
    static let loadingMessageAnimationScaleY: CGFloat = 0.2
}
