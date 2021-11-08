//
//  MapTypeEnum.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 04.11.2021.
//

import Foundation

enum MapType: String {
    case normal, satellite, hybrid, terrain
    
    static let types: [MapType] = [normal, satellite, hybrid, terrain]
}
