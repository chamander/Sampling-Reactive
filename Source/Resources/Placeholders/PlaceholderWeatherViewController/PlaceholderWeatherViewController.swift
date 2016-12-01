//  Copyright © 2016 Gavan Chan. All rights reserved.

import UIKit

final class PlaceholderWeatherViewController: UIViewController {

  @IBOutlet private weak var locationLabel: UILabel!
  @IBOutlet private weak var weatherInformationLabel: UILabel!

}

final class PlaceholderWeatherView: UIView {
  override static var layerClass: AnyClass { return CAGradientLayer.self }
}

struct PlaceholderWeatherViewModel {

}
