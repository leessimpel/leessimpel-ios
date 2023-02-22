import SwiftUI

struct OutLineButton: ButtonStyle {
    let textColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(maxWidth: .infinity)
            .foregroundColor(textColor)
            .padding(.vertical, 24)
//            .background(color.cornerRadius(32))

    }
}

struct LargeButton: ButtonStyle {
    let color: Color
    let textColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(maxWidth: .infinity)
            .foregroundColor(textColor)
            .padding(.vertical, 24)
            .background(color.cornerRadius(32))
    }
}
