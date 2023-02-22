//
//  LottieRepresentable.swift
//  IkEetKip
//
//  Created by Niels Hoogendoorn on 20/02/2023.
//

import SwiftUI
import Lottie

struct LottieRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {

       let view = UIView(frame: .zero)

       let lottieAnimationView = LottieAnimationView(name: "4Gf9fVo6Kq")
       lottieAnimationView.contentMode = .scaleAspectFit
       lottieAnimationView.loopMode = .loop
       lottieAnimationView.play()

       lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(lottieAnimationView)

       NSLayoutConstraint.activate([
        lottieAnimationView.widthAnchor.constraint(equalToConstant: 100),
        lottieAnimationView.heightAnchor.constraint(equalToConstant: 100)
       ])

       return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        //
    }
}
