//
//  SpinnerViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 07.04.2022.
//

import UIKit

class SpinnerViewController: UIActivityIndicatorView {
    
    var spinner = UIActivityIndicatorView(style: .medium)

 func start(view: UIImageView) {
     spinner.frame = view.bounds
     spinner.color = UIColor.darkGray
     view.addSubview(spinner)
     spinner.startAnimating()
     spinner.isHidden = false
    }
    
    
func stop() {
    spinner.isHidden = true
    }
}
    
