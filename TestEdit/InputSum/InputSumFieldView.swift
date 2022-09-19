//
//  InputSumField.swift
//  TestEdit
//
//  Created by Mike Karpenko on 19.09.2022.
//

import SnapKit
import UIKit

extension InputSumFieldView {
    struct Appearance {
        let cornerRadius: CGFloat = 12
        let borderWidth: CGFloat = 1
        let textFieldWidthFactor: CGFloat = 0.8
        let textFieldScaleFactor: CGFloat = 0.5
        let textFieldYOffset: CGFloat = 10
        let titleScaleFactor: CGFloat = 0.8
        let textSideInset: CGFloat = 16
        let textFieldWrapperRightOffset: CGFloat = 16
        let textCenterTopOffset: CGFloat = 24
        let textTopOffset: CGFloat = 6
        let textFieldHeight: CGFloat = 24
        let titleTopOffset: CGFloat = 30
        let animationDuration: TimeInterval = 0.3
        let clearButtonSize: CGFloat = 35
        let clearButtonRightInset: CGFloat = 4
        
        let redColor: UIColor = .red
        let blackColor: UIColor = .black
        let whiteColor: UIColor = .white
        let aquaColor: UIColor = .cyan

        let containerHeight: CGFloat = 56
        let errorImageRightInset: CGFloat = 16
        let errorImageSize: CGFloat = 16

        let duration = 0.15
    }
}

protocol InputFieldFocusDelegate: AnyObject {
    func didTap(_ field: InputSumFieldView)
}

class InputSumFieldView: UIView {
    let appearance = Appearance()
    /// superview responsible for calling layoutIfNeeded upon inputfield's layout changes
    weak var enclosingSuperview: UIView?
    weak var delegate: InputFieldFocusDelegate?
    var textFieldYConstraint: Constraint!
    // both states because SnapKit treats multiplied constraint as a new one
    var textFieldWidthConstraint: Constraint!
    var textFieldWidthConstraint2x: Constraint!
    var errorLabelHiddenConstraint: Constraint!
//    private let fontFactory: MOBFontFactory = .shared

    var shouldUpdate: ((String) -> Bool)?
    var didUpdateText: ((String) -> Void)?
    var didBeginEditing: (() -> Void)?
    var didEndEditing: ((String) -> Void)?
    var shouldReturn: (() -> Bool)?

    var hideClearButtonOnEmptyText: Bool = false

    private var didInitialSetup = false

    enum State {
        case normal
        case error(errorMessage: NSAttributedString)
    }

    var state: State = .normal

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    lazy var textFieldWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()

    lazy var errorContainerView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var errorFlashOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = appearance.redColor
        view.layer.cornerRadius = appearance.cornerRadius
        view.alpha = 0
        return view
    }()

    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = appearance.redColor
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        return label
    }()

    lazy var textField: CustomTextField = {
        let textField = CustomTextField()
        textField.customDelegate = self
        textField.textColor = appearance.blackColor
        textField.tintColor = appearance.aquaColor
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textAlignment = .left
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardAppearance = .dark
        return textField
    }()

    lazy var selectionBorderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = appearance.cornerRadius
        view.layer.borderColor = appearance.aquaColor.cgColor
        view.layer.borderWidth = appearance.borderWidth
        view.alpha = 0
        return view
    }()

    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "textFieldClearIcon"), for: .normal)
        button.alpha = 0
        return button
    }()

    lazy var errorIcon: UIImageView = {
        let view = UIImageView(image: UIImage(named: "textFieldErrorIcon"))
        view.isHidden = true
        view.contentMode = .scaleAspectFit
        view.isAccessibilityElement = true
        return view
    }()

    var isEmpty: Bool {
        return textField.text?.isEmpty ?? true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        addSubviews()
        layout()
        textField.delegate = self
        backgroundColor = appearance.whiteColor
        clipsToBounds = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let textFieldTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        containerView.addGestureRecognizer(tapRecognizer)
        textField.addGestureRecognizer(textFieldTapRecognizer)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        if #available(iOS 12, *) {
            textField.textContentType = .oneTimeCode
        } else {
            textField.textContentType = .init(rawValue: "")
        }
    }

    private func addSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        containerView.addSubview(selectionBorderView)
        containerView.addSubview(errorFlashOverlay)
        containerView.addSubview(clearButton)
        containerView.addSubview(errorIcon)
        containerView.addSubview(textFieldWrapper)
        textFieldWrapper.addSubview(textField)
        addSubview(errorContainerView)
        errorContainerView.addSubview(errorLabel)
    }

    private func layout() {
        textFieldWrapper.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(appearance.textSideInset)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(clearButton.snp.left).offset(-appearance.textFieldWrapperRightOffset)
        }

        containerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(appearance.containerHeight)
        }

        textField.snp.makeConstraints { make in
            textFieldYConstraint = make.top.equalToSuperview().offset(appearance.textCenterTopOffset).constraint
            textFieldWidthConstraint = make.width.equalTo(textFieldWrapper).multipliedBy(1).constraint
            textFieldWidthConstraint2x = make.width.equalTo(textFieldWrapper).multipliedBy(2).constraint
            make.height.equalTo(appearance.textFieldHeight)
            make.left.equalToSuperview()
        }
        textFieldWidthConstraint2x.deactivate()

        clearButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(appearance.clearButtonRightInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(appearance.clearButtonSize)
        }

        errorIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(appearance.errorImageRightInset)
            make.centerY.equalTo(textField)
            make.size.equalTo(appearance.errorImageSize)
        }

        errorContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(containerView.snp.bottom)
            make.bottom.equalToSuperview()
            errorLabelHiddenConstraint = make.height.equalTo(0).constraint
        }

        errorLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(appearance.textSideInset)
            make.top.equalTo(containerView.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(4)
        }
        errorFlashOverlay.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !didInitialSetup {
            selectionBorderView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            unfocus(animated: false)
            didInitialSetup = true
        }
    }

    override var isFirstResponder: Bool {
        return self.textField.isFirstResponder
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        return self.textField.resignFirstResponder()
    }

    @objc
    private func didTap() {
        delegate?.didTap(self)
        if !isFirstResponder {
            becomeFirstResponder()
        }
    }

    @objc
    private func clearText() {
        textField.text = ""
        textField.sendActions(for: .valueChanged)
    }

    func showBackgroundSelection(animated: Bool = true) {
        selectionBorderView.alpha = 1
    }

    func hideBackgroundSelection(animated: Bool = true) {
        selectionBorderView.alpha = 1
    }

    private func focus(animated: Bool = true) {
        UIView.animate(withDuration: animated ? appearance.animationDuration : 0, animations: {
            if self.textField.transform != .identity {
                self.textField.transform = .identity
            }
            let scaling = CGAffineTransform(scaleX: self.appearance.titleScaleFactor, y: self.appearance.titleScaleFactor)
            self.clearButton.alpha = 1
            if self.isEmpty {
                self.layoutFocused()
                self.layoutIfNeeded()
            }
        }, completion: { _ in
            let duration = self.textField.isSecureTextEntry ? 0 : 0.2
            UIView.animate(withDuration: duration, animations: {
                if !self.isEmpty {
                    self.layoutFocused()
                    self.layoutIfNeeded()
                }
            })
        })
        showBackgroundSelection(animated: animated)
    }

    private func unfocus(animated: Bool = true) {
        if !isEmpty {
            self.layoutUnfocused()
            self.layoutIfNeeded()
        }

        let block = {
            self.clearButton.alpha = 0

            if self.isEmpty {
                self.layoutUnfocused()
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animate(withDuration: appearance.animationDuration, animations: block)
        } else {
            block()
        }

        hideBackgroundSelection(animated: animated)
    }

    func layoutFocused() {
        textFieldYConstraint.update(inset: appearance.textCenterTopOffset)
        textFieldWidthConstraint.activate()
        textFieldWidthConstraint2x.deactivate()
    }

    func layoutUnfocused() {
        textFieldYConstraint.update(inset: appearance.textCenterTopOffset)
        if isEmpty {
            textFieldWidthConstraint.activate()
            textFieldWidthConstraint2x.deactivate()
        } else {
            textFieldWidthConstraint.deactivate()
            textFieldWidthConstraint2x.activate()
        }
    }

    func updateLayoutOnTextChange(from: String, to: String) {
        guard !textField.isFirstResponder else { return }
        let wasEmpty = from.isEmpty && !to.isEmpty
        let becameEmpty = !from.isEmpty && to.isEmpty
        if wasEmpty || becameEmpty {
            unfocus(animated: false)
        }
    }

    func showErrorIcon() {
        errorIcon.isHidden = false
        clearButton.isHidden = true
    }

    func hideErrorIcon() {
        errorIcon.isHidden = true
        clearButton.isHidden = false
    }

    func showErrorMessage(errorMessage: NSAttributedString) {
        UIView.animate(withDuration: 0.3, animations: {
            self.errorLabelHiddenConstraint.deactivate()
            self.errorLabel.alpha = 1
            self.errorLabel.attributedText = errorMessage
            self.enclosingSuperview?.layoutIfNeeded()
        })
    }

    func hideErrorMessage() {
        UIView.animate(withDuration: 0.3, animations: {
            self.errorLabelHiddenConstraint.activate()
            self.errorLabel.alpha = 0
            self.enclosingSuperview?.layoutIfNeeded()
        }, completion: { _ in
            self.errorLabel.text = ""
        })
    }

    func flashError() {
        let show = {
            self.errorFlashOverlay.alpha = 1
        }
        let hide = {
            self.errorFlashOverlay.alpha = 0
        }

        UIView.animate(withDuration: appearance.duration, animations: show) { _ in
            UIView.animate(
                withDuration: self.appearance.duration,
                delay: self.appearance.duration + 0.05,
                options: [],
                animations: hide
            )
        }
    }

    func configureAccessibilityLabels(
        textField: String?,
        clearButton: String?
    ) {
        self.textField.accessibilityLabel = textField
        self.clearButton.accessibilityLabel = clearButton
    }

    func configureAccessibilityIdentifiers(
        textField: String?,
        error: String,
        clearButton: String?,
        errorIcon: String?
    ) {
        self.textField.accessibilityIdentifier = textField
        self.errorLabel.accessibilityIdentifier = error
        self.clearButton.accessibilityIdentifier = clearButton
        self.errorIcon.accessibilityIdentifier = errorIcon
    }

    private func updateErrorUI() {
        if isFirstResponder {
            hideErrorIcon()
            switch state {
            case .normal:
                hideErrorMessage()
            case .error(let errorMessage):
                showErrorMessage(errorMessage: errorMessage)
            }
        } else {
            hideErrorMessage()
            switch state {
            case .normal:
                hideErrorIcon()
            case .error(let errorMessage):
                showErrorIcon()
                errorIcon.accessibilityLabel = errorMessage.string
            }
        }
    }
}

extension InputSumFieldView: UITextFieldDelegate, CustomTextDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        self.didBeginEditing?()
        focus()
        updateErrorUI()
        updateClearButtonVisibility()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.didEndEditing?(textField.text ?? "")
        unfocus()
        updateErrorUI()
        updateClearButtonVisibility()
    }

    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        if let textRange = Range(range, in: currentText) {
            let nextText = currentText.replacingCharacters(
                in: textRange,
                with: string
            )
            let shouldUpdate = self.shouldUpdate?(nextText) ?? true
            if shouldUpdate {
                updateLayoutOnTextChange(from: currentText, to: nextText)
            }
            return shouldUpdate
        }
        return true
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return shouldReturn?() ?? true
    }

    @objc func textFieldDidChange(textfield: UITextField) {
        updateClearButtonVisibility()
        didUpdateText?(textField.text ?? "")
        updateErrorUI()
    }

    // programmatic input change detection
    func textDidChange(from: String?, to: String?) {
        updateClearButtonVisibility()
        didUpdateText?(textField.text ?? "")
        updateLayoutOnTextChange(from: from ?? "", to: to ?? "")
    }

    func updateClearButtonVisibility() {
        clearButton.isHidden = (textField.text ?? "").isEmpty && hideClearButtonOnEmptyText
    }
}

