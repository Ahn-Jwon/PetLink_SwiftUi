//
//  User.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import Foundation


///```
///사용자 UserModel
///```
struct User: Identifiable, Codable, Hashable {
    
    let id: String
    let email: String
    let name: String
    var age: Int?
    var bio: String?
    var profileImageUrl: String?
    var gender: String = PetGender.unspecifide.rawValue
    var preference: String = PetGender.unspecifide.rawValue
    var interests: Array<String> = []
//    var swipesLeft: Array<String> = []
//    var swipesRight: Array<String> = []
//    var matches: Array<String> = []
    
    

    static let mockUsers: [User] = [ // 사용자 배열 초기화
        .init(id: NSUUID().uuidString, email: "bob@gmail.com", name: "Bob", age: 29, bio: "Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio Bob's bio ", profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/tindercloneios-6f4a2.appspot.com/o/images%2FAC747183-8E3B-4093-817F-9048DA72528D?alt=media&token=40ff7f1c-bf75-41ad-bd0b-a460fc6dea1c", gender: "man", preference: "woman", interests: [ "skiing", "bicycles", "painting", "astrology"]),
        
        .init(id: NSUUID().uuidString, email: "u2@gmail.com", name: "u2", age: 29, bio: "u2bio"),
        
        .init(id: NSUUID().uuidString, email: "u3@gmail.com", name: "u3", age: 29, bio: "u3bio", profileImageUrl: "ai_man3"),
        
        .init(id: NSUUID().uuidString, email: "u4@gmail.com", name: "u4", age: 29, bio: "u4bio", profileImageUrl: "ai_man4"),
        
        .init(id: NSUUID().uuidString, email: "u5@gmail.com", name: "u5", age: 29, bio: "u5bio", profileImageUrl: "ai_man5"),
        
        .init(id: NSUUID().uuidString, email: "u6@gmail.com", name: "u6", age: 29, bio: "u6bio", profileImageUrl: "ai_woman1"),
        
        .init(id: NSUUID().uuidString, email: "u7@gmail.com", name: "u7", age: 29, bio: "u7bio", profileImageUrl: "ai_woman2"),
        
        .init(id: NSUUID().uuidString, email: "u8@gmail.com", name: "u8", age: 29, bio: "u8bio", profileImageUrl: "ai_woman3"),

        .init(id: NSUUID().uuidString, email: "u9@gmail.com", name: "u9", age: 29, bio: "u9bio", profileImageUrl: "ai_woman4"),
        
        .init(id: NSUUID().uuidString, email: "u10@gmail.com", name: "Carol", age: 29, bio: "u10bio", profileImageUrl: "ai_woman5"),
        
    ]
}
