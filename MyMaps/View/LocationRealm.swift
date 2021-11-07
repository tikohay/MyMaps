//
//  LocationCoordinate.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 07.11.2021.
//

import Foundation
import RealmSwift
import GoogleMaps

class LocationRealm: Object, Decodable {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let location = LocationRealm()
        location.latitude = coordinate.longitude
        location.longitude = coordinate.longitude
        
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(location)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
//    
//    func getAllLocations() -> Results<LocationRealm> {
//        var locations: Results<LocationRealm>?
//        do {
//            let realm = try Realm()
//            locations = realm.objects(LocationRealm.self)
//        } catch {
//            print(error)
//        }
//        
//        return locations!
//    }
    
    func getAllLocations(completionHandler: ([CLLocationCoordinate2D]) -> ()) {
        do {
            let realm = try Realm()
            let locations = realm.objects(LocationRealm.self)
            var locs: [CLLocationCoordinate2D] = []
            for location in locations {
                let loc = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                locs.append(loc)
            }
            completionHandler(locs)
        } catch {
            print(error)
        }
    }
}
