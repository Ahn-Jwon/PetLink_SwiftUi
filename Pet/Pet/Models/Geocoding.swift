//
//  Geocoding.swift
//  Pet
//
//  Created by 안재원 on 3/9/25.
//

import Foundation

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]
    let status: String
}

struct GeocodingResult: Codable {
    let geometry: GeoGeometry // ✅ 기존 Geometry → GeoGeometry로 변경
}

struct GeoGeometry: Codable { // ✅ 변경된 이름 & Codable 추가
    let location: GeoLocation
}

struct GeoLocation: Codable { // ✅ Location 이름 변경하여 중복 문제 해결
    let lat: Double
    let lng: Double
}


