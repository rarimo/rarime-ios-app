//
//  ScanPassportView+ViewModel.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 02.04.2024.
//

import NFCPassportReader
import SwiftUI

struct PassportProofDataItem: Identifiable {
    let id = UUID()
    let label: LocalizedStringResource
    let value: String
    var valueType: DataValueType = .text
    var reward: Int = 0
    
    var isRequired: Bool = false
    var isSelected: Bool = false
    var processingStatus: ProcessingStatus = .processing
    
    enum DataValueType {
        case text, date
    }
    
    var formattedValue: String {
        switch valueType {
        case .date:
            do {
                return try DateUtil.mdyDateFormatter.string(from: DateUtil.parsePassportDate(value))
            } catch {
                return value
            }
        case .text:
            return value
        }
    }
}

private let requiredDataReward = 50

class PassportViewModel: ObservableObject {
    @Published var passport: Passport?
    @Published private var dataItems: [PassportProofDataItem]

    init(dataItems: [PassportProofDataItem] = []) {
        self.dataItems = dataItems
    }
        
    var requiredDataItems: [PassportProofDataItem] {
        dataItems.filter { $0.isRequired }
    }
        
    var optionalDataItems: [PassportProofDataItem] {
        dataItems.filter { !$0.isRequired }
    }
        
    var selectedDataItems: [PassportProofDataItem] {
        dataItems.filter { $0.isRequired || $0.isSelected }
    }
        
    var totalReward: Int {
        requiredDataReward + dataItems.reduce(0) { $0 + $1.reward }
    }
        
    var selectedReward: Int {
        requiredDataReward + selectedDataItems.reduce(0) { $0 + $1.reward }
    }
        
    var generalProcessingStatus: ProcessingStatus {
        if selectedDataItems.allSatisfy({ $0.processingStatus == .success }) {
            return .success
        }

        return selectedDataItems.allSatisfy { $0.processingStatus == .failure }
            ? .failure
            : .processing
    }
        
    func setPassport(_ passport: Passport) {
        self.passport = passport
        dataItems = [
            PassportProofDataItem(
                label: "Document type",
                value: passport.documentType,
                isRequired: true
            ),
            PassportProofDataItem(
                label: "Issuing authority",
                value: passport.issuingAuthority,
                isRequired: true
            ),
            PassportProofDataItem(
                label: "Document number",
                value: passport.documentNumber,
                isRequired: true
            ),
            PassportProofDataItem(
                label: "Expiry date",
                value: passport.documentExpiryDate,
                valueType: .date,
                reward: 10
            ),
            PassportProofDataItem(
                label: "Date of birth",
                value: passport.dateOfBirth,
                valueType: .date,
                reward: 5
            ),
            PassportProofDataItem(
                label: "Nationality",
                value: passport.nationality,
                reward: 20
            )
        ]
    }
        
    func changeItemSelection(id: UUID, isSelected: Bool) {
        guard let index = dataItems.firstIndex(where: { $0.id == id }) else { return }
        dataItems[index].isSelected = isSelected
    }
        
    @MainActor
    func processItem(id: UUID) async {
        guard let index = dataItems.firstIndex(where: { $0.id == id }) else { return }
        dataItems[index].processingStatus = .processing

        do {
            // TODO: Generate proof data
            try await Task.sleep(nanoseconds: UInt64(2) * NSEC_PER_SEC)
            dataItems[index].processingStatus = .success
        } catch {
            dataItems[index].processingStatus = .failure
        }
    }
}
