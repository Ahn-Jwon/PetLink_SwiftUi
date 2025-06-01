//
//  ChatRoom.swift
//  Pet
//
//  Created by 안재원 on 2/12/25.
//

import Foundation
import Firebase
import FirebaseFirestore

//struct ChatRoom: Identifiable, Codable {
//    let id: String
//    let users: [String]  // 참여한 유저 ID 리스트
//    let lastMessage: String?
//    let timestamp: Date?
//}

struct ChatRoom: Identifiable, Codable {
    let id: String
    let users: [String]            // [내 uid, 상대 uid]
    let usernames: [String]?       // [내 이름, 상대 이름] (2명 기준)
    let profileImageUrl: [String]?// [내 프로필 URL, 상대 프로필 URL] (추가)
    let lastMessage: String?
    let timestamp: Date
}
