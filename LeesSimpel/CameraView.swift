//
//  CameraView.swift
//  IkEetKip
//
//  Created by Niels Hoogendoorn on 14/02/2023.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var model = DataModel()
    @Binding var isPresenting: Bool
    @Binding var uiIMage: UIImage?

    private static let barHeightFactor = 0.15

    var body: some View {
        GeometryReader { geometry in
            ViewfinderView(image:  $model.viewfinderImage )
                .overlay(alignment: .top) {
                    Color.black
                        .opacity(0.75)
                        .frame(height: geometry.size.height * Self.barHeightFactor)
                }
                .overlay(alignment: .center)  {
                    Color.clear
                        .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                        .accessibilityElement()
                        .accessibilityLabel("View Finder")
                        .accessibilityAddTraits([.isImage])
                }
                .background(.black)
        }
        .task {
            model.openCaptureStreams()
            await model.camera.start()
        }
        .onChange(of: isPresenting) { input in
            guard !input else { return }
            model.camera.takePhoto()
        }
        .onReceive(model.uiImage.publisher) { image in
            self.uiIMage = image

        }
    }
}

struct ViewfinderView: View {
    @Binding var image: Image?

    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
