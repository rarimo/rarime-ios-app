import SwiftUI

struct RewardsView: View {
    var body: some View {
        MainViewLayout {
            ZStack(alignment: .top) {
                skeleton
                Color.backgroundPure
                    .opacity(0.3)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(Icons.calendarBlank)
                        .square(24)
                        .padding(24)
                        .background(.secondaryMain, in: Circle())
                        .foregroundStyle(.primaryMain)
                    VStack(spacing: 8) {
                        Text("Available in July")
                            .h5()
                            .foregroundStyle(.textPrimary)
                        Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem")
                            .body3()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.textSecondary)
                    }
                }
                .padding(.top, 220)
                .padding(.horizontal, 24)
            }
        }
    }

    var skeleton: some View {
        VStack(alignment: .leading, spacing: 20) {
            AppSkeleton().frame(width: 120, height: 20)
            ForEach(0 ..< 3) { _ in
                CardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        AppSkeleton().frame(width: 60, height: 12)
                        HStack {
                            AppSkeleton().frame(width: 140, height: 30)
                            Spacer()
                            AppSkeleton().frame(width: 60, height: 20)
                        }
                        AppSkeleton().frame(width: 200, height: 12)
                        HorizontalDivider()
                        AppSkeleton().frame(maxWidth: .infinity, maxHeight: 40)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 20)
        .padding(.horizontal, 12)
        .background(.backgroundPrimary)
        .blur(radius: 6)
    }
}

#Preview {
    RewardsView()
        .environmentObject(MainView.ViewModel())
}
