//  Copyright © 2016 Gavan Chan. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

final class WeatherViewController: UIViewController {

  private var currentModel: Weather? = nil

  private let disposables: CompositeDisposable = CompositeDisposable()

  private var weatherTransitioningDisposableKey: CompositeDisposable.DisposeKey? = nil

  private var contentProducer: Observable<Weather?> = .empty() {
    didSet {
      if let key = weatherTransitioningDisposableKey { disposables.remove(for: key) }

      let disposable: Disposable = transitions
        .observeOn(MainScheduler.asyncInstance)
        .subscribe { [weak self] in self?.perform(transition: $0) }

      weatherTransitioningDisposableKey = disposables.insert(disposable)
    }
  }

  private var transitions: Observable<Transition<Weather>> {
    return contentProducer
      .combiningPrevious(startingWith: nil)
      .map(Transition.init)
      .ignoringNil()
  }

  internal var animationDuration: TimeInterval = 0.5

  internal var animationOptions: UIViewAnimationOptions = [.transitionCrossDissolve, .curveLinear]

  internal var animatesTransitions: Bool { return !animationOptions.isEmpty }

  private var _animationDuration: TimeInterval {
    return animatesTransitions ? animationDuration : 0.0
  }

  @IBOutlet private weak var locationLabel: UILabel!
  @IBOutlet private weak var weatherInformationLabel: UILabel!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet private var weatherView: WeatherView!

  private func perform(transition: Transition<Weather>) {
    switch transition {

    case .disappearing:
      locationLabel.isHidden = true
      weatherInformationLabel.isHidden = true

      activityIndicator.isHidden = false
      activityIndicator.startAnimating()

      weatherView.theme = nil

    case let .appearing(weather):
      let viewModel: WeatherViewModel = WeatherViewModel(with: weather)

      locationLabel.isHidden = false
      weatherInformationLabel.isHidden = false

      activityIndicator.stopAnimating()

      weatherView.theme = viewModel.theme

      let animations: (() -> Void) = {
        self.locationLabel.text = viewModel.location
        self.weatherInformationLabel.text = viewModel.information
      }

      UIView.transition(with: weatherView, duration: 0.5, options: .curveLinear, animations: animations)

    case let.transitioning(_, weather):
      let viewModel: WeatherViewModel = WeatherViewModel(with: weather)

      weatherView.theme = viewModel.theme

      let animations: (() -> Void) = {
        self.locationLabel.text = viewModel.location
        self.weatherInformationLabel.text = viewModel.information
      }

      UIView.transition(with: weatherView, duration: 0.5, options: .curveLinear, animations: animations)
    }
  }

}

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

  private var gradient: CAGradientLayer?

  var theme: Theme? {

    didSet {

      let animation: (() -> Void)

      if case let .some(theme) = theme {
        let colors: (top: UIColor, bottom: UIColor) = theme.gradientColors
        animation = {
          let gradient: CAGradientLayer = CAGradientLayer()
          gradient.frame = self.layer.frame
          gradient.colors = [colors.top.cgColor, colors.bottom.cgColor]

          self.gradient = gradient
          self.layer.insertSublayer(gradient, at: 0)
          self.backgroundColor = nil
        }
      } else {
        animation = {
          self.gradient?.removeFromSuperlayer()
          self.gradient = nil
          self.backgroundColor = .white
        }
      }

      UIView.transition(with: self, duration: 0.5, options: [.curveLinear], animations: animation)

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
