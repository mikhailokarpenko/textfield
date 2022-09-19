//
//  ViewController.swift
//  TestEdit
//
//  Created by Valerii Sohlaiev on 30.08.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var inputSumFieldView: InputSumFieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputSumFieldView.textField.placeholder = "Сумма"
//        textFLDNew.titleText = "titleText"
//        textFLDNew.placeholder = "placeholder"
    }
    
    
    @IBAction func ShowErrorNew(_ sender: Any) {
//        textFLDNew.errorText = "errorText errorText errorText errorText errorText errorText"
    }
    @IBAction func ClearErrorNew(_ sender: Any) {
//        textFLDNew.errorText = ""
    }
    @IBAction func EndEditNew(_ sender: Any) {
//        textFLDNew.endEditing(true)
    }
    @IBAction func enableDisableNew(_ sender: Any) {
//        textFLDNew.isEnabled = !textFLDNew.isEnabled
    }
    @IBAction func showHint(_ sender: Any) {
//        textFLDNew.hint = "Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint"
    }
    var rightView: UIView = {
        let view = UIButton()
        view.backgroundColor = .red
        view.setTitle("right", for: .normal)
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 60)
        return view
    }()
    @IBAction func showHideRight(_ sender: Any) {
//        if let sv = rightView.subviews.first as? UIStackView,
//           sv.contains(rightView) {
//            textFLDNew.setRightView(nil)
//        } else {
//            textFLDNew.setRightView(rightView)
//        }
    }
    
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

public extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    func nilIfEmpty() -> String? {
        return self.isEmpty ? nil : self
    }
}

