import SwiftUI

struct HiddenNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .navigationBar)
        } else {
            content.navigationBarHidden(true)
            // Fallback on earlier versions
        }
    }
}

struct StyledText: ViewModifier {
    @Environment(\.font) var font

    let weight: Font.Weight
    let color: Color

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .fontWeight(weight)
                .foregroundColor(color)
        } else {
            content
                .font(font?.weight(weight))
                .foregroundColor(color)
            // Fallback on earlier versions
        }
    }
}

struct BorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray), lineWidth: 1)
            )
    }
}

struct HighlightModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.init(hex: "fff5ec").cornerRadius(8))
            .modifier(
                StyledText(
                    weight: .semibold,
                    color: Color(.darkText)
                )
            )
    }
}

struct SectionViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10){
                content
            }.padding(20)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
        }
        .transition(.move(edge: .bottom))
    }
}
