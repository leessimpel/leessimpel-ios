//
//  ImageScannerRepresentable.swift
//  LeesSimpel
//
//  Created by Niels Hoogendoorn on 26/02/2023.
//

import SwiftUI
import WeScan

struct ImageScanner: UIViewControllerRepresentable {
    @Binding var isPresenting: Bool
    @Binding var uiImages: [UIImage]

    func makeUIViewController(context: Context) -> CameraScannerViewController {
        let vc = CameraScannerViewController()
        vc.delegate = context.coordinator

        return vc
    }

    func updateUIViewController(_ uiViewController: CameraScannerViewController, context: Context) {
        //
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraScannerViewOutputDelegate {
        deinit {
            print("deinittting")
        }
        func captureImageFailWithError(error: Error) {
            assertionFailure("error: \(error.localizedDescription)")
        }

        func captureImageSuccess(image: UIImage, withQuad quad: WeScan.Quadrilateral?) {
            imageScanner.uiImages.append(image)
        }

        let imageScanner: ImageScanner

        init(_ imageScanner: ImageScanner) {
            self.imageScanner = imageScanner
        }
    }
}
