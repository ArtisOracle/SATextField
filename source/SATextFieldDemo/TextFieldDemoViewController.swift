//
//  TextFieldDemoViewController.swift
//  SATextField
//
//  Created by Stefan Arambasich on 9/3/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit
import SATextField


class TextFieldDemoViewController: UIViewController {

    /// The text field object on the storybord.
    @IBOutlet private weak var myTextField: SATextField?

    @IBAction func didHitButton(_ sender: UIButton) {
        view.endEditing(true)
    }
}


// MARK: -
// MARK: UITextFieldDelegate

extension TextFieldDemoViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let r = view.viewWithTag(textField.tag + 1) {
            r.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }

}
