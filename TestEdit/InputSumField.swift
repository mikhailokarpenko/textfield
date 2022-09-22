//
//  InputSumField.swift
//  TestEdit
//
//  Created by Mike Karpenko on 19.09.2022.
//

import UIKit
import SnapKit

protocol InputFieldFocusDelegate: AnyObject {
    func didTap(_ field: InputSumField)
}

class InputSumField: UIView {
    private let cornerRadius: CGFloat = 12
    private let borderWidth: CGFloat = 1
    private let cyanColor: UIColor = UIColor.cyan
    private let blackColor: UIColor = UIColor.black
    private let grey230: UIColor = .gray
    private let redColor: UIColor = .red
    private let grey100: UIColor = .lightGray
    /// superview responsible for calling layoutIfNeeded upon inputfield's layout changes
    weak var enclosingSuperview: UIView?
    weak var delegate: InputFieldFocusDelegate?
    private var bottomLabelHiddenConstraint: Constraint!
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.tintColor = cyanColor
        return tf
    }()
    
    lazy var currencyButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(blackColor, for: .normal)
        btn.setContentCompressionResistancePriority(.required, for: .horizontal)
        return btn
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = grey230
        return view
    }()
    
    let commissionLabel: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    let exchangeRateLabel: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    public var errorColor: UIColor = .systemRed {
        willSet {
            self.footerLabel.textColor = newValue
        }
    }
    
    public var errorFont: UIFont = .systemFont(ofSize: 18.0, weight: .regular) {
        willSet {
            self.footerLabel.font = newValue
        }
    }
    
    public var hintColor: UIColor = .systemMint {
        willSet {
            self.footerLabel.textColor = newValue
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
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
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
        return self.textField.isFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
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
        clipsToBounds = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let textFieldTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        roundedContainerView.addGestureRecognizer(tapRecognizer)
        textField.addGestureRecognizer(textFieldTapRecognizer)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func addSubviews() {
        roundedContainerView.addSubview(textField)
        roundedContainerView.addSubview(currencyButton)
        roundedContainerView.addSubview(separatorView)
        roundedContainerView.addSubview(commissionLabel)
        roundedContainerView.addSubview(exchangeRateLabel)
        addSubview(roundedContainerView)
        addSubview(footerLabel)
    }

    private func makeConstraints() {
        let sideInset = 16
        
        textField.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(sideInset)
        }
        currencyButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField.snp.centerY)
            make.leading.greaterThanOrEqualTo(textField.snp.trailing).offset(24)
            make.trailing.equalToSuperview().inset(sideInset)
        }
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(sideInset)
            make.leading.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(0.5)
        }
        commissionLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(sideInset)
            make.top.equalTo(separatorView.snp.bottom).offset(4)
        }
        exchangeRateLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(sideInset)
            make.top.equalTo(separatorView.snp.bottom).offset(4)
            make.leading.greaterThanOrEqualTo(commissionLabel.snp.trailing).inset(4)
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
            footerLabel.textColor = errorColor
            footerLabel.font = errorFont
        } else if let hint = hint {
            text = hint
            footerLabel.textColor = hintColor
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
    
    private func updateCurrencyButton(hasImage: Bool) {
        currencyButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        currencyButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        currencyButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        let image = hasImage ? UIImage(named: "Arrow_up") : nil
        currencyButton.setImage(image, for: .normal)
    }
}

extension InputSumField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        self.didBeginEditing?()
        updateBordersColor()
        updateCurrencyButton(hasImage: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.didEndEditing?(textField.text ?? "")
        updateBordersColor()
        updateCurrencyButton(hasImage: false)
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

    @objc func textFieldDidChange(textfield: UITextField) {
        didUpdateText?(textField.text ?? "")
    }

    // programmatic input change detection
    func textDidChange(from: String?, to: String?) {
        didUpdateText?(textField.text ?? "")
    }
}
