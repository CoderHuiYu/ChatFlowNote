//
//  ViewController.swift
//  ChatFlow
//
//  Created by Alejandro Reyes on 12/1/18.
//  Copyright © 2018 Patrick Pijnappel. All rights reserved.
//

import Foundation

class ViewController : UIViewController {
    @IBAction func didPressButton(_ sender: UIButton) {
        present(ZLSampleChatFlowVC(), animated: true, completion: nil)
    }
}
