//
//  ViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 03.11.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

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
    
    private let showLastPathButton: UIButton = {
        let button = UIButton()
        button.setTitle("show the last path", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .init(rgb: 0x0057e7)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isAddedMarker = false
    private var isUpdatedLocation = false
    
    private let mapCoordinate = CLLocationCoordinate2D(latitude: 55.753215,
                                                       longitude: 37.622504)
    private var marker: GMSMarker?
    private var manualMarker: GMSMarker?
    private var geocoder = CLGeocoder()
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    
    private var locationManager = CLLocationManager()
    
    private var allLocations:[CLLocationCoordinate2D] = []
    
    let locationRealm = LocationRealm()
    

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
private extension MapViewController {
    func setupViews() {
        setupMapView()
        setupButtons()
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupButtons() {
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
        mapView.addSubview(showLastPathButton)
        
        NSLayoutConstraint.activate([
            addMarkerButton.heightAnchor.constraint(equalToConstant: 35),
            
            buttonsStackView.widthAnchor.constraint(equalToConstant: 40),
            buttonsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            
            showLastPathButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            showLastPathButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])
    }
}

//MARK: - Add targets and recognizers
private extension MapViewController {
    func addTargetToButton() {
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
        showLastPathButton.addTarget(self,
                                     action: #selector(showLastPathButtonTapped),
                                     for: .touchUpInside)
    }
    
    @objc func myPositionButtonTapped() {
        mapView.animate(toLocation: mapCoordinate)
    }
    
    @objc func addMarkerButtonTapped() {
        isAddedMarker.toggle()
        if isAddedMarker {
            addMarkerButton.setImage(UIImage(systemName: "mappin.slash"), for: .normal)
            addMarker()
        } else {
            addMarkerButton.setImage(UIImage(systemName: "mappin"), for: .normal)
            removeMarker()
        }
    }
    
    @objc func updateLocationButtonTapped() {
        isUpdatedLocation.toggle()
        if isUpdatedLocation {
            allLocations = []
            
            route?.map = nil
            route = GMSPolyline()
            routePath = GMSMutablePath()
            route?.map = mapView
            
            locationManager.startUpdatingLocation()
            updateLocationButton.setImage(UIImage(systemName: "figure.stand"), for: .normal)
        } else {
            locationManager.stopUpdatingLocation()
            locationRealm.deleteAllLocations()
            locationRealm.addCoordinate(allLocations)
            updateLocationButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        }
    }
    
    @objc func requestLocationButtonTapped() {
        locationManager.requestLocation()
    }
    
    @objc func mapTypeButtonTapped() {
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
    
    @objc func showLastPathButtonTapped() {
        if isUpdatedLocation {
            let toVC = InfoAlert(title: "Need to stop tracking", text: "Stop tracking ?")
            toVC.modalPresentationStyle = .overCurrentContext
            toVC.modalTransitionStyle = .crossDissolve
            toVC.onOkButtonTapped = {
                self.isUpdatedLocation = false
                self.locationManager.stopUpdatingLocation()
                self.locationRealm.deleteAllLocations()
                self.locationRealm.addCoordinate(self.allLocations)
                self.createPathFromLocations()
            }
            self.present(toVC, animated: true, completion: nil)
        } else {
            createPathFromLocations()
        }
    }
}

//MARK: - Configure map and location
private extension MapViewController {
    func configureMap() {
        configureMapCoordinate()
        mapView.delegate = self
    }
    
    func configureLocation() {
        configureLocationManager()
    }
    
    func configureMapCoordinate() {
        let camera = GMSCameraPosition(target: mapCoordinate, zoom: 17)
        mapView.camera = camera
    }
    
    func configureMapStyle() {
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: MapStyleJson.style)
        } catch {
            print(error)
        }
    }
    
    func addMarker() {
        marker = GMSMarker(position: mapCoordinate)
        marker?.map = mapView
        marker?.title = "Moscow"
        marker?.snippet = "Hello"
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
    }
    
    func createPathFromLocations() {
        route?.map = nil
        routePath = GMSMutablePath()
        route = GMSPolyline()
        locationRealm.getAllLocations { locations in
            for location in locations {
                self.routePath?.add(location)
                self.route?.path = routePath
                route?.strokeColor = .blue
                route?.strokeWidth = 10
                route?.map = mapView
            }
            let bounds = GMSCoordinateBounds(path: routePath!)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50))
        }
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
        allLocations.append(location.coordinate)
        routePath?.add(location.coordinate)
        route?.path = routePath
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
        geocoder.reverseGeocodeLocation(location, completionHandler: { places, error in
            print(places?.first ?? "couldn't find place")
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
