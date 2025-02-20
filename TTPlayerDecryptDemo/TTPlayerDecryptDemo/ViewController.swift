//
//  ViewController.swift
//  TTPlayerDecryptDemo
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func playVideo(_ sender: Any) {
        let url = "your encrypted video url"
        let ctr = TTPlayerViewController(url: url)
        self.navigationController?.pushViewController(ctr, animated: true)
    }
    
}

