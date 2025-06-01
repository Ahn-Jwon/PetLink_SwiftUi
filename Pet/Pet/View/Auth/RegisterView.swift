//
//  RegisterView.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI

///```
///회원가입
///```
struct RegisterView: View {
    
    // 환경
    @State private var startRegistrationFlow = false        // View에서 등록흐름으로 이동할 수 있게해주는 것 (스와이프로 갈지말지)
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            VStack {
//                BrandingImage()
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()
                
                VStack(spacing: 32) {
                    PetInputField(imageName: "envelope", placeolderText: "email", text: $viewModel.email)
                    PetInputField(imageName: "person", placeolderText: "name", text: $viewModel.name)
                    PetInputField(imageName: "lock", placeolderText: "password", text: $viewModel.password, isSecureField: true)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                
                Button{ // ViewModel과 기능이 확보되면 완성시키기.
                    Task { // 백그라운드에서 실행하는 백엔드 기능을 넣기.
                        try await viewModel.register() {
                            startRegistrationFlow.toggle()
                        }
                    }
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(.black))
                        .clipShape(Capsule())
                }
                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 0)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                
                Spacer()
                
                Button {
                    presentationMode.wrappedValue.dismiss() // LoginView로 돌아가도록 지정.
                } label: {
                    Text("Already registered?")
                        .font(.footnote)
                    Text("Log in")
                        .font(.footnote)
                        .bold()
                }
                .padding(.bottom, 48)
            }
            
            if $viewModel.isLoading.wrappedValue {
                LoadingOverlayVIew()
            }
        }
        .alert(viewModel.errorEvent.content, isPresented: $viewModel.errorEvent.display) {
            Button("OK", role: .cancel) { } //에러 처리
        }
        .navigationDestination(isPresented: $startRegistrationFlow) {
            RegisterImageVIew()
                .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
