//
//  SpinnerViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 07.04.2022.
//

import UIKit

class SpinnerViewController {
    
var spinner: UIActivityIndicatorView?
var style: UIActivityIndicatorView.Style = .medium
var baseColor = UIColor.darkGray
    
 func start(view: UIImageView) {
            let frame = view.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.style = style
            spinner?.color = baseColor
            view.addSubview(spinner!)
            spinner!.startAnimating()
            spinner?.isHidden = false

    }
    
    
func stop() {
        spinner?.isHidden = true
        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        spinner = nil
    }
}
    
