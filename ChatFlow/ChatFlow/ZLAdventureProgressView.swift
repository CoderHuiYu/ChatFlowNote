// Copyright © 2017 Tellus, Inc. All rights reserved.

final class ZLAdventureProgressView : UIView {
    @IBOutlet private var heightConstraint: NSLayoutConstraint!
    @IBOutlet private var backOrPreviousButton: UIButton!
    // NOTE: Not ZLLabels as the design is non-standard.
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var titleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var subtitleLabel: UILabel!
    @IBOutlet private var subtitleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var finishLaterButton: UIButton!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var progressViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: ZLAdventureProgressViewDelegate!

    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Prepare
        subtitle = nil
        finishLaterButton.alpha = 0
        progressView.progress = 0
        progressView.alpha = 0
        // Constraints
        heightConstraint.constant = UIDevice.isIPhoneX ? 94 : 70
        // Shadow
        addRasterizedShadow(ofSize: 10, opacity: 0.1, offset: .zero)
    }
    
    // MARK: Updating
    var showButtons: Bool = false {
        didSet {
            let title = showButtons ? NSLocalizedString("Previous", comment: "") : NSLocalizedString("Cancel", comment: "")
            backOrPreviousButton.setTitle(title, for: .normal)
            UIView.animate(withDuration: 0.25) { self.finishLaterButton.alpha = (self.showButtons && self.delegate.shouldIncludeFinishLaterButton()) ? 1 : 0 }
        }
    }
    
    var showProgressBar: Bool = false {
        didSet {
            if !oldValue && showProgressBar {
                UIView.animate(withDuration: 0.25) {
                    self.progressView.alpha = 1
                }
            } else if oldValue && !showProgressBar {
                UIView.animate(withDuration: 0.25) {
                    self.progressView.alpha = 0
                }
            } else {
                // Do nothing
            }
        }
    }
    
    var progress: Float = 0 {
        didSet {
            if progress > 0 && !showProgressBar {
                showProgressBar = true
                runOnMainQueueAsyncDelayed(0.5) {
                    self.progressView.setProgress(self.progress, animated: true)
                }
            } else if progress == 0 && showProgressBar {
                self.progressView.setProgress(progress, animated: true)
                runOnMainQueueAsyncDelayed(0.5) {
                    self.showProgressBar = false
                }
            } else {
                progressView.setProgress(progress, animated: true)
            }
        }
    }
    
    // MARK: Accessors
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var subtitle: String? {
        get { return subtitleLabel.text }
        set {
            subtitleLabel.text = newValue
            subtitleLabel.isHidden = newValue == nil
            subtitleLabelHeightConstraint.constant = newValue == nil ? 0 : 14
            titleLabel.font = newValue == nil ? .zillyFont(size: .size14, weight: .bold) : .zillyFont(size: .size12, weight: .bold)
            titleLabelHeightConstraint.constant = newValue == nil ? 22 : 18
        }
    }
    
    // MARK: Interaction
    @IBAction private func handlebackOrPreviousButtonPressed() {
        if showButtons { delegate.handlePreviousButtonPressed() } else { delegate.handleBackButtonPressed() }
    }
    
    @IBAction private func handleFinishLaterButtonPressed() { delegate.handleFinishLaterButtonPressed() }
}

protocol ZLAdventureProgressViewDelegate : class {
    func shouldIncludeFinishLaterButton() -> Bool
    func handleBackButtonPressed()
    func handlePreviousButtonPressed()
    func handleFinishLaterButtonPressed()
}

extension ZLAdventureProgressViewDelegate {
    func shouldIncludeFinishLaterButton() -> Bool { return false }
    func handleBackButtonPressed() { }
    func handlePreviousButtonPressed() { }
    func handleFinishLaterButtonPressed() { }
}
