//
//  PetHospitalService.swift
//  Pet
//
//  Created by 안재원 on 3/9/25.
//

import Foundation
import Alamofire
import CoreLocation

import Alamofire

class PetHospitalService {
    private let apiKey = "AIzaSyDgkxrepywZneifmPOh7Nzq-q0-HcN8WJk"
    
    // 키워드로 병원 검색 (예: "動物病院")
    func fetchHospitalsByKeyword(keyword: String, completion: @escaping (Result<[PetHospital], Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        
        let parameters: [String: Any] = [
            "query": keyword,
            "region": "JP", // 일본 지역 검색
            "key": apiKey
        ]

        print("키워드 검색 요청: \(parameters)")

        AF.request(urlString, parameters: parameters)
            .validate()
            .responseDecodable(of: GooglePlacesResponse.self) { response in
                switch response.result {
                case .success(let data):
                    let hospitals = data.results.compactMap { place -> PetHospital? in
                        guard let name = place.name else { return nil }
                        let address = place.formatted_address ?? place.vicinity ?? "주소 정보 없음"
                        return PetHospital(
                            name: name,
                            address: address,
                            rating: place.rating ?? 0.0,
                            totalReviews: place.user_ratings_total ?? 0,
                            placeID: place.place_id ?? ""
                        )
                    }
                    print("병원 검색 성공: \(hospitals.count)개 발견")
                    completion(.success(hospitals))
                case .failure(let error):
                    print("API 요청 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }

    
    func getCoordinates(for city: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json"

        let parameters: [String: Any] = [
            "address": city,
            "region": "JP",
            "key": apiKey
        ]
        print("지역명 변환 요청: \(parameters)")
        AF.request(urlString, parameters: parameters)
            .validate()
            .responseDecodable(of: GeocodingResponse.self) { response in
                switch response.result {
                case .success(let data):
                    if let location = data.results.first?.geometry.location {
                        let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                        print("지역명 변환 성공: \(city) → \(coordinate.latitude), \(coordinate.longitude)")
                        completion(.success(coordinate))
                    } else {
                        print("변환 실패: 해당 지역 없음")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "해당 지역을 찾을 수 없음"])))
                    }
                case .failure(let error):
                    print("지역명 변환 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    // 위치 정보 없이 키워드로 병원 검색
    func fetchHospitalsByCoordinates(latitude: Double, longitude: Double, completion: @escaping (Result<[PetHospital], Error>) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        let parameters: [String: Any] = [
            "location": "\(latitude),\(longitude)",
            "radius": 5000,
            "type": "veterinary_care",
            "key": apiKey
        ]

        print("병원 검색 요청 (위도, 경도 기반): \(parameters)")

        AF.request(urlString, parameters: parameters)
            .validate()
            .responseDecodable(of: GooglePlacesResponse.self) { response in
                switch response.result {
                case .success(let data):
                    var hospitals = data.results.compactMap { place -> PetHospital? in
                        guard let name = place.name else { return nil }
                        let address = place.formatted_address ?? place.vicinity ?? "주소 정보 없음"
                        return PetHospital(
                            name: name,
                            address: address,
                            rating: place.rating ?? 0.0,
                            totalReviews: place.user_ratings_total ?? 0,
                            placeID: place.place_id ?? "",
                            phoneNumber: nil // 초기값은 nil
                        )
                    }

                    // 📞 전화번호 추가 요청 (비동기)
                    let dispatchGroup = DispatchGroup()
                    
                    for i in 0..<hospitals.count {
                        dispatchGroup.enter()
                        self.fetchHospitalPhoneNumber(placeID: hospitals[i].placeID) { phone in
                            hospitals[i].phoneNumber = phone
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        completion(.success(hospitals))
                    }

                case .failure(let error):
                    completion(.failure(error))
                }
            }
    
    }
    
    //  3. 지역명을 기반으로 병원 검색 (위의 두 함수를 결합)
        func searchHospitalsByCity(city: String, completion: @escaping (Result<[PetHospital], Error>) -> Void) {
            getCoordinates(for: city) { result in
                switch result {
                case .success(let coordinate):
                    self.fetchHospitalsByCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    func fetchHospitalPhoneNumber(placeID: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json"
        let parameters: [String: Any] = [
            "place_id": placeID,
            "fields": "formatted_phone_number",
            "key": apiKey
        ]

        print("🚀 전화번호 요청: \(parameters)")

        AF.request(urlString, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("전화번호 API 응답: \(value)")  // API 응답 전체 출력 (디버깅)

                    if let json = value as? [String: Any],
                       let result = json["result"] as? [String: Any],
                       let phoneNumber = result["formatted_phone_number"] as? String {
                        print("전화번호 가져옴: \(phoneNumber)")
                        completion(phoneNumber)
                    } else {
                        print("전화번호 없음")
                        completion(nil)
                    }
                case .failure(let error):
                    print("전화번호 요청 실패: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }
    
    }
