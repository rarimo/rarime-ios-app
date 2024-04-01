//
//  SelectPassportDataView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 01.04.2024.
//

import Combine
import SwiftUI

struct PassportDataItem: Identifiable {
    var id: ObjectIdentifier

    let label: LocalizedStringKey
    let value: String
    let reward: Int
    var isSelected: Bool = false
}

struct SelectPassportDataView: View {
    let onNext: () -> Void
    let onClose: () -> Void

//    @State private var dataItems: [PassportDataItem] = [
//        PassportDataItem(
//            id: ObjectIdentifier()
//            label: "Expiry date",
//            value: "03/14/2060",
//            reward: 10
//        ),
//        PassportDataItem(
//            id: ObjectIdentifier(2),
//            label: "Date of issue",
//            value: "03/14/2024",
//            reward: 5
//        ),
//        PassportDataItem(
//            id: ObjectIdentifier(3),
//            label: "Nationality",
//            value: "USA",
//            reward: 20
//        )
//    ]

    @State private var isExpiryDateSelected = false
    @State private var isDateOfIssueSelected = false
    @State private var isNationalitySelected = false

    @State private var isAllSelected = false

    private var isAllDataSelected: Bool {
        isExpiryDateSelected && isDateOfIssueSelected && isNationalitySelected
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
                    CardContainerView {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Joshua Smith")
                                    .subtitle3()
                                    .foregroundStyle(.textPrimary)
                                Text("Male, Age:24")
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
                                makeDataRow(label: "Document class mode", value: "P")
                                makeDataRow(label: "Issuing state code", value: "USA")
                                makeDataRow(label: "Document number", value: "00AA00000")
                            }
                        }
                    }
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
                                    Toggle(isOn: $isAllSelected) {}
                                        .toggleStyle(PrimarySwitchToggleStyle())
//                                        .onReceive(Just(isAllSelected)) { value in
//                                            isExpiryDateSelected = value
//                                            isDateOfIssueSelected = value
//                                            isNationalitySelected = value
//                                        }
                                        .onChange(of: isAllDataSelected) { newValue in
                                            isAllSelected = newValue
                                        }
                                    Text("Select All")
                                        .subtitle4()
                                        .foregroundStyle(.textSecondary)
                                    Spacer()
                                    RewardChip(reward: 35, isActive: isAllSelected)
                                }
                                HorizontalDivider()
//                                ForEach(dataItems.indices) { index in
//                                    DataItemSelector(
//                                        isOn: $dataItems[index].isSelected,
//                                        label: "Expiry date",
//                                        value: "03/14/2060",
//                                        reward: 10
//                                    )
//                                }
                                DataItemSelector(
                                    isOn: $isDateOfIssueSelected,
                                    label: "Date of issue",
                                    value: "03/14/2024",
                                    reward: 5
                                )
                                DataItemSelector(
                                    isOn: $isNationalitySelected,
                                    label: "Nationality",
                                    value: "USA",
                                    reward: 20
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            VStack(spacing: 12) {
                Text("🎁 You will claim 80 / 85 RMO")
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

    private func makeDataRow(label: LocalizedStringResource, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label).body3()
            Spacer()
            Text(value).subtitle4()
        }
        .foregroundStyle(.textPrimary)
    }
}

struct DataItemSelector: View {
    @Binding var isOn: Bool
    let label: LocalizedStringResource
    let value: String
    let reward: Int

    var body: some View {
        HStack(spacing: 16) {
            Toggle(isOn: $isOn) {}
                .toggleStyle(PrimarySwitchToggleStyle())
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

struct RewardChip: View {
    let reward: Int
    let isActive: Bool

    init(reward: Int, isActive: Bool = false) {
        self.reward = reward
        self.isActive = isActive
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(String("+\(reward)")).subtitle5()
            Image(Icons.rarimo).iconSmall()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .foregroundStyle(isActive ? .textPrimary : .textSecondary)
        .background(isActive ? .warningLight : .componentPrimary)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

#Preview {
    SelectPassportDataView(onNext: {}, onClose: {})
}
