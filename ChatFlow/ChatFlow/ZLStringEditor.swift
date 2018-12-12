// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

// TODO: Add edit sanitization as a strategy

/// An object that can be attached to a text field to manage string-based editing of a value.
///
/// After attaching, the text field's delegate and text should not be manually changed.
///
/// Subclassing Notes
/// -----------------
/// A string editor splits the input/value into three forms:
/// - The **decorated input** is the input text as it shows to the user, e.g. the string "$5,000.70"
/// - The **semantic input** is the "logical" input, without the display details, e.g. the string "5000.70"
/// - The **value** (of type `Value`) is the actual value being edited, e.g. the decimal number 5000.7
/// For simpler string-editors, two or even all three of these can be the same.
///
/// Usually, not all inputs map to a valid value. There are several approaches to deal with this:
/// - Always keep the semantic input valid by disallowing edits that make it invalid. For example, disallow `34.5.` as input.
/// - Allow invalid semantic input but make the value optional. For example, make `34.5.` parse to a nil value.
/// - Parse the semantic input more leniently into a value. For example, make `34.5.` as input parse to a 34.5 value.
/// - Allow values that are invalid and use error-based validation, using `validate(value:)`.
/// These different approaches can also be combined.
///
/// Methods to Override
/// -------------------
/// If `Value` is any type other than `String`, override at least the following methods.
/// Every semantic input should map to only one value, but a value could map to multiple semantic inputs.
/// This means if you convert semantic input to a value and back you might end up with a different semantic input,
/// e.g. "300.530" (semantic) => 300.53 (value) => "300.53" (semantic).
/// The form returned by `semanticInput(fromValue:)` is called the canonical (standard/preferred) form of that value.
/// - `value(fromSemanticInput:)`
/// - `semanticInput(fromValue:)`
/// - `emptyValue` (if `Value` is non-optional)
///
/// If there is a difference between decorated input and semantic input, override the following.
/// The mapping between decorated and semantic input should generally be one-to-one. i.e. there is only
/// one possible semantic input for a given decorated input and vice versa.
/// - `decoratedInput(fromSemanticInput:selection:)`
/// - `semanticInput(fromDecoratedInput:selection:)`
/// - `semanticEdit(fromDecoratedEdit:)` (optional)
///
/// For restrictions on the as-you-type value, implement one or both of the following:
/// - `shouldAllow(semanticInput:)`
/// - `shouldAllow(value:)`
///
/// For error-based validation (i.e. that does not restrict the input as it is typed), override this method:
/// - `validate(value:)`
class ZLStringEditor<Value> : NSObject, ZLEditor, UITextFieldDelegate, ZLDismissalInputAccessoryDelegate, ZLAnyStringEditor {
    // Text Field
    private(set) var textField: UITextField?
    var keyboardType: UIKeyboardType = .default { didSet { updateTextFieldProperties() } }
    var autocapitalizationType: UITextAutocapitalizationType = .sentences { didSet { updateTextFieldProperties() } }
    var isSecureTextEntry = false { didSet { updateTextFieldProperties() } }
    var autocorrectionType: UITextAutocorrectionType = .no { didSet { updateTextFieldProperties() } }
    var showDismissalAccessory: Bool = false { didSet { updateTextFieldProperties() } }
    var placeholder: String = "" { didSet { updateTextFieldProperties() } }
    var returnAction: ActionClosure?
    /// A closure that can be used to perform attributed string formatting on the text before it is displayed.
    ///
    /// - Warning: This closure should not modify the text, it must only apply string attributes.
    var textAttributer: Attributer? { didSet { handleTextAttributerSet() } }
    var placeholderAttributer: Attributer? { didSet { setTextFieldPlaceholder() } }
    // Input
    private var decoratedInput: String { return textField?.text ?? "" }
    private(set) var semanticInput: String = ""
    // Value
    var _value: Value
    var value: Value { get { return _value } set { setValue(newValue) } }
    var validatedValue: Value { return validate(value: value) == nil ? value : emptyValue }
    /// A handler that will be called whenever the value is changed by the user (even while typing).
    var valueEditedHandler: ValueEditedHandler?
    /// The original value when the text field begins editing. Meant to be set only by the editor delegate.
    var originalValue: Value?
    private var equalityFunction: EqualityFunction

    /// Whether the text field text should be set to the canonical form of the value after editing.
    ///
    /// The canonical form of the value is the result of passing it into `decoratedString(fromValue:)`.
    var canoncalizeAfterEditing: Bool { return true }

    /// The value that corresponds to empty input. By default, the placeholder is set to this value.
    var emptyValue: Value {
        if let valueType = Value.self as? AnyOptional.Type { return valueType.any_none as! Value }
        if Value.self == String.self { return "" as! Value }
        return value
    }

    typealias ValueEditedHandler = (Value) -> Void
    typealias Attributer = (String) -> NSAttributedString
    typealias EqualityFunction = (Value, Value) -> Bool

    // MARK: Initialization
    init(initialValue: Value, equalityFunction: @escaping EqualityFunction) {
        _value = initialValue
        self.equalityFunction = equalityFunction
        super.init()
        placeholder = decoratedInput(fromValue: emptyValue)
        updateTextFromValue()
    }

    // MARK: General
    @objc(attachToTextField:)
    func attach(to textField: UITextField) {
        self.textField = textField
        updateTextFieldProperties()
        updateTextFromValue()
    }

    private func updateTextFieldProperties() {
        guard let textField = textField else { return }
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.delegate = self
        textField.inputAccessoryView = showDismissalAccessory ? dismissalAccessory : nil
        textField.isSecureTextEntry = isSecureTextEntry
        setTextFieldPlaceholder()
    }

    private func updateTextFromValue() {
        setTextFieldText(equalityFunction(value, emptyValue) ? "" : decoratedInput(fromValue: value))
        self.semanticInput = semanticInput(fromValue: value)
    }

    private func setTextFieldText(_ text: String?) {
        guard let textField = textField else { return }
        if let text = text, let attributer = textAttributer {
            let attributedText = attributer(text)
            assert(attributedText.string == text, "attributer should not modify the text, it must only apply string attributes.")
            textField.attributedText = attributedText
        } else {
            textField.text = text
        }
    }

    private func setTextFieldPlaceholder() {
        guard let textField = textField else { return }
        if let attributer = placeholderAttributer {
            let attributedPlaceholder = attributer(placeholder)
            assert(attributedPlaceholder.string == placeholder, "attributer should not modify the text, it must only apply string attributes.")
            textField.attributedPlaceholder = attributedPlaceholder
        } else {
            textField.placeholder = placeholder
        }
    }

    private func setValue(_ value: Value) {
        let oldValue = self.value
        // Sanitize
        let value = sanitize(value: value)
        if !shouldAllow(value: value) { ZLWarn("Sanitization for \(type(of: self)) returned a disallowed value: \(value)") }
        // Set
        _value = value
        // Update
        if !(textField?.isEditing == true && equalityFunction(oldValue, value)) {
            updateTextFromValue()
        }
    }

    private func handleTextAttributerSet() {
        guard let textField = textField else { return }
        let selection = textField.selection
        setTextFieldText(textField.text)
        if let selection = selection { textField.select(selection) }
    }

    // MARK: Text Field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        // TODO: Rejected paste still modifies the cursor position
        let decoratedInput = (textField.text ?? "")
        let decoratedSelection = String.Index(encodedOffset: range.lowerBound) ..< String.Index(encodedOffset: range.upperBound)
        let decoratedEdit = replacementString
        // Convert to semantic
        let (semanticInput, semanticSelection) = self.semanticInput(fromDecoratedInput: decoratedInput, selection: decoratedSelection)
        let semanticEdit = self.semanticEdit(fromDecoratedEdit: decoratedEdit)
        // Perform edit
        guard let (newSemanticInput, newSemanticSelection) = performSemanticEdit(semanticEdit, on: semanticInput, selection: semanticSelection) else { return false }
        // Validate new input & value
        guard shouldAllow(semanticInput: newSemanticInput) else { return false }
        let newValue = self.value(fromSemanticInput: newSemanticInput)
        guard shouldAllow(value: newValue) else { return false }
        // Convert to decorated
        let (newDecoratedString, newDecoratedSelection) = self.decoratedInput(fromSemanticInput: newSemanticInput, selection: newSemanticSelection)
        // Perform changes & set value
        setTextFieldText(!newSemanticInput.isEmpty ? newDecoratedString : nil)
        textField.select(newDecoratedSelection)
        self.semanticInput = newSemanticInput
        _value = newValue
        valueEditedHandler?(value)
        // Always return false, as we performed the changes manually above
        return false
    }

    // TODO: Modify selection on begin editing to fix cursor position when we have a suffix?
    func textFieldDidBeginEditing(_ textField: UITextField) {
        originalValue = value
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFromValue()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnAction = returnAction {
            returnAction()
        } else if let nextInput = textField.nextInput {
            nextInput.becomeFirstResponder()
        }
        return true
    }

    // MARK: Dismissal Accessory
    private lazy var dismissalAccessory: ZLDismissalInputAccessory = {
        let accessory = ZLDismissalInputAccessory.loadFromNib()!
        accessory.delegate = self
        return accessory
    }()

    func dismissalInputAccessoryCancelTapped(_ inputAccessory: ZLDismissalInputAccessory!) {
        _value = originalValue ?? emptyValue
        valueEditedHandler?(value)
        textField!.endEditing(true)
    }

    func dismissalInputAccessoryDoneTapped(_ inputAccessory: ZLDismissalInputAccessory!) {
        textField!.endEditing(true)
    }

    // MARK: Decorated <=> Semantic
    func semanticInput(fromDecoratedInput decoratedInput: String, selection decoratedSelection: Range<String.Index>) -> (String, Range<String.Index>) {
        return (decoratedInput, decoratedSelection)
    }

    func decoratedInput(fromSemanticInput semanticInput: String, selection semanticSelection: Range<String.Index>) -> (String, Range<String.Index>) {
        return (semanticInput, semanticSelection)
    }

    func semanticEdit(fromDecoratedEdit edit: String) -> String {
        return edit
    }

    func performSemanticEdit(_ edit: String, on input: String, selection: Range<String.Index>) -> (String, Range<String.Index>)? {
        let newInput = input.replacingCharacters(in: selection, with: edit)
        let newUTF16Index = String.Index(encodedOffset: selection.lowerBound.encodedOffset + edit.utf16.count)
        let newCursorIndex = newUTF16Index != newInput.utf16.endIndex ? newInput.rangeOfComposedCharacterSequence(at: newUTF16Index).lowerBound : newInput.endIndex
        return (newInput, newCursorIndex ..< newCursorIndex)
    }

    // MARK: Value <=> Semantic
    func value(fromSemanticInput input: String) -> Value {
        precondition(Value.self == String.self, "Subclasses must override this method if Value is any type other than String.")
        return input as! Value
    }

    func semanticInput(fromValue value: Value) -> String {
        precondition(Value.self == String.self, "Subclasses must override this method if Value is any type other than String.")
        return value as! String
    }

    // MARK: Validation
    /// Returns whether the given semantic input should be allowed to occur.
    ///
    /// By default, the editor stops any edits that result in a semantic input for which this method returns `false`.
    func shouldAllow(semanticInput input: String) -> Bool { return true }

    /// Returns whether the value should be allowed to occur in the text field.
    ///
    /// By default, the editor stops any edits that result in a value for which this method returns `false`.
    func shouldAllow(value: Value) -> Bool { return true }

    /// Constrains the value to a normalized allowable value.
    ///
    /// Subclasses should override this method if not all values are allowed and/or any value has a normalized form.
    /// This sanitization will automatically be applied to any value set programmatically.
    /// - Note: The returned value is required to pass `shouldAllow(value:)`, but not necessarily `validate(value:)`.
    func sanitize(value: Value) -> Value { return value }

    /// Validates the value and returns an error if it does not pass validation.
    ///
    /// This is generally not called by the editor itself but by the consumer of the editor,
    /// and shown in the UI (by the caller) only when the user tries to continue w the invalid value, i.e. not as-you-type.
    ///
    /// Subclasses can override to provide error-based validation. The return error should contains descriptions
    /// suitable for display to the user.
    func validate(value: Value) -> Error? { return nil }

    // MARK: Convenience
    // If you implemented the required methods listed under subclassing notes, these methods will automatically work.

    func semanticInput(fromDecoratedInput input: String) -> String {
        let dummySelection = input.endIndex..<input.endIndex
        let (result, _) = semanticInput(fromDecoratedInput: input, selection: dummySelection)
        return result
    }

    func decoratedInput(fromSemanticInput input: String) -> String {
        let dummySelection = input.endIndex..<input.endIndex
        let (result, _) = decoratedInput(fromSemanticInput: input, selection: dummySelection)
        return result
    }

    func value(fromDecoratedInput input: String) -> Value {
        return value(fromSemanticInput: semanticInput(fromDecoratedInput: input))
    }

    func decoratedInput(fromValue value: Value) -> String {
        return decoratedInput(fromSemanticInput: semanticInput(fromValue: value))
    }

    // MARK: Obj-C
    var objc_value: Any {
        get { return value }
        set { value = newValue as! Value }
    }
    var objc_valueEditedHandler: (Any) -> Void {
        get { return valueEditedHandler as! (Any) -> Void }
        set { valueEditedHandler = newValue }
    }
    var objc_textField: UITextField? {
        get { return textField }
    }
}

extension ZLStringEditor where Value : Equatable {
    convenience init(initialValue: Value) {
        self.init(initialValue: initialValue, equalityFunction: ==)
    }
}

// MARK: Utility
extension UITextField {
    var selection: Range<String.Index>? {
        guard let selectedTextRange = selectedTextRange else { return nil }
        let startOffset = offset(from: beginningOfDocument, to: selectedTextRange.start)
        let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
        return String.Index(encodedOffset: startOffset) ..< String.Index(encodedOffset: startOffset + length)
    }

    func select(_ range: Range<String.Index>) {
        let nsRange = NSRange(range, in: (text ?? ""))
        let start = position(from: beginningOfDocument, offset: nsRange.location)!
        let end = position(from: start, offset: nsRange.length)!
        selectedTextRange = textRange(from: start, to: end)
    }
}

// MARK: Obj-C
extension UIViewController {
    func currencyEditor() -> ZLAnyStringEditor {
        return ZLNumberEditor.currencyEditor(alwaysShowDecimal: false, range: 0...1_000_000_000)
    }
}

extension UIView {
    class func currencyEditor() -> ZLAnyStringEditor {
        return ZLNumberEditor.currencyEditor(alwaysShowDecimal: false, range: 0...1_000_000_000)
    }
    class func percentageEditor() -> ZLAnyStringEditor {
        return ZLNumberEditor.percentageEditor(maxDecimalPlaces: 3, range: 0...100)
    }
}

@objc protocol ZLAnyStringEditor {
    var objc_value: Any { get set }
    var objc_valueEditedHandler: (Any) -> Void { get set }
    var objc_textField: UITextField? { get }
    @objc(attachToTextField:)
    func attach(to textField: UITextField)
}



// MARK: - Protocols

protocol ZLEditor : class {
    var value: Value { get set }
    var valueEditedHandler: ValueEditedHandler? { get set }

    associatedtype Value
    typealias ValueEditedHandler = (Value) -> Void
}

protocol ZLModalEditor : ZLEditor {
    func show()
}
