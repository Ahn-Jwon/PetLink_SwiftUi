//
//  PetInputField.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI

struct PetInputField: View {
    let imageName: String                     // 이미지 이름 변수
    @State var placeolderText: String         // 문자열이 될 상태변수 자리표시자 (텍스트필드의 제목과 같음)
    @Binding var text: String                //  문자열 유형의 바인딩 var 텍스트 이므로 이에대해  ID 와 비밀번호를 설정
    var isSecureField: Bool = false          //  보안필드
    
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(systemName: imageName)     // 위의 "let imageName라는 변수의 데이터가 이쪽으로 들어간다.
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color(.darkGray))
                if isSecureField {
                    SecureField(placeolderText, text: $text)
                } else {
                    TextField(placeolderText, text: $text)
                        .textInputAutocapitalization(.never)    // 자동대문자 사용 안함
                }
            }
            .padding(4)
            
            Divider()
                .background(Color(.darkGray))
        }
    }
}
