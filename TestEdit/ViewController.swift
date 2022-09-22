//
//  ViewController.swift
//  TestEdit
//
//  Created by Valerii Sohlaiev on 30.08.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var inputSumFieldView: InputSumField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputSumFieldView.enclosingSuperview = view
        inputSumFieldView.textField.placeholder = "Сума"
        inputSumFieldView.currencyButton.setTitle("UAH", for: .normal)
        inputSumFieldView.commissionLabel.text = "Комісія: 0.00 ₴"
        inputSumFieldView.exchangeRateLabel.text = "1 $ → 37.00 ₴"
        
        
        // MARK: - Tips
        
        // allow to input 4 or less characters
        inputSumFieldView.shouldUpdate = { $0.count < 5 }
        
        
        // Control when next button tapped
        inputSumFieldView.shouldReturn = {
            print("Next button tapped")
            return false
        }
        
        inputSumFieldView.didBeginEditing = {
            print("begin editing")
        }
        
        inputSumFieldView.didEndEditing = { text in
            print("end editing text: \(text)")
        }
        
        inputSumFieldView.didUpdateText = { text in
            print("updated text: \(text)")
        }
        
        inputSumFieldView.currencyButton.addTarget(self, action: #selector(currencyPressed), for: .touchUpInside)
    }
    
    
    @IBAction func ShowErrorNew(_ sender: Any) {
        inputSumFieldView.errorText = "errorText errorText errorText errorText errorText errorText"
    }
    @IBAction func ClearErrorNew(_ sender: Any) {
        inputSumFieldView.errorText = nil
    }
    @IBAction func EndEditNew(_ sender: Any) {
        inputSumFieldView.endEditing(true)
    }
    @IBAction func showHint(_ sender: Any) {
        inputSumFieldView.hintText = "Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint"
    }
    @IBAction func hideHint(_ sender: Any) {
        inputSumFieldView.hintText = nil
    }
    
    @objc
    private func currencyPressed() {
        print("currency button pressed")
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

