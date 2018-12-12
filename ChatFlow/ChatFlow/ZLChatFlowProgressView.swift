// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

final class ZLChatFlowProgressView : UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var titleLabel: ZLLabel!
    @IBOutlet var tellusCashLabel: ZLLabel!
    @IBOutlet var tellusCashImageView: UIImageView!
    @IBOutlet private var progressView: UIProgressView!
    weak var delegate: ZLChatFlowProgressViewDelegate?
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        addSubview(contentView, constrainedToFillWith: .zero)

        [ undoButton, progressView, tellusCashLabel, tellusCashImageView ].forEach { $0.isHidden = true }
        progressView.progress = 0
        heightAnchor.constraint(equalToConstant: 98).isActive = true
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
    }
    
    // MARK: Updating
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    func setProgress(_ progress: Float, animated: Bool) {
        progressView.setProgress(progress, animated: animated)
    }
    
    var showTellusCash: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.tellusCashLabel.isHidden = !self.showTellusCash
                self.tellusCashImageView.isHidden = !self.showTellusCash
            }
        }
    }

    var showUndoButton: Bool = false {
        didSet { UIView.animate(withDuration: 0.25) { self.undoButton.isHidden = !self.showUndoButton } }
    }
    
    // MARK: Actions
    @IBAction private func handleUndoButtonPressed() {
        delegate?.handleUndoButtonPressed()
    }
}

protocol ZLChatFlowProgressViewDelegate : class {
    func handleUndoButtonPressed()
}
