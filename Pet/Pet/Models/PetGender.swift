//
//  PetGender.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import Foundation

///```
///성별 지정 enum
///```
enum PetGender: String, CaseIterable, Identifiable, Codable {
    case man = "man"
    case woman = "woman"
    case unspecifide = "unspecified"
    
    var id: Self { self }
        
    // str을 문자열 매개변수로 사용하여 물자열에서 Tinder성별을 반환한다.
    static func fromString(str: String) -> PetGender {
        switch str.lowercased() {
        // 불특정 다수에게 스위치를 줘서 선택할 수 있게끔
        case "man": return .man
        case "woman": return .woman
        default: return .unspecifide
        }
    }
}
