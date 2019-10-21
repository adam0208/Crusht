//
//  TermsViewController.swift
//  Crusht
//
//  Created by William Kelly on 5/16/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://www.crusht.co/terms-and-conditions")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
}
