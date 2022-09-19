

import UIKit

public class TextField: UITextField {
    // MARK: - Public properties

    public var lineColor: UIColor = .systemGray {
        didSet {
            self.updateLineColor()
        }
    }

    public var errorLineColor: UIColor = .systemRed {
        didSet {
            self.updateLineColor()
        }
    }

    public var activeLineColor: UIColor = .systemBlue {
        didSet {
            self.updateLineColor()
        }
    }

    public var errorColor: UIColor = .systemGray {
        didSet {
            self.errorLabel.textColor = errorColor
        }
    }

    public var titleLabelColor: UIColor = .systemBlue {
        didSet {
            self.titleLabel.textColor = titleLabelColor
        }
    }

    public var padding = UIEdgeInsets() {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var errorText: String? {
        didSet {
            self.errorLabel.text = errorText
            self.errorLabel.sizeToFit()
            self.updateLineColor()

            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()

            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.errorLabel.alpha = (self.errorText ?? "").isEmpty ? 0.0 : 1.0
            })
        }
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

    // Reset error when begin typing in text field.

    public var isResetError = true

    // MARK: - Private properties

    private var lineLayer = CALayer()

    private let errorLabel = UILabel()

    private let titleLabel = UILabel()

    private var isError: Bool {
        return !(self.errorText ?? "").isEmpty
    }

    private let minTextFieldHeight: CGFloat = 40.0
    private var placeholderBackup: String?

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
        self.updateErrorLabelPosition()
        self.updateTitleLabelPosition()
        self.updateLinePosition()
        self.updateTitleLabel()
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
        let bounds = super.leftViewRect(forBounds: bounds)
        return getRect(forBounds: bounds)
    }

    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = super.rightViewRect(forBounds: bounds)
        return getRect(forBounds: bounds)
    }

    override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = super.clearButtonRect(forBounds: bounds)
        return getRect(forBounds: bounds)
    }

    override public var intrinsicContentSize: CGSize {
        let textFieldIntrinsicContentSize = super.intrinsicContentSize
        let height = ceil(max(
            self.minTextFieldHeight + self.titleLabelHeight + self.lineLayerHeight,
            self.minTextFieldHeight + self.titleLabelHeight + self.lineLayerHeight + self.errorLabelHeight
        ))
        return CGSize(width: textFieldIntrinsicContentSize.width, height: height)
    }

    // MARK: - TextFieldDelegate

    @objc fileprivate func textFieldDidChanged() {
        if self.isResetError {
            self.errorText = nil
        }
        self.updateLineColor()
        self.updateTitleLabel()
    }

    @objc fileprivate func textFieldDidBeginEditing() {
        placeholderBackup = placeholder
        placeholder = nil
    }

    @objc fileprivate func textFieldDidEndEditing() {
        placeholder = placeholderBackup
    }

    // MARK: - Private methods

    private func commonInit() {
        self.font = UIFont.systemFont(ofSize: 18.0, weight: .regular)

        let titleLabel = self.titleLabel
//        titleLabel.font = Fonts.callout
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.textColor = self.activeLineColor
        titleLabel.text = self.titleText
        titleLabel.backgroundColor = .clear
        titleLabel.alpha = 0
        self.addSubview(titleLabel)

        let errorLabel = self.errorLabel
//        errorLabel.font = Fonts.callout
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.numberOfLines = 0
        errorLabel.textColor = self.errorColor
        errorLabel.text = self.errorText
        errorLabel.backgroundColor = .clear
        errorLabel.alpha = 0
        self.addSubview(errorLabel)

        self.setupBottomBorder(color: self.lineColor)
        self.addTarget(self, action: #selector(textFieldDidChanged), for: .allEditingEvents)
        self.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    private func setupBottomBorder(color: UIColor) {
        self.borderStyle = .none

        let lineLayer = self.lineLayer
        lineLayer.backgroundColor = color.cgColor
        lineLayer.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: 1)
        self.lineLayer = lineLayer
        self.layer.addSublayer(lineLayer)
    }

    private func internalRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
            .inset(by: self.paddingInset())
            .inset(by: UIEdgeInsets(top: self.titleLabelHeight, left: 0, bottom: self.errorLabelHeight, right: 0))
            .inset(by: UIEdgeInsets(top: 0, left: 0, bottom: ceil(self.lineLayerHeight), right: 0))
    }

    private func getRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = bounds
        bounds.size.height = self.bounds.height - self.titleLabelHeight - self.errorLabelHeight - self.lineLayerHeight
        bounds.origin.y = self.bounds.height - self.minTextFieldHeight - self.errorLabelHeight - self.lineLayerHeight
        return bounds
    }

    private func paddingInset() -> UIEdgeInsets {
        var padding = self.padding
        let pairs = [
            (self.leftView, self.leftViewMode, { (rect: CGRect) in
                padding.left += rect.size.width
            }),
            (self.rightView, self.rightViewMode, { (rect: CGRect) in
                padding.right += rect.size.width
            })
        ]
        pairs.forEach { view, viewMode, operation in
            view.map {
                if viewMode == .always || viewMode == .unlessEditing {
                    operation($0.frame)
                }
            }
        }

        if self.clearButtonMode == .always || self.clearButtonMode == .whileEditing, isEditing {
            padding.right = 28
        }

        return padding
    }

    private func updateLineColor() {
        if self.isError {
            self.setLineColor(color: self.errorLineColor)
        } else if self.isFirstResponder {
            self.setLineColor(color: self.activeLineColor)
        } else {
            self.setLineColor(color: self.lineColor)
        }
    }

    private func updateTitleLabel() {
        let alpha: CGFloat = (text ?? "").isEmpty && !(placeholder ?? "").isEmpty ? 0.0 : 1.0
        UIView.animate(withDuration: 0.25) {
            self.titleLabel.alpha = alpha
        }
    }

    private func setLineColor(color: UIColor) {
        self.lineLayer.backgroundColor = color.cgColor
    }

    private var lineLayerHeight: CGFloat {
        return self.lineLayer.bounds.height
    }

    private var errorLabelHeight: CGFloat {
        if self.isError {
            return max(20, self.errorLabel.bounds.height)
        } else {
            return 0.0
        }
    }

    private var titleLabelHeight: CGFloat {
        if let text = self.titleText, !(text.isEmpty) {
            return max(20, self.titleLabel.bounds.height)
        } else {
            return 0.0
        }
    }

    private func updateLinePosition() {
        let lineLayer = self.lineLayer
        var frame = lineLayer.frame
        frame.size.width = self.bounds.width
        frame.origin.y = ceil(self.bounds.height - frame.height - self.errorLabelHeight)
        lineLayer.frame = frame
    }

    private func updateErrorLabelPosition() {
        let errorLabel = self.errorLabel
        let height = errorText?.height(width: self.bounds.width, font: errorLabel.font) ?? 0
        var frame = errorLabel.frame
        frame.origin.y = ceil(self.bounds.height - max(20, height))
        frame.size = CGSize(width: self.bounds.width, height: max(20, height))

        errorLabel.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            errorLabel.frame = frame
        }
    }

    private func updateTitleLabelPosition() {
        let titleLabel = self.titleLabel
        titleLabel.text = self.titleText
        var frame = titleLabel.frame
        frame.origin.y = (text ?? "").isEmpty && !(placeholder ?? "").isEmpty ? self.bounds.midY : 0.0
        frame.size.width = self.bounds.width

        titleLabel.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            titleLabel.frame = frame
        }
    }
}

fileprivate extension String {
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
