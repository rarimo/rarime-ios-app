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
    let onNext: () -> Void
    let onClose: () -> Void

    private var passport: Passport {
        passportViewModel.passport!
    }

    private var isAllOptionalItemsSelected: Bool {
        passportViewModel.optionalDataItems.allSatisfy { $0.isSelected }
    }

    private var gender: LocalizedStringResource {
        return passport.gender == "M" ? "Male" : "Female"
    }

    var body: some View {
        ScanPassportLayoutView(
            step: 3,
            title: "Select Data",
            text: "Selected data can be used as anonymised proofs",
            onClose: onClose
        ) {
            ScrollView {
                if passportViewModel.passport != nil {
                    VStack(spacing: 12) {
                        generalDataSection
                        mustDataSection
                        additionalDataSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            VStack(spacing: 12) {
                Text(
                    "🎁 You will claim \(Text(String("\(passportViewModel.selectedReward) /")).fontWeight(.semibold)) \(passportViewModel.totalReward) RMO")
                    .body3()
                    .foregroundStyle(.textSecondary)

                AppButton(text: "Continue", action: onNext)
                    .controlSize(.large)
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
            .padding(.horizontal, 20)
            .background(.backgroundPure)
        }
    }

    private var generalDataSection: some View {
        CardContainer {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(passport.fullName)
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Text("\(gender), Age: \(passport.ageString)")
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
        CardContainer {
            VStack(spacing: 20) {
                HStack {
                    Text("Must data")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    RewardChipView(reward: 50, isActive: true)
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
        CardContainer {
            VStack(spacing: 20) {
                HStack {
                    Text("Additional Data")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                }
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        AppToggle(isOn: Binding<Bool>(
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
                        RewardChipView(reward: 35, isActive: isAllOptionalItemsSelected)
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
            AppToggle(isOn: Binding<Bool>(
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
            RewardChipView(reward: item.reward, isActive: item.isSelected)
        }
    }
}

private struct PreviewView: View {
    @StateObject private var viewModel = PassportViewModel()

    var body: some View {
        SelectPassportDataView(
            onNext: {},
            onClose: {}
        )
        .onAppear {
            viewModel.setPassport(
                Passport(
                    firstName: "Joshua",
                    lastName: "Smith",
                    gender: "M",
                    passportImage: nil,
                    documentType: "P",
                    issuingAuthority: "USA",
                    documentNumber: "00AA00000",
                    documentExpiryDate: "900314",
                    dateOfBirth: "600314",
                    nationality: "USA"
                )
            )
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    PreviewView()
}
