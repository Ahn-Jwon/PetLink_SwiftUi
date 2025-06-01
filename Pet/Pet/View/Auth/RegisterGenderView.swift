//
//  RegisterGenderView.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI

///```
///User 성별 등록
///```
struct RegisterGenderView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss                                  // 오버레이를 닫을 수 있다.
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .padding()
            Text("Step 3 of 6")
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding()
            Text("Hey, \(viewModel.currentUser?.name ?? "")")
                .font(.title)
                .padding()
            Text("What are you looking for?")
                .font(.headline)
                .padding()
            Divider()
            
            //MARK: 나의 성별 선택기
            HStack {
                Text("I am a")
                    .padding(.trailing)
                    .frame(width: 150, alignment: .trailing)
                Picker("Choose", selection: $viewModel.gender) {
                    ForEach(PetGender.allCases) { gender in
                        switch gender {
                        case PetGender.man: Text("Man")
                        case PetGender.woman:Text("Woman")
                        case PetGender.unspecifide:Text("Unspecifide")
                        }
                    }
                }
                .frame(width: 150, alignment: .leading)
            }
            Divider()
            NavigationLink {
                RegisterBioView()
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

#Preview {
    RegisterGenderView()
        .environmentObject(AuthViewModel())
}
