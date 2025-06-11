import SwiftUI

struct LikenessProcessingView: View {
    @EnvironmentObject private var likenessManager: LikenessManager

    let onComplete: () -> Void
    let onError: () -> Void

    @State private var currentTask: LikenessProcessingTask = .allCases.first!
    @State private var progress: Double = 0

    @State private var isExecutionCompleted = false

    var body: some View {
        VStack(spacing: 0) {
            DotsLoadingView(size: 4, spacing: 3)
                .frame(width: 24, height: 24)
                .padding(12)
                .background(.baseWhite.opacity(0.2), in: Circle())
                .foregroundStyle(.baseWhite)
                .overlay(Circle().stroke(.baseWhite, lineWidth: 3))
            Text(currentTask.description)
                .h3()
                .foregroundStyle(.baseWhite)
                .padding(.top, 32)
            LinearProgressView(
                progress: progress,
                height: 4,
                backgroundFill: AnyShapeStyle(Color.baseWhite.opacity(0.1)),
                foregroundFill: AnyShapeStyle(Color.baseWhite)
            )
            .padding(.top, 92)
            .frame(width: 290)
            Text("This can take up to a minute")
                .body4()
                .foregroundStyle(.baseWhite.opacity(0.6))
                .padding(.top, 24)
            Spacer()
        }
        .padding(.top, 240)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await registerLikeness() }
        .task { await simulateProcessing() }
    }

    @MainActor
    func registerLikeness() async {
        do {
            try await likenessManager.runRegistration()

            likenessManager.setIsRegistered(true)
            FeedbackGenerator.shared.notify(.success)

            onComplete()
        } catch {
            likenessManager.setFaceImage(nil)
            FeedbackGenerator.shared.notify(.error)

            LoggerUtil.common.error("Likeness registration error: \(error)")
            AlertManager.shared.emitError("Error during likeness registration, please try again")

            onError()
        }
    }

    @MainActor
    func simulateProcessing() async {
        let allTasks = Array(LikenessProcessingTask.allCases)
        let progressTimes = allTasks.map { Double($0.progressTime) }
        let totalTime = progressTimes.reduce(0, +)

        for (i, task) in allTasks.enumerated() {
            currentTask = task
            FeedbackGenerator.shared.impact(.light)

            let previousSum = progressTimes.prefix(i).reduce(0, +)
            let newSum = previousSum + progressTimes[i]

            progress = previousSum / totalTime
            withAnimation(.linear(duration: progressTimes[i])) {
                progress = newSum / totalTime
            }

            try? await Task.sleep(nanoseconds: UInt64(progressTimes[i]) * NSEC_PER_SEC)
        }

        progress = 1
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            LikenessProcessingView(onComplete: {}, onError: {})
                .background(.baseBlack)
                .environmentObject(LikenessManager())
        }
}
