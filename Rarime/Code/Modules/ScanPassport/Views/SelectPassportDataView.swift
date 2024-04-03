//
//  SelectPassportDataView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import Combine
import NFCPassportReader
import SwiftUI

struct SelectPassportDataView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel

    var passport: NFCPassportModel
    let onNext: () -> Void
    let onClose: () -> Void

    private var isAllOptionalItemsSelected: Bool {
        passportViewModel.optionalDataItems.allSatisfy { $0.isSelected }
    }

    private var gender: LocalizedStringResource {
        return passport.gender == "M" ? "Male" : "Female"
    }

    private var age: Int {
        return Calendar.current.dateComponents(
            [.year],
            from: DateUtil.parsePassportDate(passport.dateOfBirth),
            to: Date()
        ).year!
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
                    "🎁 You will claim \(Text(String("\(passportViewModel.selectedReward) /")).fontWeight(.semibold)) \(passportViewModel.totalReward) RMO")
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
    }

    private var generalDataSection: some View {
        CardContainerView {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String("\(passport.firstName) \(passport.lastName)"))
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text("\(gender), Age: \(age)")
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                if passport.passportImage != nil {
                    Image(uiImage: passport.passportImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 56)
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
                    ForEach(passportViewModel.requiredDataItems) { item in
                        HStack(spacing: 8) {
                            Text(item.label).body3()
                            Spacer()
                            Text(item.formattedValue).subtitle4()
                        }
                        .foregroundStyle(.textPrimary)
                    }
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
                        ToggleView(isOn: Binding<Bool>(
                            get: { isAllOptionalItemsSelected },
                            set: { newValue in
                                for item in passportViewModel.optionalDataItems {
                                    passportViewModel.changeItemSelection(id: item.id, isSelected: newValue)
                                }
                            }
                        ))
                        Text("Select All")
                            .subtitle4()
                            .foregroundStyle(.textSecondary)
                        Spacer()
                        RewardChip(reward: 35, isActive: isAllOptionalItemsSelected)
                    }
                    HorizontalDivider()
                    ForEach(passportViewModel.optionalDataItems) { item in
                        DataItemSelector(
                            item: item,
                            onSelect: { newValue in
                                passportViewModel.changeItemSelection(id: item.id, isSelected: newValue)
                            }
                        )
                    }
                }
            }
        }
    }
}

private struct DataItemSelector: View {
    let item: PassportProofDataItem
    let onSelect: (_ newValue: Bool) -> Void

    var body: some View {
        HStack(spacing: 16) {
            ToggleView(isOn: Binding<Bool>(
                get: { item.isSelected },
                set: { newValue in onSelect(newValue) }
            ))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .body3()
                    .foregroundStyle(.textSecondary)
                Text(item.formattedValue)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
            RewardChip(reward: item.reward, isActive: item.isSelected)
        }
    }
}

private struct PreviewView: View {
    @State private var passportModel: NFCPassportModel
    @StateObject private var viewModel = PassportViewModel()

    init() {
        passportModel = NFCPassportModel()
        passportModel.firstName = "Joshua"
        passportModel.lastName = "Smith"
        passportModel.gender = "M"
        passportModel.dateOfBirth = "900314"
        passportModel.documentType = "P"
        passportModel.issuingAuthority = "USA"
        passportModel.documentNumber = "00AA00000"
        passportModel.documentExpiryDate = "600314"
        passportModel.nationality = "USA"
    }

    var body: some View {
        SelectPassportDataView(
            passport: passportModel,
            onNext: {},
            onClose: {}
        )
        .onAppear {
            viewModel.fillProofDataItems(nfcPassport: passportModel)
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    PreviewView()
}
