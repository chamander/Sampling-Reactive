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
