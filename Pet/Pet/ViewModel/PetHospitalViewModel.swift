import SwiftUI
import Foundation
import CoreLocation



class PetHospitalViewModel: ObservableObject {
    @Published var hospitals: [PetHospital] = []
    private let hospitalService = PetHospitalService()

    //  앱 실행 시 기본 병원 리스트 불러오기
    func fetchDefaultHospitals() {
        print("🚀 기본 병원 리스트 가져오기 (도쿄)")
        searchHospitalsByCity(city: "도쿄") //  기본 검색어를 "도쿄"로 설정
    }

    // 사용자가 입력한 지역을 기반으로 병원 검색
    func searchHospitalsByCity(city: String) {
        print("🚀 \(city) 지역 병원 검색 실행")
        hospitalService.searchHospitalsByCity(city: city) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let hospitals):
                    print("\(city) 지역 병원 검색 성공: \(hospitals.count)개 발견")
                    self.hospitals = hospitals
                case .failure(let error):
                    print("❌ 병원 검색 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

