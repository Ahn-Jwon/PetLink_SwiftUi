//
//  MainTabView.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI

struct MainTabView: View {
    let user: User
    @State private var selectedIndex = 0    // 현재 탭 인덱스
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            MainView(user: user)
                .onAppear {
                    selectedIndex = 0
                }
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0) // 선택한 인덱스의 값은 0이라고 tag 붙여줌.
                .buttonStyle(PlainButtonStyle())
            BoardView()
                .onAppear {
                    selectedIndex = 1
                }
                .tabItem {
                    Image(systemName: "magnifyingglass.circle")
                }
                .tag(1) // 선택한 인덱스의 값은 0이라고 tag 붙여줌.
                .buttonStyle(PlainButtonStyle())
            ChatListView()
                .onAppear {
                    selectedIndex = 2
                }
                .tabItem {
                    Image(systemName: "bubble.right")
                }
                .tag(2) // 선택한 인덱스의 값은 0이라고 tag 붙여줌.
                .buttonStyle(PlainButtonStyle())
            ProfileView(user: user, editMode: true)
                .onAppear {
                    selectedIndex = 3
                }
                .tabItem {
                    Image(systemName: "person")
                }
                .tag(3) // 선택한 인덱스의 값은 0이라고 tag 붙여줌.
                .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    MainTabView(user: User.mockUsers[0])
}
