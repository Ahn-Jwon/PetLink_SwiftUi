import SwiftUI


struct RegisetInterestsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss                                  // 오버레이를 닫을 수 있다.
    
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()
                Text("Steo 5 of 6")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding()
                Text("Hey, \(viewModel.currentUser?.name ?? "")")
                    .font(.title)
                    .padding()
                Text("Pick a few of your interests")
                    .font(.headline)
                    .padding()
                Divider()
                
               let gredItems: [GridItem] = [
                    .init(.flexible(), spacing: 1),
                    .init(.flexible(), spacing: 1),
                    .init(.flexible(), spacing: 1)
                ]
                
                LazyVGrid(columns: gredItems, spacing: 20) {
                    ForEach(PetInterests.allCases, id:\.self) { item in
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
               

                NavigationLink {
                    RegisterCompletionView()
                        .navigationBarBackButtonHidden()
                } label: {
                    Text("Next")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 360, height: 44)
                        .background(Color(.systemBlue))
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
    RegisetInterestsView()
        .environmentObject(AuthViewModel())
}
