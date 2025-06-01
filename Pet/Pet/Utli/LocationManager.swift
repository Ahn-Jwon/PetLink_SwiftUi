//
//  LocationManager.swift
//  Pet
//
//  Created by 안재원 on 2/8/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var currentAddress: String?
    // 지역 정보를 영어로 요청하기 위해 locale을 en_US로 설정
    let locale = Locale(identifier: "en_US")
    
    private var isAddressRequested = false  // 주소 요청 여부 체크

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // 위치 정보 저장
        self.currentLocation = location.coordinate
        
        // 이미 주소를 요청했다면 더 이상 요청하지 않음
        if isAddressRequested {
            return
        }
        
        // 한 번만 요청하기
        isAddressRequested = true
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, error in
            if let error = error {
                print("주소 변환 오류: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("주소를 찾을 수 없습니다.")
                return
            }
            
            // 지역명(도시 이름) 영어로 변환
            self.currentAddress = placemark.locality ?? "Unknown location"
        }
    }

    // 위치 업데이트 실패 시 호출됩니다.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패?: \(error.localizedDescription)")
    }
}

