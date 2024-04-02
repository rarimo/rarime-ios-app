//
//  PassportProofView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct ProcessingDataItem: Identifiable {
    var id = UUID()
    var title: LocalizedStringResource
    var status: ProcessingStatus = .processing
}

struct PassportProofView: View {
    let onFinish: () -> Void

    @State private var dataItems: [ProcessingDataItem] = [
        ProcessingDataItem(title: "Document class mode"),
        ProcessingDataItem(title: "Issuing state code"),
        ProcessingDataItem(title: "Document number"),
        ProcessingDataItem(title: "Expiry date"),
        ProcessingDataItem(title: "Nationality"),
    ]

    private var generalStatus: ProcessingStatus {
        if dataItems.allSatisfy({ $0.status == .success }) {
            return .success
        }

        return dataItems.contains { $0.status == .failure }
            ? .failure
            : .processing
    }

    private func processItems() {
        for index in dataItems.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) + 1) {
                dataItems[index].status = .success
                FeedbackGenerator.shared.impact(.light)
            }
        }
    }

    private func onGeneralStatusChange() {
        if generalStatus == .success {
            FeedbackGenerator.shared.notify(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                onFinish()
            }
        } else if generalStatus == .failure {
            FeedbackGenerator.shared.notify(.error)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 32) {
                GeneralStatusView(status: generalStatus)
                HorizontalDivider()
                VStack(spacing: 16) {
                    ForEach(dataItems) { item in
                        HStack(spacing: 4) {
                            Text(item.title)
                                .body3()
                                .foregroundStyle(.textPrimary)
                            Spacer()
                            ProcessingChipView(status: item.status)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
            footerView
        }
        .padding(.top, 80)
        .onAppear { processItems() }
        .onChange(of: generalStatus) { _ in onGeneralStatusChange() }
    }

    private var footerView: some View {
        VStack(spacing: 16) {
            HorizontalDivider()
            Button(action: onFinish) {
                Text("Back to Rewards")
                    .buttonLarge()
                    .frame(maxWidth: .infinity)
            }
            .disabled(generalStatus == .processing)
            .controlSize(.large)
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .opacity(generalStatus == .processing ? 0 : 1)
    }
}

private struct GeneralStatusView: View {
    let status: ProcessingStatus

    private var title: LocalizedStringResource {
        switch status {
        case .processing:
            return "Please Wait..."
        case .success:
            return "All Done!"
        case .failure:
            return "Error"
        }
    }

    private var text: LocalizedStringResource {
        switch status {
        case .processing:
            return "Creating anonymized identity proof"
        case .success:
            return "You will be redirected in a few seconds"
        case .failure:
            return "Please try again later"
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                ZStack {
                    if status == .processing {
                        CirclesLoaderView()
                    } else {
                        Image(status.icon ?? Icons.dotsThreeOutline)
                            .square(24)
                            .foregroundStyle(status.foregroundColor)
                    }
                }
                .animation(.easeInOut, value: status)
            }
            .frame(width: 80, height: 80)
            .background(status.backgroundColor)
            .clipShape(Circle())
            VStack {
                Text(title)
                    .h6()
                    .foregroundStyle(.textPrimary)
                Text(text)
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 150)
        }
    }
}

#Preview {
    PassportProofView(onFinish: {})
}
