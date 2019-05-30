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
        
        let myURL = URL(string:"https://app.termly.io/document/terms-of-use-for-website/2ce67fc1-504a-49aa-a498-5c1d8f3f8225")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
}
