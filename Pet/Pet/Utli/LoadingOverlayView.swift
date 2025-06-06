
import SwiftUI

struct LoadingOverlayVIew: View {
    var body: some View {
        VStack {
            HStack{
                Spacer()
            }
            Spacer()
            ProgressView() //로딩하는 View
            Spacer()
        }
        .background(Color.black.opacity(0.25))
    }
}

#Preview {
    LoadingOverlayVIew()
}
