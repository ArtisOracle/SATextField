//
//  ViewController.swift
//  SATextField
//
//  Created by Stefan Arambasich on 9/3/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet fileprivate weak var tf: SATextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction fileprivate func didHitButton(_ sender: UIButton) {
        view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let r = view.viewWithTag(textField.tag + 1) {
            r.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}
