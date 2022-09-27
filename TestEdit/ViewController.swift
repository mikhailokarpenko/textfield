//
//  ViewController.swift
//  TestEdit
//
//  Created by Valerii Sohlaiev on 30.08.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var inputTextView: InputTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.titleLabel.text = "Тайтл"
        inputTextView.textView.text = "some text"
        
        
        // MARK: - Tips
        
        // allow to input 4 or less characters
        inputTextView.shouldUpdate = { $0.count < 55 }


        // Control when next button tapped
        inputTextView.shouldReturn = {
            print("Next button tapped")
            return false
        }

        inputTextView.didBeginEditing = {
            print("begin editing")
        }

        inputTextView.didEndEditing = { text in
            print("end editing text: \(text)")
        }

        inputTextView.didUpdateText = { text in
            print("updated text: \(text)")
        }
    }
    
    
    @IBAction func ShowErrorNew(_ sender: Any) {
        inputTextView.errorText = "errorText errorText errorText errorText errorText errorText"
    }
    @IBAction func ClearErrorNew(_ sender: Any) {
        inputTextView.errorText = nil
    }
    @IBAction func EndEditNew(_ sender: Any) {
        inputTextView.endEditing(true)
    }
    @IBAction func showHint(_ sender: Any) {
        inputTextView.hintText = "Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint Hint"
    }
    @IBAction func hideHint(_ sender: Any) {
        inputTextView.hintText = nil
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

