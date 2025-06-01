//
//  PetApp.swift
//  Pet
//
//  Created by 안재원 on 1/27/25.
//

import SwiftUI
import Firebase

@main
struct PetApp: App {
    
    @StateObject var viewModel = AuthViewModel()    // 이렇게 하면 AuthViewModel을 어플리케이션 전체에서 사용할 수 있다.
    // 초기에는 더미 User 데이터를 사용합니다.
       @StateObject var editProfileViewModel = EditProfileViewModel(
        user: User(id: "0", email: "guest@example.com", name: "Guest")
       )
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)  // 전달하기
                .environmentObject(editProfileViewModel)
        }
    }
}
