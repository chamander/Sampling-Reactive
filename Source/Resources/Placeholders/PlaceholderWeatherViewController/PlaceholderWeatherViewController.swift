//  Copyright © 2016 Gavan Chan. All rights reserved.

import UIKit

final class PlaceholderWeatherViewController: UIViewController {

  @IBOutlet private weak var locationLabel: UILabel!
  @IBOutlet private weak var weatherInformationLabel: UILabel!

}

final class PlaceholderWeatherView: UIView {

  enum Theme {
    case blistering
    case hot
    case neutral
    case cold

    var gradientColors: (light: UIColor, dark: UIColor) {
      switch self {
      case .blistering:
        return (.init(rgb: (254, 229, 207)), .init(rgb: (253, 191, 132)))
      case .hot:
        return (.init(rgb: (254, 212, 171)), .init(rgb: (255, 240, 233)))
      case .neutral:
        return (.init(rgb: (226, 232, 254)), .init(rgb: (255, 249, 255)))
      case .cold:
        return (.init(rgb: (253, 194, 164)), .init(rgb: (226, 232, 254)))
      }
    }
  }

  override static var layerClass: AnyClass { return CAGradientLayer.self }

}

struct PlaceholderWeatherViewModel {

}

fileprivate extension UIColor {

  convenience init(rgb: (Int, Int, Int), alpha: CGFloat = 1.0) {
    let red: CGFloat = CGFloat(rgb.0) / 255.0
    let green: CGFloat = CGFloat(rgb.1) / 255.0
    let blue: CGFloat = CGFloat(rgb.2) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

}
