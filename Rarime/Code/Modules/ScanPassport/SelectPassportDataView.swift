//
//  SelectPassportDataView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import Combine
import SwiftUI

// TODO: move logic to ViewModel
private struct Passport {
    let fullName: String
    let sex: String
    let age: String
    let documentClassModel: String
    let issuingStateCode: String
    let documentNumber: String
    let expirationDate: String
    let dateOfIssue: String
    let nationality: String
}

private let samplePassport = Passport(
    fullName: "Joshua Smith",
    sex: "Male",
    age: "24",
    documentClassModel: "P",
    issuingStateCode: "USA",
    documentNumber: "00AA00000",
    expirationDate: "03/14/2060",
    dateOfIssue: "03/14/2024",
    nationality: "USA"
)

private struct PassportDataItem {
    let label: LocalizedStringResource
    let value: String
    let reward: Int
    var isSelected: Bool = false
}

struct SelectPassportDataView: View {
    let onNext: () -> Void
    let onClose: () -> Void

    @State private var dataItems: [PassportDataItem] = [
        PassportDataItem(
            label: "Expiry date",
            value: samplePassport.expirationDate,
            reward: 10
        ),
        PassportDataItem(
            label: "Date of issue",
            value: samplePassport.dateOfIssue,
            reward: 5
        ),
        PassportDataItem(
            label: "Nationality",
            value: samplePassport.nationality,
            reward: 20
        )
    ]

    private var isAllDataSelected: Bool {
        dataItems.allSatisfy { $0.isSelected }
    }

    private let mustDataReward = 50
    private var totalReward: Int {
        mustDataReward + dataItems.reduce(0) { $0 + $1.reward }
    }

    private var selectedReward: Int {
        mustDataReward + dataItems
            .filter { $0.isSelected }
            .reduce(0) { $0 + $1.reward }
    }

    var body: some View {
        ScanPassportLayoutView(
            step: 3,
            title: "Select Data",
            text: "Selected data can be used as anonymised proofs",
            onClose: onClose
        ) {
            ScrollView {
                VStack(spacing: 12) {
                    generalDataSection
                    mustDataSection
                    additionalDataSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            VStack(spacing: 12) {
                Text(
                    "🎁 You will claim \(Text(String("\(selectedReward) /")).fontWeight(.semibold)) \(totalReward) RMO")
                    .body3()
                    .foregroundStyle(.textSecondary)
                Button(action: onNext) {
                    Text("Continue")
                        .buttonLarge()
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
            .padding(.horizontal, 20)
            .background(.backgroundPure)
        }
        .background(.backgroundPrimary)
    }

    private var generalDataSection: some View {
        CardContainerView {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(samplePassport.fullName)
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text("\(samplePassport.sex), Age: \(samplePassport.age)")
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                ZStack {
                    Image(Icons.user)
                        .square(32)
                        .foregroundStyle(.textPrimary)
                }
                .padding(12)
                .background(.componentPrimary)
                .clipShape(Circle())
            }
        }
    }

    private var mustDataSection: some View {
        CardContainerView {
            VStack(spacing: 20) {
                HStack {
                    Text("Must data")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    RewardChip(reward: 50, isActive: true)
                }
                VStack(spacing: 16) {
                    makeMustDataRow(label: "Document class mode", value: samplePassport.documentClassModel)
                    makeMustDataRow(label: "Issuing state code", value: samplePassport.issuingStateCode)
                    makeMustDataRow(label: "Document number", value: samplePassport.documentNumber)
                }
            }
        }
    }

    private var additionalDataSection: some View {
        CardContainerView {
            VStack(spacing: 20) {
                HStack {
                    Text("Additional Data")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                }
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ToggleView(isOn: .constant(isAllDataSelected)) { _ in
                            let newValue = !isAllDataSelected
                            for index in dataItems.indices {
                                dataItems[index].isSelected = newValue
                            }
                        }
                        Text("Select All")
                            .subtitle4()
                            .foregroundStyle(.textSecondary)
                        Spacer()
                        RewardChip(reward: 35, isActive: isAllDataSelected)
                    }
                    HorizontalDivider()
                    ForEach(dataItems.indices, id: \.self) { index in
                        DataItemSelector(
                            isOn: $dataItems[index].isSelected,
                            label: dataItems[index].label,
                            value: dataItems[index].value,
                            reward: dataItems[index].reward
                        )
                    }
                }
            }
        }
    }

    private func makeMustDataRow(label: LocalizedStringResource, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label).body3()
            Spacer()
            Text(value).subtitle4()
        }
        .foregroundStyle(.textPrimary)
    }
}

private struct DataItemSelector: View {
    @Binding var isOn: Bool
    let label: LocalizedStringResource
    let value: String
    let reward: Int

    var body: some View {
        HStack(spacing: 16) {
            ToggleView(isOn: $isOn)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .body3()
                    .foregroundStyle(.textSecondary)
                Text(value)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
            RewardChip(reward: reward, isActive: isOn)
        }
    }
}

#Preview {
    SelectPassportDataView(onNext: {}, onClose: {})
}
