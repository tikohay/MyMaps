//
//  ViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 03.11.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    private let mapView = GMSMapView()
    private var buttonsStackView: UIStackView?
    
    private let myPositionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .init(rgb: 0x0057e7)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let addMarkerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mappin"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .init(rgb: 0x0057e7)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let updateLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .init(rgb: 0x0057e7)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let requestLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .init(rgb: 0x0057e7)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let mapTypeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .init(rgb: 0x0057e7)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private var isAddedMarker = false
    private var isUpdatedLocation = false
    
    private let mapCoordinate = CLLocationCoordinate2D(latitude: 55.753215,
                                                       longitude: 37.622504)
    private var marker: GMSMarker?
    private var manualMarker: GMSMarker?
    private var geocoder = CLGeocoder()
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        configureMap()
        addTargetToButton()
        configureLocation()
    }
}

//MARK: - Setup views
extension MapViewController {
    private func setupViews() {
        setupMapView()
        setupButtons()
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupButtons() {
        buttonsStackView = UIStackView(arrangedSubviews: [myPositionButton,
                                                          addMarkerButton,
                                                          updateLocationButton,
                                                          requestLocationButton,
                                                          mapTypeButton])
        
        guard let buttonsStackView = buttonsStackView else { return }
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 1
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            addMarkerButton.heightAnchor.constraint(equalToConstant: 35),
            
            buttonsStackView.widthAnchor.constraint(equalToConstant: 40),
            buttonsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10)
        ])
    }
}

//MARK: - Add targets and recognizers
extension MapViewController {
    private func addTargetToButton() {
        myPositionButton.addTarget(self,
                                   action: #selector(myPositionButtonTapped),
                                   for: .touchUpInside)
        addMarkerButton.addTarget(self,
                                  action: #selector(addMarkerButtonTapped),
                                  for: .touchUpInside)
        updateLocationButton.addTarget(self,
                                       action: #selector(updateLocationButtonTapped),
                                       for: .touchUpInside)
        requestLocationButton.addTarget(self,
                                        action: #selector(requestLocationButtonTapped),
                                        for: .touchUpInside)
        mapTypeButton.addTarget(self,
                                action: #selector(mapTypeButtonTapped),
                                for: .touchUpInside)
    }
    
    @objc private func myPositionButtonTapped() {
        mapView.animate(toLocation: mapCoordinate)
    }
    
    @objc private func addMarkerButtonTapped() {
        isAddedMarker.toggle()
        if isAddedMarker {
            addMarkerButton.setImage(UIImage(systemName: "mappin.slash"), for: .normal)
            addMarker()
        } else {
            addMarkerButton.setImage(UIImage(systemName: "mappin"), for: .normal)
            removeMarker()
        }
    }
    
    @objc private func updateLocationButtonTapped() {
        isUpdatedLocation.toggle()
        if isUpdatedLocation {
            route?.map = nil
            route = GMSPolyline()
            routePath = GMSMutablePath()
            route?.map = mapView
            
            locationManager.startUpdatingLocation()
            updateLocationButton.setImage(UIImage(systemName: "figure.stand"), for: .normal)
        } else {
            locationManager.stopUpdatingLocation()
            updateLocationButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        }
    }
    
    @objc private func requestLocationButtonTapped() {
//        let bounds = GMSCoordinateBounds(path: routePath!)
//        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50))
        locationManager.requestLocation()
    }
    
    @objc private func mapTypeButtonTapped() {
        let frame = buttonsStackView?.convert(mapTypeButton.frame, to: self.view)
        let toVC = MapTypeViewController()
        toVC.containerViewFrame = frame
        toVC.onTypeButton = { type in
            self.mapView.mapType = type
        }
        toVC.modalPresentationStyle = .overCurrentContext
        toVC.modalTransitionStyle = .crossDissolve
        self.present(toVC, animated: true, completion: nil)
    }
}

//MARK: - Configure map and location
extension MapViewController {
    private func configureMap() {
        configureMapCoordinate()
        mapView.delegate = self
    }
    
    private func configureLocation() {
        configureLocationManager()
    }
    
    private func configureMapCoordinate() {
        let camera = GMSCameraPosition(target: mapCoordinate, zoom: 17)
        mapView.camera = camera
    }
    
    private func configureMapStyle() {
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: MapStyleJson.style)
        } catch {
            print(error)
        }
    }
    
    private func addMarker() {
        marker = GMSMarker(position: mapCoordinate)
        marker?.map = mapView
        marker?.title = "Moscow"
        marker?.snippet = "Hello"
    }
    
    private func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            marker.icon = GMSMarker.markerImage(with: .green)
            self.manualMarker = marker
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        mapView.animate(toLocation: location.coordinate)
//        let marker = GMSMarker(position: location.coordinate)
//        marker.map = mapView
//        marker.icon = GMSMarker.markerImage(with: .green)
        routePath?.add(location.coordinate)
        route?.path = routePath
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 70)
        mapView.animate(to: position)
        geocoder.reverseGeocodeLocation(location, completionHandler: { places, error in
            print(places?.first ?? "couldn't find place")
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
