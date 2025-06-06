
import SwiftUI

struct PetInputField: View {
    let imageName: String
    @State var placeolderText: String
    @Binding var text: String
    var isSecureField: Bool = false          
    
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(systemName: imageName)
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
