import SwiftUI


struct ZkpView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var passportManager: PassportManager
    
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            back
            Spacer()
        }
    }
    
    var back: some View {
        HStack {
            Spacer()
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .foregroundStyle(.black)
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                }
                    
            }
            .frame(width: 55, height: 55)
        }
    }
}

#Preview {
    ZkpView() {}
        .environmentObject(UserManager.shared)
        .environmentObject(PassportManager.shared)
}
