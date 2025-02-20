import SwiftUI

@resultBuilder
struct ViewArrayBuilder {
    static func buildExpression<V: View>(_ expression: V) -> [AnyView] {
        [AnyView(expression)]
    }
    
    static func buildBlock<V: View>(_ views: V...) -> [AnyView] {
        views.map { AnyView($0) }
    }
    
    static func buildBlock(_ components: [AnyView]...) -> [AnyView] {
        components.flatMap { $0 }
    }
    
    static func buildOptional(_ component: [AnyView]?) -> [AnyView] {
        component ?? []
    }
    
    static func buildEither(first component: [AnyView]) -> [AnyView] {
        component
    }
    
    static func buildEither(second component: [AnyView]) -> [AnyView] {
        component
    }
    
    static func buildArray(_ components: [[AnyView]]) -> [AnyView] {
        components.flatMap { $0 }
    }
}
