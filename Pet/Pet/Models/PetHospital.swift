//
//  PetHospital.swift
//  Pet
//
//  Created by 안재원 on 3/9/25.
//

import Foundation

struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
    let status: String
}

struct GooglePlace: Codable {
    let name: String?
    let vicinity: String?  // ✅ 주변 주소 (있을 수도 있고 없을 수도 있음)
    let formatted_address: String? // ✅ 전체 주소 (있을 수도 있고 없을 수도 있음)
    let geometry: Geometry?
    let business_status: String? // ✅ 영업 상태 (예: "OPERATIONAL")
    let place_id: String?
    let rating: Double? // ✅ 평점 추가
    let user_ratings_total: Int? // ✅ 리뷰 수 추가
}

struct Geometry: Codable {
    let location: Location?
}

struct Location: Codable {
    let lat: Double?
    let lng: Double?
}


struct PetHospital: Identifiable, Codable {
    let id = UUID()
    let name: String
    let address: String
    let rating: Double
    let totalReviews: Int
    let placeID: String
    var phoneNumber: String?  // ✅ 추가됨
}



