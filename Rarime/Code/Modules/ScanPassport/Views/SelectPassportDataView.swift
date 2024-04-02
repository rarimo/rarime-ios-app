//
//  SelectPassportDataView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import Combine
import NFCPassportReader
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

private struct PassportDataItem {
    let label: LocalizedStringResource
    let value: String
    let reward: Int
    var isSelected: Bool = false
}

struct SelectPassportDataView: View {
    var nfcModel: NFCPassportModel
    let onNext: () -> Void
    let onClose: () -> Void

    @State private var dataItems: [PassportDataItem]

    init(nfcModel: NFCPassportModel, onNext: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.nfcModel = nfcModel
        self.onNext = onNext
        self.onClose = onClose
        dataItems = [
            PassportDataItem(
                label: "Expiry date",
                value: nfcModel.documentExpiryDate,
                reward: 10
            ),
            PassportDataItem(
                label: "Date of birth",
                value: nfcModel.dateOfBirth,
                reward: 5
            ),
            PassportDataItem(
                label: "Nationality",
                value: nfcModel.nationality,
                reward: 20
            )
        ]
    }

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
                    Text(String("\(nfcModel.firstName) \(nfcModel.lastName)"))
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text("\(nfcModel.gender), Age: \(nfcModel.dateOfBirth)")
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                if nfcModel.passportImage != nil {
                    Image(uiImage: nfcModel.passportImage!)
                        .square(56)
                        .background(.componentPrimary)
                        .clipShape(Circle())
                } else {
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
                    makeMustDataRow(label: "Document class mode", value: nfcModel.documentType)
                    makeMustDataRow(label: "Issuing state code", value: nfcModel.issuingAuthority)
                    makeMustDataRow(label: "Document number", value: nfcModel.documentNumber)
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

private struct PreviewView: View {
    @State private var nfcModel: NFCPassportModel

    init() {
        nfcModel = NFCPassportModel()
        nfcModel.firstName = "Joshua"
        nfcModel.lastName = "Smith"
        nfcModel.gender = "M"
        nfcModel.dateOfBirth = "03/14/1990"
        nfcModel.documentType = "P"
        nfcModel.issuingAuthority = "USA"
        nfcModel.documentNumber = "00AA00000"
        nfcModel.documentExpiryDate = "03/14/2060"
        nfcModel.nationality = "USA"
    }

    var body: some View {
        SelectPassportDataView(
            nfcModel: nfcModel,
            onNext: {},
            onClose: {}
        )
    }
}

#Preview {
    PreviewView()
}
