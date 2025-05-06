import SwiftUI

struct LikenessProcessing<ProcessingTask: LikenessProcessingTask>: View {
    @EnvironmentObject private var likenessManager: LikenessManager

    let onComplete: () -> Void
    let onError: (Error) -> Void
    let onClose: () -> Void

    @State private var completedTasks: [ProcessingTask] = []
    @State private var currentTask: ProcessingTask = .allCases.first!
    @State private var progress: Double = 0

    @State private var isExecutionCompleted = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                // TODO: use actual animation
                LoopVideoPlayer(url: Videos.likenessProcessing)
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(maxWidth: 320, maxHeight: 320)
                Text("Please wait")
                    .h1()
                    .foregroundStyle(.textPrimary)
                Text("Creating likeness record")
                    .body3()
                    .foregroundStyle(.textSecondary)
                Spacer()
                VStack(spacing: 8) {
                    ForEach(Array(ProcessingTask.allCases), id: \.rawValue) { task in
                        LikenessProcessingEntry(
                            task: task,
                            completedTasks: $completedTasks,
                            currentTask: $currentTask
                        )
                    }
                }
                .padding(.horizontal, 20)
                .onChange(of: completedTasks.count) { val in
                    Task {
                        FeedbackGenerator.shared.impact(.light)

                        if val == ProcessingTask.allCases.count {
                            while !isExecutionCompleted {
                                try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
                            }

                            onComplete()
                        }
                    }
                }
            }

            AppIconButton(variant: .secondary, icon: Icons.closeFill, action: onClose)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.top, .trailing], 20)
        }
        .padding(.bottom, 20)
    }

    func runProcess() {
        Task {
            do {
                try await likenessManager.runRegistration()

                isExecutionCompleted = true
            } catch {
                onError(error)
            }
        }
    }
}

struct LikenessProcessingEntry<ActionTask: LikenessProcessingTask>: View {
    let task: ActionTask

    @Binding var completedTasks: [ActionTask]
    @Binding var currentTask: ActionTask

    @State private var progress: Double = 0

    var isCompleted: Bool {
        completedTasks.contains(where: { $0.rawValue == task.rawValue })
    }

    var isProgressing: Bool {
        task.rawValue == currentTask.rawValue && !isCompleted
    }

    var textColor: Color {
        if isCompleted {
            return .successDarker
        } else if isProgressing {
            return .textPrimary
        } else {
            return .textSecondary
        }
    }

    var body: some View {
        HStack {
            Text(task.description)
                .subtitle5()
                .foregroundStyle(textColor)
            Spacer()
            Group {
                if isCompleted {
                    Image(.checkLine)
                        .foregroundStyle(.successDarker)
                } else if isProgressing {
                    Text("\(Int(progress * 100))%")
                        .subtitle5()
                        .foregroundStyle(.textPrimary)
                }
            }
        }
        .padding(20)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(isCompleted ? .clear : .bgComponentPrimary, lineWidth: 1)

            if isProgressing {
                GeometryReader { geo in
                    Rectangle()
                        .fill(.bgComponentPrimary)
                        .frame(width: geo.size.width * CGFloat(progress))
                }
            }
        }
        .background(isCompleted ? .successLighter : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear(perform: startTask)
        .onChange(of: currentTask.rawValue) { _ in
            startTask()
        }
    }

    func startTask() {
        if !isProgressing {
            return
        }

        Task { @MainActor in
            while progress <= 0.99 {
                progress += 0.01

                try await Task.sleep(nanoseconds: UInt64(task.progressTime) * NSEC_PER_SEC / 100)
            }

            completedTasks.append(task)

            if currentTask.rawValue == Array(ActionTask.allCases).last?.rawValue {
                return
            }

            currentTask = Array(ActionTask.allCases)[currentTask.rawValue + 1]
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            LikenessProcessing<LikenessProcessingRegisterTask>(onComplete: {}, onError: { _ in }, onClose: {})
                .environmentObject(LikenessManager.shared)
        }
}
