//
//  ContentView.swift
//  Pet
//
//  Created by 안재원 on 1/27/25.
//
import SwiftUI

struct SplashView: View { // 런치스크링 대신 사용.
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Image("PetLink-logo")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.orange)
                Text("Welcome to PetLink")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    // 스플래시 화면 표시 여부
    @State private var showSplash = true

    var body: some View {
        Group {
            // showSplash가 true라면 스플래시 화면을 보여주고,
            // 아니라면 기존 로직대로 분기
            if showSplash {
                SplashView()
                    .onAppear {
                        // 1~2초 뒤에 스플래시 종료
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showSplash = false
                        }
                    }
            } else {
                if viewModel.currentUser == nil || viewModel.signupFlowActive {
                    // 로그인 정보가 없으면 로그인 화면
                    LoginView()
                } else {
                    // 로그인 정보가 있으면 메인 화면
                    if let user = viewModel.currentUser {
                        MainTabView(user: user)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}

#Preview {
    ContentView()
}
