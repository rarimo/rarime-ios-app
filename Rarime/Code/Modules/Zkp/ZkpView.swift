import SwiftUI

struct ZkpView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var passportManager: PassportManager
    
    let onBack: () -> Void
    
    @State private var isGenerating = false
    @State private var proof: ZkProof? = nil
    
    @State private var zkpVariants: [ZkpVariants] = []
    
    @State private var isCopied = false
    
    var body: some View {
        VStack {
            back
            if let proof {
                Spacer()
                visualizeProof(proof)
                Spacer()
            } else {
                variants
                    .padding()
                Spacer()
                if isGenerating {
                    ProgressView()
                        .padding()
                } else {
                    AppButton(text: "Generate", action: generateProof)
                        .controlSize(.large)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    func visualizeProof(_ proof: ZkProof) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.baseBlack)
                VStack {
                    Text("Raw proof")
                        .h5()
                        .foregroundStyle(.white)
                        .padding()
                        .align(.leading)
                    ScrollView {
                        Text(visualizeProofJson(proof))
                            .body4()
                            .foregroundStyle(.white)
                    }
                    .padding()
                }
            }
            .frame(height: 250)
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.baseBlack)
                VStack {
                    Text("Public signals")
                        .h5()
                        .foregroundStyle(.white)
                        .padding()
                        .align(.leading)
                    ScrollView {
                        ForEach(zkpVariants, id: \.title) { signal in
                            HStack {
                                Text(signal.title)
                                    .body4()
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(signal.template)
                                    .body4()
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(height: 350)
            Spacer()
            copyButton
        }
    }
    
    func visualizeProofJson(_ proof: ZkProof) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try? encoder.encode(proof)
        
        return data?.utf8 ?? ""
    }
    
    func generateProof() {
        isGenerating = true
        Task { @MainActor in
            defer { isGenerating = false }
            
            do {
                try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
                
                proof = try! JSONDecoder().decode(ZkProof.self, from: ZkProof.template)
            } catch {
                LoggerUtil.common.error("error: \(error)")
                
                AlertManager.shared.emitError(.unknown("EVM RPC is not responding"))
            }
        }
    }
    
    func calculateSelector() -> Int {
        var selector = 0
        
        for variant in zkpVariants {
            let variantBit = 1 << variant.rawValue
            
            selector |= variantBit
        }
        
        return selector
    }
    
    var variants: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(.baseBlack)
            VStack {
                ForEach(ZkpVariants.allCases, id: \.self.rawValue) { zkpVariant in
                    variant(zkpVariant)
                        .padding()
                }
                Spacer()
            }
        }
        .frame(height: 500)
    }
    
    func variant(_ variant: ZkpVariants) -> some View {
        HStack {
            Toggle(
                variant.title,
                isOn: .init(
                    get: { zkpVariants.contains(variant) },
                    set: { isOn in
                        if isOn {
                            zkpVariants.append(variant)
                        } else {
                            zkpVariants.removeAll { $0 == variant }
                        }
                    }
                )
            )
            .body2()
            .foregroundStyle(.white)
        }
    }
    
    var back: some View {
        HStack {
            Text("ZKP Data")
                .h5()
                .foregroundStyle(.textSecondary)
                .padding(.top, 16)
                .align(.leading)
                .padding()
            Spacer()
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .foregroundStyle(.black)
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                }
            }
            .frame(width: 55, height: 55)
        }
    }
    
    var copyButton: some View {
        Button(action: {
            if isCopied { return }
            
            guard let user = userManager.user else { return }

            UIPasteboard.general.string = user.secretKey.hex
            isCopied = true
            FeedbackGenerator.shared.impact(.medium)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isCopied = false
            }
        }) {
            HStack {
                Image(isCopied ? Icons.check : Icons.copySimple).iconMedium()
                Text(isCopied ? "Copied" : "Copy to clipboard").buttonMedium()
            }
            .foregroundStyle(.textPrimary)
        }
    }
}

#Preview {
    ZkpView {}
        .environmentObject(UserManager.shared)
        .environmentObject(PassportManager.shared)
}
