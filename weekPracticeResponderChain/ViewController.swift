//
//  ViewController.swift
//  weekPracticeResponderChain
//
//  Created by 양호준 on 2022/01/01.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var greenView: GreenView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        let greenViewGestureRecognizer = UITapGestureRecognizer.init(target: greenView, action: #selector(greenView.changeViewColor))
        view.addGestureRecognizer(greenViewGestureRecognizer)
    }
}

