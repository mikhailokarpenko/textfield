//
// Copyright © 2022 Monvel LTD. All rights reserved.
//
// Created by Mike Karpenko
//

import SnapKit
import UIKit

class InputTextField: UIView {
    let appearance = Appearance()
    /// superview responsible for calling layoutIfNeeded upon inputfield's layout changes
    weak var enclosingSuperview: UIView?
    weak var delegate: InputFocusDelegate?
    private var bottomLabelHiddenConstraint: Constraint!
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private(set) lazy var textField: UITextField = {
        let tf = UITextField()
        tf.tintColor = appearance.cyanColor
        tf.clearButtonMode = .never
        tf.textAlignment = .left
        tf.isHidden = true
        return tf
    }()

    private lazy var textStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, textField])
        sv.axis = .vertical
        sv.alignment = .leading
        sv.spacing = 0
        return sv
    }()

    private let clearButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "cross"), for: .normal)
        btn.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
        return btn
    }()

    private lazy var clearButtonContainer: UIView = {
        let view = UIView()
        view.addSubview(clearButton)
        view.isHidden = true
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [textStackView, clearButtonContainer])
        sv.axis = .horizontal
        sv.distribution = .fillProportionally
        sv.spacing = 16
        return sv
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

    public var leftView: UIView? {
        willSet {
            leftView?.removeFromSuperview()
        }
        didSet {
            if let leftView {
                mainStackView.insertArrangedSubview(leftView, at: 0)
            }
        }
    }
    public var rightView: UIView? {
        willSet {
            rightView?.removeFromSuperview()
        }
        didSet {
            if let rightView {
                mainStackView.addArrangedSubview(rightView)
            }
        }
    }

    private lazy var roundedContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = appearance.grey230.cgColor
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

    private var isEmpty: Bool {
        return textField.text?.isEmpty ?? true
    }

    var shouldUpdate: ((String) -> Bool)?
    var didUpdateText: ((String) -> Void)?
    var didBeginEditing: (() -> Void)?
    var didEndEditing: ((String) -> Void)?
    var shouldReturn: (() -> Bool)?

    override var isFirstResponder: Bool {
        return self.textField.isFirstResponder
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.isHidden = false
        clearButtonContainer.isHidden = isEmpty
        let translationX = titleLabel.frame.width * (1 - appearance.titleScaleFactor) / 2
        let translation = CGAffineTransform(translationX: -translationX, y: 0)
        let scaling = CGAffineTransform(scaleX: appearance.titleScaleFactor,
                                        y: appearance.titleScaleFactor)
        UIView.animate(withDuration: appearance.animationDuration) {
            self.titleLabel.transform = translation.concatenating(scaling)
            self.layoutSubviews()
        }
        return self.textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        UIView.animate(withDuration: appearance.animationDuration) {
            self.textField.isHidden = self.isEmpty
            self.clearButtonContainer.isHidden = true
            if self.isEmpty {
                self.titleLabel.transform = .identity
            }
            self.layoutSubviews()
        }
        return self.textField.resignFirstResponder()
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
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        roundedContainerView.addGestureRecognizer(tapRecognizer)
    }

    private func addSubviews() {
        clearButtonContainer.addSubview(clearButton)
        roundedContainerView.addSubview(mainStackView)
        addSubview(roundedContainerView)
        addSubview(footerLabel)
    }

    private func makeConstraints() {
        clearButton.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.center.equalToSuperview()
        }
        clearButtonContainer.snp.makeConstraints { make in
            make.width.equalTo(clearButton.snp.width)
        }
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(appearance.verticalInset)
            make.leading.trailing.equalToSuperview().inset(appearance.sideInset)
        }
        roundedContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.width.equalToSuperview()
            make.height.equalTo(appearance.baseHeight)
        }
        footerLabel.snp.makeConstraints { make in
            make.top.equalTo(roundedContainerView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(appearance.sideInset)
            bottomLabelHiddenConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview()
        }
    }

    private func updateBordersColor() {
        if isError {
            roundedContainerView.layer.borderColor = appearance.redColor.cgColor
        } else if isFirstResponder {
            roundedContainerView.layer.borderColor = appearance.cyanColor.cgColor
        } else {
            roundedContainerView.layer.borderColor = appearance.grey230.cgColor
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
        textField.text = nil
        clearButtonContainer.isHidden = true
    }

    private func setupBottomLabel(error: String?, hint: String?) {
        var text = String()
        if let err = error, !err.isEmpty {
            text = err
            footerLabel.textColor = appearance.redColor
            footerLabel.font = errorFont
        } else if let hint = hint {
            text = hint
            footerLabel.textColor = appearance.grey100
            footerLabel.font = hintFont
        }

        footerLabel.text = text
        updateBordersColor()

        UIView.animate(withDuration: appearance.animationDuration) {
            self.footerLabel.alpha = text.isEmpty ? 0.0 : 1.0
            text.isEmpty ? self.bottomLabelHiddenConstraint.activate() : self.bottomLabelHiddenConstraint.deactivate()
            self.enclosingSuperview?.layoutIfNeeded()
        }
    }
}

extension InputTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        didBeginEditing?()
        updateBordersColor()
        clearButtonContainer.isHidden = isEmpty
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditing?(textField.text ?? "")
        updateBordersColor()
        clearButtonContainer.isHidden = true
        textField.isHidden = isEmpty
    }

    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        if let textRange = Range(range, in: currentText) {
            let nextText = currentText.replacingCharacters(
                in: textRange,
                with: string
            )
            let shouldUpdate = self.shouldUpdate?(nextText) ?? true
            return shouldUpdate
        }
        return true
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return shouldReturn?() ?? true
    }

    @objc
    func textFieldDidChanged(textfield: UITextField) {
        didUpdateText?(textField.text ?? "")
        clearButtonContainer.isHidden = isEmpty
    }
}

extension InputTextField {
    struct Appearance {
        let cyanColor: UIColor = .cyan//Asset.Palette.aqua.color
        let grey230: UIColor = .gray//Asset.Palette.grey230.color
        let redColor: UIColor = .red//Asset.Palette.red.color
        let grey100: UIColor = .gray//Asset.Palette.grey100.color
        let animationDuration: CGFloat = 0.3
        let titleScaleFactor: CGFloat = 0.8
        let sideInset: CGFloat = 16
        let verticalInset: CGFloat = 6
        let baseHeight: CGFloat = 56
    }
}
