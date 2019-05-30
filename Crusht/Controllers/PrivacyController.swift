//
//  PrivacyController.swift
//  Crusht
//
//  Created by William Kelly on 5/16/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import WebKit

class PrivacyController: UIViewController, WKUIDelegate {

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
    }
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://app.termly.io/document/privacy-policy/7b4441c3-63d0-4987-a99d-856e5053ea0c")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
}


