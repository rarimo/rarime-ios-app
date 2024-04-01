//
//  PassportProofView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import SwiftUI

enum ProcessingStatus {
    case processing, success, failure

    var icon: String? {
        switch self {
        case .processing:
            return nil
        case .success:
            return Icons.check
        case .failure:
            return Icons.close
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .processing:
            return "Processing"
        case .success:
            return "Done"
        case .failure:
            return "Failed"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .processing:
            return .warningLighter
        case .success:
            return .successLighter
        case .failure:
            return .errorLighter
        }
    }

    var foregroundColor: Color {
        switch self {
        case .processing:
            return .warningDark
        case .success:
            return .successDark
        case .failure:
            return .errorMain
        }
    }
}

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

    var generalStatus: ProcessingStatus {
        if dataItems.allSatisfy({ $0.status == .success }) {
            return .success
        }

        return dataItems.contains { $0.status == .failure } ? .failure : .processing
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
                            ProcessingChip(status: item.status)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
            VStack(spacing: 16) {
                HorizontalDivider()
                Button(action: onFinish) {
                    Text("Home Page")
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
        .padding(.top, 80)
        .onAppear {
            for index in dataItems.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) + 1) {
                    dataItems[index].status = .success
                }
            }
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
            return "You will be redirected in 5sec"
        case .failure:
            return "Please try again later"
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Image(status.icon ?? Icons.dotsThreeOutline)
                    .square(24)
                    .foregroundStyle(status.foregroundColor)
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

private struct ProcessingChip: View {
    let status: ProcessingStatus

    var body: some View {
        HStack {
            if let icon = status.icon {
                Image(icon).iconSmall()
            }
            Text(status.text).overline3()
        }
        .frame(height: 24)
        .padding(.horizontal, 8)
        .background(status.backgroundColor)
        .clipShape(Capsule())
        .foregroundStyle(status.foregroundColor)
    }
}

#Preview {
    PassportProofView(onFinish: {})
}
