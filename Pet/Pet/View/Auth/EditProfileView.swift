
import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @StateObject var viewModel: EditProfileViewModel
    
    
    // 초기의 데이터를 주기 위함.
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                EditHeaderView()
                EditProfileImageView()
                EdiNameAgeView()
                EditBioView()
                EditPrerferenceView()
                EditInterestsView()
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    EditProfileView(user: User.mockUsers[0])
}




// MARK: 상단 Text Button

struct EditHeaderView: View {
    @EnvironmentObject var viewModel: EditProfileViewModel // 환경객체
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            Button {
                Task {
                    try await viewModel.updateUserData()
                }
                dismiss()
            } label: {
                Text("Save")
                    .bold()
            }
        }
        .padding()
        Divider()
    }
}



// MARK: 프로필 이미지
struct EditProfileImageView: View {
    @EnvironmentObject var viewModel: EditProfileViewModel // 환경객체
    
    var body: some View {
        PhotosPicker(selection: $viewModel.selectedImage) {
            HStack {
                Spacer()
                ZStack(alignment:  .bottomTrailing) {
                    if let displaySelectedImage = viewModel.profileImage {
                        displaySelectedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .clipShape(Circle())
                    } else {
                        RoundImageView(imageUrl: viewModel.profileImageUrl, imageSize: .xlarge)
                    }
                    
                    Image(systemName: "pencil")
                        .resizable()
                        .padding(12)
                        .background(.black)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .containerShape(Circle())
                }
                Spacer()
            }
            .padding()
        }
        Divider()
    }
}


// MARK: 이름 수정

struct EdiNameAgeView: View {
    @EnvironmentObject var viewModel: EditProfileViewModel // 환경객체
    
    var body: some View {
        HStack {
            Text(viewModel.name)
                .font(.title)
                .bold()
            Spacer()
        }
        .padding()
        
        HStack {
            Text("Age")
                .font(.title2)
            Picker("Choose", selection: $viewModel.age) {
                ForEach(18...100, id: \.self) { age in
                    Text(String(age))
                }
            }
        }
        .padding()
        Divider()
    }
}


// MARK: 자기 소개 글
struct EditBioView: View {
    @EnvironmentObject var viewModel: EditProfileViewModel // 환경객체
    
    var body: some View {
        Text("About me")
            .font(.title2)
            .padding()
        TextField("Bio", text: $viewModel.bio, axis: .vertical)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.gray, lineWidth: 1)
            )
            .lineLimit(6) // 실제 줄을 리밋트한다기본다 노출상태의 크기를 조절하는 개념?
            .padding()
        Divider()
    }
}



// MARK: 성별 수정

struct EditPrerferenceView: View {
    @EnvironmentObject var viewModel: EditProfileViewModel // 환경객체
    
    var body: some View {
        HStack {
            Text("I am a")
                .padding(.trailing)
                .frame(width: 150, alignment: .leading)
            Picker("Choose", selection: $viewModel.gender) {
                ForEach(PetGender.allCases) { gender in
                    switch gender {
                    case PetGender.man: Text("Man")
                    case PetGender.woman: Text("Woman")
                    case PetGender.unspecifide: Text("Unspecified")
                    }
                }
            }
        }
        .padding()
        HStack {
            Text("Looking for")
                .padding(.trailing)
                .frame(width: 150, alignment: .leading)
            Picker("Choose", selection: $viewModel.preference) {
                ForEach(PetGender.allCases) { gender in
                    switch gender {
                    case PetGender.man: Text("Man")
                    case PetGender.woman: Text("Woman")
                    case PetGender.unspecifide: Text("Any")
                    }
                }
            }
        }
        .padding()
        
        Divider()
    }
}


// MARK: 관심분야 수정
struct EditInterestsView: View {
    @EnvironmentObject var viewModel: EditProfileViewModel // 환경객체
    
    var body: some View {
        let gridItems: [GridItem] = [
            .init(.flexible(), spacing: 1),
            .init(.flexible(), spacing: 1),
            .init(.flexible(), spacing: 1)
        ]
        
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(PetInterests.allCases, id: \.self) { item in
                let selected = viewModel.interests.contains(item.rawValue)
                Text(String(describing: item))
                    .padding(8)
                    .foregroundStyle(selected ? .white : .black)
                    .background(selected ? .blue : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray, lineWidth: 1)
                    )
                    .onTapGesture {
                        if selected {
                            viewModel.interests.remove(item.rawValue)
                        } else {
                            viewModel.interests.insert(item.rawValue)
                        }
                    }
            }
        }
        .padding()
    }
}
