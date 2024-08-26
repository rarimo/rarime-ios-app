import NFCPassportReader
import SwiftUI

struct SelectPassportDataView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel
    let onNext: () -> Void
    let onClose: () -> Void

    private var passport: Passport {
        passportViewModel.passport!
    }

    private var gender: LocalizedStringResource {
        return passport.gender == "M" ? "Male" : "Female"
    }

    var body: some View {
        ScanPassportLayoutView(
            step: 3,
            title: "Document data",
            text: "Data generates an incognito profile",
            onClose: onClose
        ) {
            if passportViewModel.passport != nil {
                VStack(spacing: 12) {
                    generalDataSection
                    mustDataSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            Spacer()
            AppButton(text: "Continue", action: onNext)
                .controlSize(.large)
                .padding(.top, 12)
                .padding(.bottom, 20)
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
                PassportImageView(image: passport.passportImage)
            }
        }
    }

    private var mustDataSection: some View {
        CardContainer {
            VStack(spacing: 20) {
                HStack {
                    Text("Identifiers")
                        .subtitle3()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    RewardChipView(
                        reward: Int(PASSPORT_RESERVE_TOKENS),
                        isActive: true
                    )
                    .opacity(passportViewModel.isEligibleForReward ? 1 : 0)
                }
                VStack(spacing: 16) {
                    makeDocumentRow(label: "Document class mode", value: passport.documentType)
                    makeDocumentRow(label: "Issuing state code", value: passport.issuingAuthority)
                    makeDocumentRow(label: "Document ID", value: passport.documentNumber)
                }
            }
        }
    }

    private func makeDocumentRow(label: LocalizedStringResource, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label).body3()
            Spacer()
            Text(value).subtitle4()
        }
        .foregroundStyle(.textPrimary)
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
                    passportImageRaw: nil,
                    documentType: "P",
                    issuingAuthority: "USA",
                    documentNumber: "00AA00000",
                    documentExpiryDate: "900314",
                    dateOfBirth: "600314",
                    nationality: "USA",
                    dg1: Data(),
                    dg15: Data(),
                    sod: Data(),
                    signature: Data()
                )
            )
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    PreviewView()
}
