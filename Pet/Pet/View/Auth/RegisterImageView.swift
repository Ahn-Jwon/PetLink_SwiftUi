import SwiftUI
import PhotosUI                                                           // Image Picker을



// MARK: User ProfileImage Setting
struct RegisterImageVIew: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss                                  // 오버레이를 닫을 수 있다.
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .padding()
            Text("Steo 1 of 6")
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding()
            Text("Hey, \(viewModel.currentUser?.name ?? "")")
                .font(.title)
                .padding()
            Text("Upload a photo")
                .font(.headline)
                .padding()
            Divider()
            // MARK: Image 선택기
            PhotosPicker(selection: $viewModel.selectedImage) {
                VStack {
                    if let image = viewModel.profileImage {
                        image
                            .resizable()                               //image는 ViewModel과 Service에 있는 실제 Image이다
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.white)
                            .background(.gray)
                            .clipShape(Circle())
                            .padding()
                    } else {
                        Image(systemName: "person")
                            .resizable()                               //image는 ViewModel과 Service에 있는 실제 Image이다
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.white)
                            .background(.gray)
                            .clipShape(Circle())
                            .padding()
                    }
                }
            }
            .padding(.vertical, 8)
            
            NavigationLink {
                RegisterAgeView()
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
            .simultaneousGesture(TapGesture().onEnded({ _ in        //이거 이상하게 자동생성이 안된다..
                Task {
                    try await viewModel.uploadUserImage()
                }
            }))
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
    RegisterImageVIew()
        .environmentObject(AuthViewModel())
}
