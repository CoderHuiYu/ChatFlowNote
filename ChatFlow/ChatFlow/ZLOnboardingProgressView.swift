// Copyright © 2017 Tellus, Inc. All rights reserved.

final class ZLOnboardingProgressView : UIView {
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet var tellusCashLabel: ZLLabel!
    @IBOutlet var tellusCashImageView: UIImageView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var progressViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: ZLOnboardingProgressViewDelegate?
    
    // MARK: Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        [ undoButton, tellusCashLabel, tellusCashImageView ].forEach { $0.alpha = 0 }
        progressView.progress = 0
        progressView.isHidden = true
        progressViewHeightConstraint.constant = 0
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
    }
    
    // MARK: Updating
    var showUndoButton: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) { self.undoButton.alpha = self.showUndoButton ? 1 : 0 }
        }
    }
    
    var showTellusCash: Bool = false {
        didSet {
            tellusCashLabel.alpha = showTellusCash ? 1 : 0
            tellusCashImageView.alpha = showTellusCash ? 1 : 0
        }
    }
    
    var showProgressBar: Bool = false {
        didSet {
            if oldValue == false && showProgressBar == true {
                self.progressViewHeightConstraint.constant = 4
                progressView.alpha = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.progressView.isHidden = false
                    self.layoutIfNeeded()
                }, completion: { _ in
                    UIView.animate(withDuration: 0.25) {
                        self.progressView.alpha = 1
                    }
                })
            } else if oldValue == true && showProgressBar == false {
                UIView.animate(withDuration: 0.25, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressViewHeightConstraint.constant = 0
                    UIView.animate(withDuration: 0.25) {
                        self.progressView.isHidden = true
                        self.layoutIfNeeded()
                    }
                })
            } else {
                // Do nothing
            }
        }
    }
    
    func setProgress(_ progress: Float) {
        if progress > 0 && !showProgressBar {
            showProgressBar = true
            runOnMainQueueAsyncDelayed(0.5) {
                self.progressView.setProgress(progress, animated: true)
            }
        } else if progress == 0 && showProgressBar {
            self.progressView.setProgress(progress, animated: true)
            runOnMainQueueAsyncDelayed(0.25) {
                self.showProgressBar = false
            }
        } else {
            progressView.setProgress(progress, animated: true)
        }
    }

    // MARK: Actions
    @IBAction private func handleUndoButtonPressed() {
        delegate?.handleUndoButtonPressed()
    }
}

protocol ZLOnboardingProgressViewDelegate : class {
    func handleUndoButtonPressed()
}
