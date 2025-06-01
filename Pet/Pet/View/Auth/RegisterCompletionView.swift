//
//  RegisterCompletionView.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI

///```
///완료 화면
///```
struct RegisterCompletionView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss                                  // 오버레이를 닫을 수 있다.
    
    var body: some View {
        ZStack {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()
                Text("Steo 6 of 6")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding()
                Text("Hey, \(viewModel.currentUser?.name ?? "")")
                    .font(.title)
                    .padding()
                Text("That's all for now")
                    .font(.headline)
                    .padding()
                Text("You can always update this in your profile page.")
                    .font(.headline)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button {
                    Task {
                        try await viewModel.completRegistrationFlow()
                    }
                } label: {
                    Text("Finish")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 360, height: 44)
                        .background(.black)
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                }
                Button {
                    viewModel.skipRegisterationFlow()
                    dismiss()
                } label: {
                    Text("Skip for now")
                }
                .foregroundStyle(.gray)
                
                Spacer()
            }
            
            if $viewModel.isLoading.wrappedValue {
                LoadingOverlayVIew()
            }
        }
    }
}


#Preview {
    RegisterCompletionView()
        .environmentObject(AuthViewModel())
}

