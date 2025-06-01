//
//  RegisterBioView.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI

///```
///등록 소개
///```
struct RegisterBioView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss                                  // 오버레이를 닫을 수 있다.
    
    var body: some View {
        ZStack {
            Image("PetLink-logo")
                .resizable()
                .frame(width: 300, height: 300)
                .foregroundColor(.orange)
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()
                Text("Steo 4 of 6")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding()
                Text("Hey, \(viewModel.currentUser?.name ?? "")")
                    .font(.title)
                    .padding()
                Text("Write a few words aboits yourself")
                    .font(.headline)
                    .padding()
                Divider()
                
                // MARK: 자기소개 글
                TextEditor(text: $viewModel.bio)
                    .frame(width: 300, height: 150, alignment: .topLeading)
                    .overlay(
                        RoundedRectangle(cornerRadius:  6)
                            .stroke(.gray, lineWidth: 1)
                    )
                    .padding()
                
                NavigationLink {
                    RegisetInterestsView()
                        .navigationBarBackButtonHidden()
                } label: {
                    Text("Next")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 360, height: 44)
                        .background(Color(.black))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                }
                .padding()
                
                Button {
                    viewModel.skipRegisterationFlow()
                    dismiss()
                } label: {
                    Text("Skip for now")
                }
                .foregroundStyle(.gray)
                
                Spacer()
            }
        }
    }
}

#Preview {
    RegisterBioView()
        .environmentObject(AuthViewModel())
}
