//  Copyright © 2016 Gavan Chan. All rights reserved.

import ReactiveSwift
import Result
import UIKit

final class WeatherViewController: UIViewController {

  private var currentModel: Weather? = nil

  private let disposables: CompositeDisposable = CompositeDisposable()

  private var contentProducer: SignalProducer<Weather?, NoError> = .empty {
    didSet {
      let disposable: Disposable = transitions
        .observe(on: QueueScheduler.main)
        .startWithValues { [weak self] in self?.perform(transition: $0) }
      disposables.add(disposable)
    }
  }

  private var transitions: SignalProducer<Transition<Weather>, NoError> {
    return contentProducer
      .combinePrevious(currentModel)
      .map(Transition.init)
      .skipNil()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    contentProducer = testObservable
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
      currentModel = weather
      let viewModel: WeatherViewModel = WeatherViewModel(with: weather)

      locationLabel.isHidden = false
      weatherInformationLabel.isHidden = false

      activityIndicator.stopAnimating()

      weatherView.theme = viewModel.theme

      let animations: (() -> Void) = {
        self.locationLabel.text = viewModel.location
        self.weatherInformationLabel.text = viewModel.information
      }

      UIView.transition(with: weatherView, duration: 0.5, options: animationOptions, animations: animations)

    case let .transitioning(_, weather):
      currentModel = weather
      let viewModel: WeatherViewModel = WeatherViewModel(with: weather)

      weatherView.theme = viewModel.theme

      let animations: (() -> Void) = {
        self.locationLabel.text = viewModel.location
        self.weatherInformationLabel.text = viewModel.information
      }

      UIView.transition(with: weatherView, duration: 0.5, options: animationOptions, animations: animations)
    }
  }

  private var testObservable: SignalProducer<Weather?, NoError> {
    return SignalProducer<Weather?, NoError> { observer, _ in

      var cities: Array<City> = [
        (7839805, "Melbourne"),
        (2147714, "Sydney"),
        (2063523, "Perth"),
        (2078025, "Adelaide"),
      ].map(City.init)

      var disposed: Bool = false

      func dispatch(_ work: @escaping (() -> Void)) {
        if !disposed { DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: work) }
      }

      let adelaideBlock: (() -> Void) = {
        let adelaide = cities.removeFirst()
        observer.send(value: Weather(city: adelaide, current: 28.0, cloudiness: 40.0))
        observer.sendCompleted()
      }

      let perthBlock: (() -> Void) = {
        let perth = cities.removeFirst()
        observer.send(value: Weather(city: perth, current: 24.0, cloudiness: 80.0))
        dispatch(adelaideBlock)
      }

      let sydneyBlock: (() -> Void) = {
        let sydney = cities.removeFirst()
        observer.send(value: Weather(city: sydney, current: 17.0, cloudiness: 60.0))
        dispatch(perthBlock)
      }

      let melbourneBlock: (() -> Void) = {
        let melbourne = cities.removeFirst()
        observer.send(value: Weather(city: melbourne, current: 37.0, cloudiness: 20.0))
        dispatch(sydneyBlock)
      }

      let nilBlock: (() -> Void) = {
        observer.send(value: nil)
        dispatch(melbourneBlock)
      }

      DispatchQueue.main.async(execute: nilBlock)

    }
  }

}
