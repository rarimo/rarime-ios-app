struct ThemedAnimation {
    let light: String
    let dark: String

    init(light: String, dark: String) {
        self.light = light
        self.dark = dark
    }

    init(_ name: String) {
        self.light = name
        self.dark = name
    }
}

enum Animations {
    static let passport = ThemedAnimation("Passport")
    static let introWelcome = ThemedAnimation("IntroWelcome")
    static let introIncognito = ThemedAnimation("IntroIncognito")
    static let introProofs = ThemedAnimation("IntroProofs")
    static let introRewards = ThemedAnimation("IntroRewards")
    static let incognito = ThemedAnimation(light: "IncognitoLight", dark: "IncognitoDark")
    static let scanPassport = ThemedAnimation("ScanPassport")
}
