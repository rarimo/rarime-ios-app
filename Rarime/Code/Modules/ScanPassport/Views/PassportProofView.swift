//
//  PassportProofView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

struct PassportProofView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel
    let onFinish: () -> Void

    private func processItems() async {
        for item in passportViewModel.selectedDataItems {
            await passportViewModel.processItem(id: item.id)
            FeedbackGenerator.shared.impact(.light)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 32) {
                GeneralStatusView(status: passportViewModel.generalProcessingStatus)
                HorizontalDivider()
                VStack(spacing: 16) {
                    ForEach(passportViewModel.selectedDataItems) { item in
                        ProcessingItemView(item: item)
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
            footerView
        }
        .padding(.top, 80)
        .task { await processItems() }
        .onChange(of: passportViewModel.generalProcessingStatus) { val in
            FeedbackGenerator.shared.notify(val == .success ?.success : .error)
        }
        .background(.backgroundPrimary)
    }

    private var footerView: some View {
        VStack(spacing: 16) {
            HorizontalDivider()
            Button(action: onFinish) {
                Text("Back to Rewards")
                    .buttonLarge()
                    .frame(maxWidth: .infinity)
            }
            .disabled(passportViewModel.generalProcessingStatus == .processing)
            .controlSize(.large)
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .opacity(passportViewModel.generalProcessingStatus == .processing ? 0 : 1)
    }
}

private struct ProcessingItemView: View {
    let item: PassportProofDataItem

    var body: some View {
        HStack(spacing: 4) {
            Text(item.label)
                .body3()
                .foregroundStyle(.textPrimary)
            Spacer()
            ProcessingChipView(status: item.processingStatus)
        }
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
            return "Your passport proof is ready"
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
        .environmentObject(PassportViewModel(
            dataItems: [
                PassportProofDataItem(label: "First Name", value: "", isSelected: true),
                PassportProofDataItem(label: "Last Name", value: "", isSelected: true),
                PassportProofDataItem(label: "Date of Birth", value: "", isSelected: true),
                PassportProofDataItem(label: "Passport Number", value: "", isSelected: true),
            ]
        ))
}
