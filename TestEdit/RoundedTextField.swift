//
// Copyright © 2022 Monvel LTD. All rights reserved.
//
// Created by Mike Karpenko
//

import UIKit

protocol TextFieldProtocol: UITextField {
    var bordersColor: UIColor { get set }
    var activeBordersColor: UIColor { get set }

    var titleLabelColor: UIColor { get set }
    var titleFont: UIFont { get set }
    var titleText: String? { get set }

    var textFont: UIFont { get set }
    var textFieldTextColor: UIColor { get set }
    var textFieldDisabledTextColor: UIColor { get set }
    var backgroundDisabledColor: UIColor { get set }
    var padding: UIEdgeInsets { get set }
    var placeholder: String? { get set }

    var hint: String? { get set }
    var hintFont: UIFont { get set }
    var hintColor: UIColor { get set }

    var errorText: String? { get set }
    var errorFont: UIFont { get set }
    var errorColor: UIColor { get set }
    var errorBordersColor: UIColor { get set }
}

public class RoundedTextField: UITextField, TextFieldProtocol {
    // MARK: - Public properties

    public var bordersColor: UIColor = .systemGray {
        didSet {
            self.updateBordersColor()
        }
    }

    public var errorBordersColor: UIColor = .systemRed {
        didSet {
            self.updateBordersColor()
        }
    }

    public var activeBordersColor: UIColor = .cyan {
        didSet {
            self.updateBordersColor()
        }
    }

    public var errorColor: UIColor = .systemRed {
        willSet {
            self.footerLabel.textColor = newValue
        }
    }

    public var hintColor: UIColor = .systemGray

    public var titleLabelColor: UIColor = .systemGray {
        willSet {
            self.titleLabel.textColor = newValue
        }
    }

    public var textFieldTextColor: UIColor = .darkGray {
        willSet {
            self.textColor = newValue
            self.prefixLabel.textColor = newValue
        }
    }

    public var textFieldDisabledTextColor: UIColor = .gray
    public var backgroundDisabledColor: UIColor = .gray.withAlphaComponent(0.7)

    public var errorFont: UIFont = .systemFont(ofSize: 18.0, weight: .regular) {
        willSet {
            self.footerLabel.font = newValue
        }
    }

    public var hintFont: UIFont = .systemFont(ofSize: 18.0, weight: .regular)

    public var titleFont: UIFont = .systemFont(ofSize: 18.0, weight: .regular) {
        willSet {
            self.titleLabel.font = newValue
        }
    }

    public var textFont: UIFont = .systemFont(ofSize: 18.0, weight: .regular) {
        willSet {
            self.font = newValue
            self.prefixLabel.font = newValue
        }
    }

    public var padding = UIEdgeInsets() {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var errorText: String? {
        didSet {
            let text = errorText?.isEmpty == true ? nil : errorText
            setupBottomLabel(error: text, hint: hint)
        }
    }

    private func setupBottomLabel(error: String? = nil, hint: String? = nil) {
        var text = ""
        if let err = error, !err.isEmpty {
            text = err
            self.footerLabel.textColor = errorColor
            self.footerLabel.font = errorFont
        } else if let hint = hint {
            text = hint
            self.footerLabel.textColor = hintColor
            self.footerLabel.font = hintFont
        }

        self.footerLabel.text = text
        self.footerLabel.sizeToFit()
        self.updateBordersColor()
        self.updateFooterLabelPosition()

        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.footerLabel.alpha = text.isEmpty ? 0.0 : 1.0
        })
    }

    public var titleText: String? {
        didSet {
            self.titleLabel.text = titleText
            self.titleLabel.sizeToFit()
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    public var prefixText: String? {
        didSet {
            self.prefixLabel.text = prefixText
            self.prefixLabel.sizeToFit()
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override public var placeholder: String? {
        get {
            return placeholderBackup
        }
        set {
            placeholderBackup = newValue
        }
    }

    func setRightView(_ newValue: UIView?) {
        if let view = newValue,
           view != self.rightStackView,
           !self.rightStackView.arrangedSubviews.contains(view) {
            if self.rightStackView.arrangedSubviews.count > 1,
               let lastView = self.rightStackView.arrangedSubviews[safe: 1] {
                lastView.removeFromSuperview()
            }
            self.rightStackView.insertArrangedSubview(view, at: 1)
        } else if let lastView = self.rightStackView.arrangedSubviews[safe: 1] {
            lastView.removeFromSuperview()
        }
        rightStackView.sizeToFit()
        rightStackView.layoutIfNeeded()
        setNeedsLayout()
    }

    public var hint: String? {
        didSet {
            setupBottomLabel(error: errorText, hint: hint)
        }
    }

    private lazy var borderBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = self.bordersColor.cgColor
        view.layer.borderWidth = bordersWidth
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Private properties

    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0, weight: .regular)
        label.numberOfLines = 0
        label.textColor = self.errorColor
        label.backgroundColor = .clear
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var clearButton: UIButton = {
        let btn = UIButton()
        btn.alpha = 0.0
        btn.setImage(UIImage(named: "cross"), for: .normal)
        btn.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
        btn.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24))
        return btn
    }()

    private lazy var rightStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [clearButton])
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.backgroundColor = .clear
        return sv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = self.titleLabelColor
        label.text = self.titleText
        label.backgroundColor = .clear
        return label
    }()

    private lazy var prefixLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = textFieldTextColor
        label.text = self.prefixText
        return label
    }()

    private var isError: Bool {
        return !(self.errorText ?? "").isEmpty
    }

    private let minTextFieldHeight: CGFloat = 40.0
    private let bordersWidth: CGFloat = 1.0
    private let sideInset: CGFloat = 16.0
    private let verticalInset: CGFloat = 6.0
    private var placeholderBackup: String?
    private let spaceTopError: CGFloat = 0.0

    // MARK: - Initializations and Deallocations

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    // MARK: - Override methods

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.updateTitleLabelPosition()
        self.updateBorderBackgroundPosition()
        self.updatePrefixPosition()
        self.updateFooterLabelPosition()
    }

    override public var isEnabled: Bool {
        willSet {
            textColor = newValue ? textFieldTextColor : textFieldDisabledTextColor
            borderBackgroundView.backgroundColor = newValue ? .clear : backgroundDisabledColor
        }
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.internalRect(forBounds: bounds)
    }

    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return self.internalRect(forBounds: bounds)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.internalRect(forBounds: bounds)
    }

    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let leftBounds = super.leftViewRect(forBounds: bounds)
        return CGRect(x: sideInset, y: 0, width: leftBounds.width, height: borderBackgroundView.frame.height)
    }

    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightBounds = super.rightViewRect(forBounds: bounds)
        let x = borderBackgroundView.frame.width - borderBackgroundView.layer.borderWidth - rightBounds.size.width - sideInset
        return CGRect(x: x, y: 0, width: rightBounds.width, height: borderBackgroundView.frame.height)
    }

    override public var intrinsicContentSize: CGSize {
        let textFieldIntrinsicContentSize = super.intrinsicContentSize
        let height = max(
            minTextFieldHeight + titleLabelHeight + bordersWidth * 2,
            minTextFieldHeight + titleLabelHeight + bordersWidth * 2 + footerLabelHeight
        )
        return CGSize(width: textFieldIntrinsicContentSize.width, height: height)
    }

    // MARK: - TextFieldDelegate

    @objc
    fileprivate func textFieldAllEditingEvents() {
        self.updateBordersColor()
        clearButton.alpha = text?.isEmpty == true ? 0.0 : 1.0
    }

    @objc
    fileprivate func textFieldDidChanged() {
        if errorText != nil {
            self.errorText = nil
        }
    }

    @objc
    fileprivate func textFieldDidBeginEditing() {
        attributedPlaceholder = NSAttributedString(string: placeholderBackup ?? "")
        prefixLabel.text = prefixText
    }

    @objc
    fileprivate func textFieldDidEndEditing() {
        attributedPlaceholder = nil
        updateTitleLabelPosition()
        if text?.isEmpty == true {
            prefixLabel.text = nil
        }
    }

    // MARK: - Private methods

    private func commonInit() {
        font = textFont
        textColor = textFieldTextColor
        prefixLabel.textColor = textColor
        prefixLabel.font = font

        addSubview(borderBackgroundView)
        addSubview(titleLabel)
        addSubview(footerLabel)
        addSubview(prefixLabel)

        rightView = rightStackView
        rightViewMode = .always
        clearButtonMode = .never
        borderStyle = .none

        addTarget(self, action: #selector(textFieldAllEditingEvents), for: .allEditingEvents)
        addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    private func internalRect(forBounds bounds: CGRect) -> CGRect {
        let prefixInset = prefixLabel.frame.width > 0 ? prefixLabel.frame.width + 3 : 0
        return bounds
            .inset(by: paddingInset())
            .inset(by: UIEdgeInsets(
                top: titleLabelHeight,
                left: sideInset + prefixInset,
                bottom: footerLabelHeight,
                right: sideInset
            ))
            .inset(by: UIEdgeInsets(
                top: bordersWidth,
                left: bordersWidth,
                bottom: bordersWidth,
                right: bordersWidth
            ))
    }

    private func paddingInset() -> UIEdgeInsets {
        var padding = self.padding
        if let leftView = self.leftView {
            padding.left += leftView.frame.width
        }
        if let rightView = self.rightView {
            padding.right += rightView.frame.width
        }
        return padding
    }

    private func updateBordersColor() {
        if self.isError {
            borderBackgroundView.layer.borderColor = errorBordersColor.cgColor
        } else if self.isFirstResponder {
            borderBackgroundView.layer.borderColor = activeBordersColor.cgColor
        } else {
            borderBackgroundView.layer.borderColor = bordersColor.cgColor
        }
    }

    private var footerLabelHeight: CGFloat {
        var errorHeight: CGFloat = 0.0
        if let err = errorText, !err.isEmpty {
            errorHeight = max(20, err.height(withConstrainedWidth: self.bounds.width, font: footerLabel.font))
        } else if let hint = hint {
            errorHeight = max(20, hint.height(withConstrainedWidth: self.bounds.width, font: footerLabel.font))
        }
        return errorHeight
    }

    private var titleLabelHeight: CGFloat {
        if let text = self.titleText, !(text.isEmpty) {
            return max(20, self.titleLabel.bounds.height)
        } else {
            return 0.0
        }
    }

    private func updateTitleLabelPosition() {
        let titleLabel = self.titleLabel
        titleLabel.text = self.titleText
        var frame = titleLabel.frame
        if text?.isEmpty == false || isFirstResponder || prefixText?.nilIfEmpty() != nil {
            frame.origin.y = verticalInset
        } else {
            frame.origin.y = self.borderBackgroundView.bounds.midY - titleLabel.frame.height / 2
        }
        frame.origin.x = sideInset + (leftView?.frame.width ?? 0)
        frame.size.width = self.bounds.width - bordersWidth - (leftView?.frame.width ?? 0) - (rightView?.frame.width ?? 0) - sideInset * 2

        titleLabel.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            titleLabel.frame = frame
        }
    }

    private func updatePrefixPosition() {
        var frame = prefixLabel.frame
        frame.origin.x = titleLabel.frame.origin.x
        frame.origin.y = borderBackgroundView.bounds.height - minTextFieldHeight - bordersWidth
        frame.size.height = minTextFieldHeight
        prefixLabel.layoutIfNeeded()
        prefixLabel.frame = frame
    }

    private func updateBorderBackgroundPosition() {
        var frame = borderBackgroundView.frame
        frame.origin.x = 0
        frame.origin.y = 0
        frame.size.height = minTextFieldHeight + titleLabelHeight + bordersWidth * 2
        frame.size.width = self.bounds.width
        borderBackgroundView.layoutIfNeeded()
        borderBackgroundView.frame = frame
    }

    private func updateFooterLabelPosition() {
        var frame = footerLabel.frame
        frame.origin.x = sideInset
        frame.origin.y = self.bounds.height - footerLabelHeight + spaceTopError
        frame.size = CGSize(width: self.bounds.width - sideInset * 2, height: footerLabelHeight)
        footerLabel.layoutIfNeeded()
        footerLabel.frame = frame
    }

    @objc
    private func clearPressed() {
        self.text = nil
        sendActions(for: .editingChanged)
    }
}
