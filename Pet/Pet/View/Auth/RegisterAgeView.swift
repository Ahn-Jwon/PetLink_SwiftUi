
import SwiftUI


// MARK: User Age 등록
struct RegisterAgeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss                                  // 오버레이를 닫을 수 있다.
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .padding()
            Text("Steo 2 of 6")
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding()
            Text("Hey, \(viewModel.currentUser?.name ?? "")")
                .font(.title)
                .padding()
            Text("Let's get some basic info on you")
                .font(.headline)
                .padding()
            Divider()
            
            //MARK: age 선택
            Text("What's your age")
            Picker("Choose", selection: $viewModel.age) {
                ForEach(0...30, id:\.self) { age in
                    Text(String(age))
                }
            }
            
            NavigationLink {
                RegisterGenderView()
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

#Preview {
    RegisterAgeView()
        .environmentObject(AuthViewModel())
}
