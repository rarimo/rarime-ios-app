import SwiftUI

private enum HomeRoute: Hashable {
    case scanPassport
}

struct HomeView: View {
    let onBalanceTap: () -> Void

    @State private var isAirdropSheetPresented = false
    @State private var isPassportSheetPresented = false
    @State private var path: [HomeRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            homeContent
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .scanPassport:
                        ScanPassportView(onClose: { path.removeLast() })
                            .navigationBarBackButtonHidden()
                    }
                }
        }
    }

    var homeContent: some View {
        VStack(alignment: .leading, spacing: 32) {
            header
            VStack(spacing: 24) {
                airdropCard
                otherPassportsCard
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 32)
        .background(.backgroundPrimary)
    }

    var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: onBalanceTap) {
                    HStack(spacing: 4) {
                        Text("Balance: RMO").body3()
                        Image(Icons.caretRight).iconSmall()
                    }
                }
                .foregroundStyle(.textSecondary)
                Spacer()
                Button(action: {}) {
                    Image(Icons.qrCode).iconMedium()
                }
            }

            HStack {
                Text("0").h4().foregroundStyle(.textPrimary)
                Spacer()
                Text("Beta launch")
                    .body3()
                    .foregroundStyle(.warningDark)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(.warningLighter)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 8)
    }

    var airdropCard: some View {
        CardContainer {
            VStack(spacing: 20) {
                Text("🇺🇦")
                    .h4()
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                VStack(spacing: 8) {
                    Text("Programable Airdrop")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("Beta launch is focused on distributing tokens to Ukrainian identity holders")
                        .body2()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                AppButton(text: "Let’s Start", rightIcon: Icons.arrowRight) {
                    isAirdropSheetPresented = true
                }
                .controlSize(.large)
                .dynamicSheet(isPresented: $isAirdropSheetPresented, fullScreen: true) {
                    AirdropIntroView(onStart: {
                        isAirdropSheetPresented = false
                        path.append(.scanPassport)
                    })
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    var otherPassportsCard: some View {
        CardContainer {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Other passport holders")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text("Join a waitlist")
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                ZStack {
                    Image(Icons.caretRight)
                        .iconSmall()
                }
                .padding(4)
                .background(.primaryMain)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .foregroundStyle(.baseBlack)
            }
        }
        .onTapGesture { isPassportSheetPresented = true }
        .dynamicSheet(isPresented: $isPassportSheetPresented, fullScreen: true) {
            PassportIntroView(onStart: {
                isPassportSheetPresented = false
                path.append(.scanPassport)
            })
        }
    }
}

#Preview {
    HomeView(onBalanceTap: {})
}
