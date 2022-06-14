//
//  MapViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 14.06.2022.
//

import UIKit
import MapKit
import CoreLocation
protocol MapViewControllerDelegate: AnyObject {
    func saveLocation(with location: String)
}

class MapViewController: UIViewController {
    weak var delegate: MapViewControllerDelegate?
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        map.frame = view.bounds
        setupNavItems()
        LocationManager.shared.getUserLocaation { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                strongSelf.addMapPin(with: location)
            }
        }
    }
    func addMapPin(with location: CLLocation) {
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
        map.addAnnotation(pin)
        LocationManager.shared.resolveLocatioName(with: location) { [weak self] locationName in
            self?.title = locationName
        }
    }
    func setupNavItems() {
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.left"), style: .plain, target: self, action: #selector(backPressed))
        back.tintColor = .black
        navigationItem.leftBarButtonItem = back
        navigationItem.title = Constants.App.titleNewPhoto
        let next = UIBarButtonItem(image: UIImage(systemName: "chevron.compact.right"), style: .plain, target: self, action: #selector(nextPressed))
        next.tintColor = .black
        navigationItem.rightBarButtonItem = next
    }
    @objc func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    @objc func nextPressed() {
        let location = self.title
        delegate?.saveLocation(with: location ?? "")
        navigationController?.popViewController(animated: true)
    }
}
