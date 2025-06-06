import Foundation

///```
///성별 지정 enum
///```
enum PetGender: String, CaseIterable, Identifiable, Codable {
    case man = "man"
    case woman = "woman"
    case unspecifide = "unspecified"
    
    var id: Self { self }
        
    
    static func fromString(str: String) -> PetGender {
        switch str.lowercased() {
        // 불특정 다수에게 스위치를 줘서 선택할 수 있게끔
        case "man": return .man
        case "woman": return .woman
        default: return .unspecifide
        }
    }
}
