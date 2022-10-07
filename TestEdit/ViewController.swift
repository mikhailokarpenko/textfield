//
//  ViewController.swift
//  TestEdit
//
//  Created by Valerii Sohlaiev on 30.08.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var inputTextField: InputTextField!
    
    let leftView: UIView = {
        let lv = UIView()
        lv.snp.makeConstraints { make in
            make.height.width.equalTo(44)
        }
        lv.backgroundColor = .green
        return lv
    }()
    
    let rightView: UIView = {
        let rv = UIView()
        rv.snp.makeConstraints { make in
            make.height.width.equalTo(44)
        }
        rv.backgroundColor = .magenta
        return rv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextField.enclosingSuperview = view
        inputTextField.titleLabel.text = "Title"
        inputTextField.textField.placeholder = "Placeholder"
        
        
        // MARK: - Tips
        
        // allow to input 4 or less characters
        inputTextField.shouldUpdate = { $0.count < 155 }


        // Control when next button tapped
        inputTextField.shouldReturn = {
            print("Next button tapped")
            return false
        }

        inputTextField.didBeginEditing = {
            print("begin editing")
        }

        inputTextField.didEndEditing = { text in
            print("end editing text: \(text)")
        }

        inputTextField.didUpdateText = { text in
            print("updated text: \(text)")
        }
    }
    
    
    @IBAction func ShowErrorNew(_ sender: Any) {
        inputTextField.errorText = "errorText errorText errorText errorText errorText errorText"
    }
    @IBAction func ClearErrorNew(_ sender: Any) {
        inputTextField.errorText = nil
    }
    @IBAction func EndEditNew(_ sender: Any) {
        inputTextField.resignFirstResponder()
    }
    @IBAction func showHint(_ sender: Any) {
        inputTextField.hintText = "Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint"
    }
    @IBAction func hideHint(_ sender: Any) {
        inputTextField.hintText = nil
    }
    @IBAction func showLeft(_ sender: Any) {
        inputTextField.leftView = leftView
    }
    @IBAction func hideLeft(_ sender: Any) {
        inputTextField.leftView = nil
    }
    @IBAction func showRight(_ sender: Any) {
        inputTextField.rightView = rightView
    }
    @IBAction func hideRight(_ sender: Any) {
        inputTextField.rightView = nil
    }
    @IBAction func showPrefix(_ sender: Any) {
        
    }
    @IBAction func hidePrefix(_ sender: Any) {
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

