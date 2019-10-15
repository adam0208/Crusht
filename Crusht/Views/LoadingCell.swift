//
//  LoadingCell.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 11/10/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return spinner
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 40).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
