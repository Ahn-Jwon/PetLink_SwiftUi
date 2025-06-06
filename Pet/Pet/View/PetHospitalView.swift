
import SwiftUI
import CoreLocation


import SwiftUI
import CoreLocation

struct PetHospitalListView: View {
    @StateObject private var viewModel = PetHospitalViewModel()
    @State private var searchQuery: String = ""

    var body: some View {
        VStack {
            HStack {
                TextField("地域名で検索します", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
                Button(action: {
                    if !searchQuery.isEmpty {
                        viewModel.searchHospitalsByCity(city: searchQuery)
                    }
                }) {
                    Text("Ok")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.hospitals) { hospital in
                        VStack(alignment: .leading, spacing: 15) {
                            Text(hospital.name)
                                .font(.headline)
                            Text(hospital.address)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let phone = hospital.phoneNumber {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.black)
                                    Text(phone)
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.black)
                                    Text("-")
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Hospital List")
        .padding()
        .onAppear {
            viewModel.fetchDefaultHospitals() // 앱 실행 시 기본 병원 리스트 가져오기
        }
    }
}




#Preview {
    PetHospitalListView()
}


