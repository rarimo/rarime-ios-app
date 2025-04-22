import SwiftUI

struct LikenessProcessing<Task: LikenessProcessingTask>: View {
    @State private var completedTasks: [Task] = []

    @State private var currentTask: Task = .allCases.first!

    @State private var progress: Double = 0

    let onCompletion: () -> Void
    let onBack: () -> Void

    var body: some View {
        withCloseButton {
            VStack {
                Text("Please wait")
                    .h1()
                    .align()
                    .padding(.horizontal)
                    .padding(.vertical, 75)
                VStack {
                    ForEach(Array(Task.allCases), id: \.rawValue) { task in
                        LikenessProcessingEntry(
                            task: task,
                            completedTasks: $completedTasks,
                            currentTask: $currentTask,
                            onCompletion: onCompletion
                        )
                    }
                }
                Spacer()
            }
        }
    }

    func withCloseButton(_ body: () -> some View) -> some View {
        ZStack(alignment: .topTrailing) {
            body()
            VStack {
                Button(action: onBack) {
                    ZStack {
                        Circle()
                            .foregroundColor(.bgComponentPrimary)
                        Image(systemName: "xmark")
                            .foregroundColor(.baseBlack)
                    }
                }
                .frame(width: 40, height: 40)
            }
            .padding()
        }
    }
}

struct LikenessProcessingEntry<ActionTask: LikenessProcessingTask>: View {
    let task: ActionTask

    @Binding var completedTasks: [ActionTask]
    @Binding var currentTask: ActionTask

    let onCompletion: () -> Void

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.bgComponentPrimary)
            if isCompleted {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.bgComponentPrimary)
            } else if isProgressing {
                RoundedRectangle(cornerRadius: 24)
                    .frame(width: 366 * CGFloat(progress), height: 60)
                    .foregroundStyle(.primaryLighter)
                    .align()
            }
            HStack {
                Text(task.description)
                    .subtitle5()
                    .foregroundStyle(textColor)
                Spacer()
                Group {
                    if isCompleted {
                        Image(systemName: "checkmark")
                    } else if isProgressing {
                        Text("\(Int(progress * 100))%")
                            .subtitle5()
                    }
                }
                .foregroundStyle(.textPrimary)
            }
            .padding(.horizontal, 25)
        }
        .frame(width: 366, height: 60)
        .onAppear(perform: startTask)
        .onChange(of: currentTask.rawValue) { _ in
            startTask()
        }
    }

    var isCompleted: Bool {
        completedTasks.contains(where: { $0.rawValue == task.rawValue })
    }

    var isProgressing: Bool {
        task.rawValue == currentTask.rawValue
    }

    var textColor: Color {
        if isCompleted {
            return .textPrimary
        } else if isProgressing {
            return .textPrimary
        } else {
            return .textSecondary
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
                onCompletion()

                return
            }

            currentTask = Array(ActionTask.allCases)[currentTask.rawValue + 1]
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            LikenessProcessing<LikenessProcessingRegisterTask>(onCompletion: {}, onBack: {})

//            LikenessProcessing<LikenessProcessingTaskRecoveryTask>(onCompletion: {}, onBack: {})
        }
}
