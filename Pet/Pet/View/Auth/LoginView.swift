
import SwiftUI


struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("PetLink-logo")
                        .resizable()
                        .frame(width: 300, height: 300)
                        .foregroundColor(.orange)
                    VStack(spacing: 32) {
                        PetInputField(imageName: "envelope", placeolderText: "email", text: $viewModel.email)
                        PetInputField(imageName: "lock", placeolderText: "password", text: $viewModel.password, isSecureField: true)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    
                    Button{ // ViewModel과 기능이 확보되면 완성시키기.
                        Task { // 백그라운드에서 실행하는 백엔드 기능을 넣기.
                            try await viewModel.login()
                        }
                    } label: {
                        Text("Login")
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

                    NavigationLink {
                        RegisterView()
                            .navigationBarHidden(true)
                    } label: {
                        HStack {
                            Text("Don't have an accoint?")
                                .font(.footnote)
                            Text("Sign up")
                                .font(.footnote)
                                .foregroundStyle(.blue)
                                .bold()
                        }
                    }
                    .padding(.bottom, 28)
                    .foregroundStyle(.black)
                }
                if $viewModel.isLoading.wrappedValue {
                    LoadingOverlayVIew()
                }
            }
            .alert(viewModel.errorEvent.content, isPresented: $viewModel.errorEvent.display) {
                Button("OK", role: .cancel) { } //에러 처리
        }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
