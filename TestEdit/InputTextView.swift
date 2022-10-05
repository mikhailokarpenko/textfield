//
// Copyright © 2022 Monvel LTD. All rights reserved.
//
// Created by Mike Karpenko
//

import SnapKit
import UIKit

protocol InputFocusDelegate: AnyObject {
    func didTap(_ field: InputTextView)
}

class InputTextView: UIView {
    private let cyanColor: UIColor = .cyan//Asset.Palette.aqua.color
    private let blackColor: UIColor = .gray//Asset.Palette.grey30.color
    private let grey230: UIColor = .gray//Asset.Palette.grey230.color
    private let redColor: UIColor = .red//Asset.Palette.red.color
    private let grey100: UIColor = .gray//Asset.Palette.grey100.color
    /// superview responsible for calling layoutIfNeeded upon inputfield's layout changes
    weak var enclosingSuperview: UIView?
    weak var delegate: InputFocusDelegate?
    private var bottomLabelHiddenConstraint: Constraint!
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.tintColor = cyanColor
        tv.textAlignment = .left
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.isUserInteractionEnabled = false
        tv.textContainer.lineFragmentPadding = 0
        tv.text = placeholder
        tv.font = placeholderFont
        tv.textColor = placeholderColor
        tv.isHidden = true
        return tv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, textView])
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()
    
    private let clearButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "cross"), for: .normal)
        btn.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    public var errorFont: UIFont = .systemFont(ofSize: 18.0, weight: .regular) {
        willSet {
            self.footerLabel.font = newValue
        }
    }

    public var hintFont: UIFont = .systemFont(ofSize: 18.0, weight: .regular) {
        willSet {
            self.footerLabel.font = newValue
        }
    }
    
    public var textFont: UIFont = .systemFont(ofSize: 18, weight: .regular)
    public var textColor: UIColor = .black
    public var placeholderFont: UIFont = .systemFont(ofSize: 18, weight: .regular)
    public var placeholderColor: UIColor = .lightGray
    
    var placeholder: String?

    var hintText: String? {
        didSet {
            setupBottomLabel(error: errorText, hint: hintText)
        }
    }

    var errorText: String? {
        didSet {
            setupBottomLabel(error: errorText, hint: hintText)
        }
    }

    private lazy var roundedContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = grey230.cgColor
        return view
    }()

    private let footerLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()

    private var isError: Bool {
        (errorText ?? String()).isEmpty == false
    }

    var shouldUpdate: ((String) -> Bool)?
    var didUpdateText: ((String) -> Void)?
    var didBeginEditing: (() -> Void)?
    var didEndEditing: ((String) -> Void)?
    var shouldReturn: (() -> Bool)?

    override var isFirstResponder: Bool {
        return self.textView.isFirstResponder
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        self.textView.isHidden = false
        self.updateClearButtonVisibility()
        return self.textView.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        self.textView.isHidden = self.textView.text == placeholder ? true : false
        self.clearButton.isHidden = true
        return self.textView.resignFirstResponder()
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
        makeConstraints()
        textView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let textFieldTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        roundedContainerView.addGestureRecognizer(tapRecognizer)
        textView.addGestureRecognizer(textFieldTapRecognizer)
    }

    private func addSubviews() {
        roundedContainerView.addSubview(mainStackView)
        roundedContainerView.addSubview(clearButton)
        addSubview(roundedContainerView)
        addSubview(footerLabel)
    }

    private func makeConstraints() {
        let sideInset = 16
        let verticalInset = 6

        mainStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(sideInset)
            make.trailing.equalTo(clearButton.snp.leading)
            make.top.bottom.equalToSuperview().inset(verticalInset)
            make.bottom.equalToSuperview().inset(verticalInset)
        }
        clearButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(sideInset)
            make.height.width.equalTo(24)
        }
        roundedContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.width.equalToSuperview()
            make.height.greaterThanOrEqualTo(56)
        }
        footerLabel.snp.makeConstraints { make in
            make.top.equalTo(roundedContainerView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(sideInset)
            bottomLabelHiddenConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview()
        }
    }

    private func updateBordersColor() {
        if self.isError {
            roundedContainerView.layer.borderColor = redColor.cgColor
        } else if self.isFirstResponder {
            roundedContainerView.layer.borderColor = cyanColor.cgColor
        } else {
            roundedContainerView.layer.borderColor = grey230.cgColor
        }
    }

    @objc
    private func didTap() {
        delegate?.didTap(self)
        if !isFirstResponder {
            becomeFirstResponder()
        }
    }

    @objc
    private func clearPressed() {
        textView.text = nil
        updatePlaceholder()
        updateClearButtonVisibility()
    }

    private func setupBottomLabel(error: String?, hint: String?) {
        var text = String()
        if let err = error, !err.isEmpty {
            text = err
            footerLabel.textColor = redColor
            footerLabel.font = errorFont
        } else if let hint = hint {
            text = hint
            footerLabel.textColor = grey100
            footerLabel.font = hintFont
        }

        self.footerLabel.text = text
        updateBordersColor()

        UIView.animate(withDuration: 0.3) {
            self.footerLabel.alpha = text.isEmpty ? 0.0 : 1.0
            text.isEmpty ? self.bottomLabelHiddenConstraint.activate() : self.bottomLabelHiddenConstraint.deactivate()
            self.enclosingSuperview?.layoutIfNeeded()
        }
    }

    private func updatePlaceholder() {
        if let text = self.textView.text,
           !text.isEmpty,
           text != placeholder {
            self.textView.font = textFont
            self.textView.textColor = textColor
        } else {
            self.textView.text = placeholder
            self.textView.font = placeholderFont
            self.textView.textColor = placeholderColor
            self.textView.selectedTextRange = self.textView.textRange(from: self.textView.beginningOfDocument, to: self.textView.beginningOfDocument)
        }
    }
    
    private func updateClearButtonVisibility() {
        if let text = self.textView.text,
           !text.isEmpty,
           text != placeholder {
            clearButton.isHidden = false
        } else {
            clearButton.isHidden = true
        }
    }
}

extension InputTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?()
        updateBordersColor()
        updatePlaceholder()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        didEndEditing?(textView.text ?? "")
        resignFirstResponder()
        updateBordersColor()
        if self.textView.textColor == placeholderColor {
            self.textView.text = nil
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text == placeholder ? "" : textView.text ?? ""
        if let textRange = Range(range, in: currentText) {
            let nextText = currentText.replacingCharacters(
                in: textRange,
                with: text
            )
            let shouldUpdate = self.shouldUpdate?(nextText) ?? true
            if shouldUpdate {
                textView.text = nextText.isEmpty ? (placeholder ?? "").appending(" ") : currentText
            }
            return shouldUpdate
        }
        textView.text = currentText
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        didUpdateText?(textView.text ?? "")
        updatePlaceholder()
        updateClearButtonVisibility()
    }
}

