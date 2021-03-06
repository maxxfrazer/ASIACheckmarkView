//
//  ViewController.swift
//  ASIACheckmarkView
//
//  Created by Andrzej Michnia on 13.03.2016.
//  Copyright © 2016 Andrzej Michnia Usługi Programistyczne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var checkmark: ASIACheckmarkView!

    
    @IBAction func changeState(_ sender: ASIACheckmarkView) {
        sender.animate(checked:!sender.boolValue)
    }

    
    @IBAction func changeStateWithSpinning(_ sender: ASIACheckmarkView) {
        if !sender.isSpinning {
            sender.animate(checked:!sender.boolValue)
            sender.isSpinning = true
        }
        else {
            sender.isSpinning = false
        }
    }
    

}

