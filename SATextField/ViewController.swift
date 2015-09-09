//
//  ViewController.swift
//  SATextField
//
//  Created by Stefan Arambasich on 9/3/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var tf: SATextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction private func didHitButton(sender: UIButton) {
        view.endEditing(true)
    }
}

