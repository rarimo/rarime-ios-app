import SwiftUI

struct DropdownOption<T: Hashable> {
    let label: String
    let value: T
}

struct AppDropdown<T: Hashable>: View {
    @Binding var value: T
    let options: [DropdownOption<T>]

    @State private var isExpanded = false

    var selectedOption: DropdownOption<T> {
        options.first { $0.value == value } ?? options.first!
    }

    var body: some View {
        ZStack {
            HStack(spacing: 4) {
                Text(selectedOption.label).overline2()
                Image(Icons.carretDown).square(12)
            }
            .foregroundStyle(.textPrimary)
            .onTapGesture {
                isExpanded.toggle()
                FeedbackGenerator.shared.impact(.light)
            }
            .overlay(alignment: .topLeading) {
                ZStack {
                    if isExpanded {
                        VStack(spacing: 0) {
                            ForEach(options, id: \.value) { option in
                                Button(action: {
                                    value = option.value
                                    isExpanded.toggle()
                                    FeedbackGenerator.shared.impact(.light)
                                }) {
                                    HStack {
                                        Text(option.label).overline2()
                                        Spacer()
                                        if option.value == value {
                                            Image(Icons.check).iconSmall()
                                        }
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .foregroundStyle(.textPrimary)
                                }
                                if option.value != options.last!.value {
                                    HorizontalDivider()
                                }
                            }
                        }
                        .background(.backgroundOpacity, in: RoundedRectangle(cornerRadius: 12))
                        .frame(width: 150)
                        .offset(y: 24)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        VStack(alignment: .leading, spacing: 8) {
            AppDropdown(
                value: .constant("1"),
                options: [
                    DropdownOption(label: "Option 1", value: "1"),
                    DropdownOption(label: "Option 2", value: "2"),
                    DropdownOption(label: "Option 3", value: "3")
                ]
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.backgroundPrimary)
}
