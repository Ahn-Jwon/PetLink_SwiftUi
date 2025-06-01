//
//  Board.swift
//  Pet
//
//  Created by 안재원 on 2/6/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Board: Identifiable, Codable {
    var id: String?
    var username: String
    var userId: String
    var title: String
    var content: String
    var imageUrl: String? //  이미지 URL 저장 필드 추가
    var latitude: Double? //  위치 정보 (위도)
    var longitude: Double? //  위치 정보 (경도)
    var address: String?  //  작성자의 지역 정보 추가
    var timestamp: Timestamp?
}


