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
        return tv
    }()
    private let clearButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "cross"), for: .normal)
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
        return self.textView.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
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
        clipsToBounds = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let textFieldTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        roundedContainerView.addGestureRecognizer(tapRecognizer)
        textView.addGestureRecognizer(textFieldTapRecognizer)
    }

    private func addSubviews() {
        roundedContainerView.addSubview(titleLabel)
        roundedContainerView.addSubview(textView)
        roundedContainerView.addSubview(clearButton)
        addSubview(roundedContainerView)
        addSubview(footerLabel)
    }

    private func makeConstraints() {
        let sideInset = 16

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.leading.equalToSuperview().inset(sideInset)
            make.trailing.equalTo(clearButton.snp.leading).offset(sideInset)
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(sideInset)
            make.trailing.equalTo(clearButton.snp.leading).inset(sideInset)
            make.bottom.equalToSuperview().inset(6)
        }
        clearButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(sideInset)
            make.bottom.greaterThanOrEqualToSuperview().inset(sideInset)
            make.height.width.equalTo(24)
        }
        roundedContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.width.equalToSuperview()
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
}

extension InputTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        didEndEditing?(textView.text ?? "")
        resignFirstResponder()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        if let textRange = Range(range, in: currentText) {
            let nextText = currentText.replacingCharacters(
                in: textRange,
                with: text
            )
            let shouldUpdate = self.shouldUpdate?(nextText) ?? true
            return shouldUpdate
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        didUpdateText?(textView.text ?? "")
    }
}

