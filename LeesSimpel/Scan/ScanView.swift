import SwiftUI
import AVKit
import VisionKit

struct DataScanner: View {
    @State var isPresenting: Bool = false
    @State var uiImages: [UIImage] = []
    @State var showNextScreen: Bool = false

    @State var showNextAction: Bool = false
    @State var showResult: Bool = false

    var body: some View {
            ZStack(alignment: .top) {
                if showNextAction {
                    VStack(spacing: 24) {
                        Spacer()
                        Text("Scans gemaakt: \(uiImages.count)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 16)

                        Button("Nog een scan maken") {
                            showNextAction = false
                        }
                        .buttonStyle(LargeButton(color: .blue, textColor: .white))

                        Button("Ik ben klaar met scannen!") {
                            showNextScreen = true
                        }
                        .buttonStyle(LargeButton(color: .green, textColor: .white))
                        Spacer()
                    }
                    .padding()

                } else {
                    VStack {
                        Text("Maak een foto van je brief")
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .modifier(StyledText(weight: .bold, color: .white))
                    }.zIndex(100)
                    ZStack {
                        ImageScanner(isPresenting: $isPresenting, uiImages: $uiImages)
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
            }
            .onAppear {
                self.isPresenting = true
            }
            .onChange(of: uiImages, perform: { _ in
                self.showNextAction = true
            })
        .background(
            NavigationLink(destination: ProcessingView(images: uiImages), isActive: $showNextScreen, label: {
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
