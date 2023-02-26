import SwiftUI
import AVKit
import VisionKit

struct DataScanner: View {
    @State var isPresenting: Bool = false
    @State var uiImage: UIImage? = nil
    @State var showNextScreen: Bool = false

    @State var showResult: Bool = false

    var body: some View {
            ZStack(alignment: .top) {
                VStack {
                    Text("Maak een foto van je brief")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .modifier(StyledText(weight: .bold, color: .white))

                    Spacer()
                    Button {
                        isPresenting = false
                    } label: {
                        Text("Maak foto")
                    }
                    .buttonStyle(LargeButton(color: .white, textColor: Color(.darkText)))
                    .padding(.horizontal, 16)
                }.zIndex(100)
                ZStack {
                    ImageScanner(isPresenting: $isPresenting, uiIMage: $uiImage)
                    VStack {
                        Color.black.opacity(0.3).blur(radius: 0)
                            .edgesIgnoringSafeArea(.all)
                            .reverseMask {
                                Color.white
                                    .frame(maxWidth: .infinity)
                                    .padding(.all, 16)
                                    .aspectRatio(210/297, contentMode: .fit)
                                    .clipped()
                            }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                self.isPresenting = true
            }
            .onChange(of: uiImage, perform: { _ in
                showNextScreen = true
            })
        .background(
            NavigationLink(destination: ProcessingView(image: uiImage), isActive: $showNextScreen, label: {
                EmptyView()
            })
            .labelsHidden()
        )
        .modifier(HiddenNavBarModifier())
    }
}

extension View {
  @inlinable
  public func reverseMask<Mask: View>(
    alignment: Alignment = .center,
    @ViewBuilder _ mask: () -> Mask
  ) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
  }
}
