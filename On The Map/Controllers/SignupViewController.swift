//
//  SignupViewController.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/31/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import WebKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = URLRequest(url: URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!)
        webView.load(request)
    }
}
