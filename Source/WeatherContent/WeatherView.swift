//  Copyright © 2016 Gavan Chan. All rights reserved.

import UIKit

final class WeatherView: UIView {

  enum Theme {
    case blistering
    case hot
    case neutral
    case cold

    fileprivate var gradientColors: (top: UIColor, bottom: UIColor) {
      switch self {
      case .blistering:
        return (.init(rgb: (254, 229, 207)), .init(rgb: (253, 191, 132)))
      case .hot:
        return (.init(rgb: (254, 212, 171)), .init(rgb: (255, 240, 233)))
      case .neutral:
        return (.init(rgb: (226, 232, 254)), .init(rgb: (255, 249, 255)))
      case .cold:
        return (.init(rgb: (255, 249, 255)), .init(rgb: (226, 232, 254)))
      }
    }
  }

  var theme: Theme? {

    didSet {

      let animation: (() -> Void)

      guard let existing: CAGradientLayer = layer as? CAGradientLayer else { fatalError("Class must match `static var layerClass`.") }

      if let theme = theme {

        let colors: (top: UIColor, bottom: UIColor) = theme.gradientColors

        animation = {
          existing.colors = [colors.top.cgColor, colors.bottom.cgColor]
          self.backgroundColor = nil
        }

      } else {

        animation = {
          existing.colors = [UIColor.white.cgColor]
          self.backgroundColor = .white
        }

      }

      UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve, .curveLinear], animations: animation)

    }

  }

  override static var layerClass: AnyClass { return CAGradientLayer.self }

}

fileprivate extension UIColor {

  convenience init(rgb: (Int, Int, Int), alpha: CGFloat = 1.0) {
    let red: CGFloat = CGFloat(rgb.0) / 255.0
    let green: CGFloat = CGFloat(rgb.1) / 255.0
    let blue: CGFloat = CGFloat(rgb.2) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

}
