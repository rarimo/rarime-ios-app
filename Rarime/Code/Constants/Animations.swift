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
    static let incognito = ThemedAnimation(light: "IncognitoLight", dark: "IncognitoDark")
    static let processing = ThemedAnimation("Processing")
}
