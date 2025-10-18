//
//  LottieView.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 07.10.25.
//

import UIKit
import Lottie

final class LottieView: UIView {
  private var animationView: LottieAnimationView?

  init(name: String) {
    super.init(frame: .zero)
    let v = LottieAnimationView(name: name)
    v.loopMode = .loop
    v.translatesAutoresizingMaskIntoConstraints = false
    addSubview(v)
    NSLayoutConstraint.activate([
      v.leadingAnchor.constraint(equalTo: leadingAnchor),
      v.trailingAnchor.constraint(equalTo: trailingAnchor),
      v.topAnchor.constraint(equalTo: topAnchor),
      v.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    v.play()
    animationView = v
  }
  required init?(coder: NSCoder) { fatalError() }
}
