//
//  CustomTextfield.swift
//  TestEdit
//
//  Created by Mike Karpenko on 19.09.2022.
//

import UIKit

protocol CustomTextDelegate: AnyObject {
    func textDidChange(from: String?, to: String?)
}

final class CustomTextField: UITextField {
    weak var customDelegate: CustomTextDelegate?

    override var text: String? {
        didSet {
            customDelegate?.textDidChange(from: oldValue, to: text)
        }
    }

    var isAnyActionAvailable: Bool = true
    var textInsets: UIEdgeInsets = .zero

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard self.isAnyActionAvailable else { return false }
        return super.canPerformAction(action, withSender: sender)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - bounds.height, y: 0, width: bounds.height, height: bounds.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
}
