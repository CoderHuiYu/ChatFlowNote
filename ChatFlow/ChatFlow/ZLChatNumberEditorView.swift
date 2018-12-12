// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

final class ZLChatNumberEditorView : UIView {
    @IBOutlet private(set) var textField: UITextField!
    @IBOutlet private var titleLabel: ZLLabel!
    private let title: String
    private let editor: ZLNumberEditor
    
    init(title: String, editor: ZLNumberEditor) {
        (self.title, self.editor) = (title, editor)
        super.init(frame: .zero)
        let subview = UINib(nibName: "ZLChatNumberEditorView", bundle: nil).instantiate(withOwner: self).first as! UIView
        addSubview(subview, constrainedToFillWith: .zero)
        titleLabel.text = title
        editor.attach(to: textField)
    }
    
    override init(frame: CGRect) { preconditionFailure() }
    required init?(coder: NSCoder) { preconditionFailure() }
}

final class ZLChatStringEditorView<Value> : UIView {
    @IBOutlet private(set) var textField: UITextField!
    @IBOutlet private var titleLabel: ZLLabel!
    private let title: String
    private let editor: ZLStringEditor<Value>

    init(title: String, editor: ZLStringEditor<Value>) {
        (self.title, self.editor) = (title, editor)
        super.init(frame: .zero)
        let subview = UINib(nibName: "ZLChatNumberEditorView", bundle: nil).instantiate(withOwner: self).first as! UIView
        addSubview(subview, constrainedToFillWith: .zero)
        titleLabel.text = title
        editor.attach(to: textField)
    }

    override init(frame: CGRect) { preconditionFailure() }
    required init?(coder: NSCoder) { preconditionFailure() }
}
