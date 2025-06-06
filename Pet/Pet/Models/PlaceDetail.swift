
import Foundation

struct PlaceDetailsResponse: Codable {
    let result: PlaceDetailsResult?
}

struct PlaceDetailsResult: Codable {
    let formatted_phone_number: String?  // 전화번호 저장
}
