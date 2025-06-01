//
//  PlaceDetail.swift
//  Pet
//
//  Created by 안재원 on 3/9/25.
//

import Foundation

struct PlaceDetailsResponse: Codable {
    let result: PlaceDetailsResult?
}

struct PlaceDetailsResult: Codable {
    let formatted_phone_number: String?  // ✅ 전화번호 저장
}
