//
//  SpinnerViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 07.04.2022.
//

import UIKit

class SpinnerViewController: UIActivityIndicatorView {

    private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = UIColor.darkGray
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    private  func setConstraints(view: UIImageView) {
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    func start(view: UIImageView) {
        view.addSubview(spinner)
        setConstraints(view: view)
        spinner.startAnimating()
        spinner.isHidden = false
    }

    func stop() {
        spinner.isHidden = true
    }
}
