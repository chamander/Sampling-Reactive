//  Copyright © 2016 Gavan Chan. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

final class RotatingContentController: UIViewController {

  internal var contentProducer: Observable<UIViewController?> = .empty()

  internal var animationDuration: TimeInterval = 0.5

  internal var animationOptions: UIViewAnimationOptions = [.transitionCrossDissolve]

  internal var animatesTransitions: Bool { return !animationOptions.isEmpty }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  private var _animationDuration: TimeInterval {
    return animatesTransitions ? animationDuration : 0.0
  }

  private var transitions: Observable<Transition<UIViewController>> {
    return rx.viewDidAppear.take(1)
      .then(observable: contentProducer)
      .map(WeakBox.init)
      .combiningPrevious(startingWith: WeakBox(containing: nil))
      .map { Transition(from: $0.value, to: $1.value) }
      .ignoringNil()
  }

  private func perform(transition: Transition<UIViewController>) {
    switch transition {
    case let .appearing(content):
      perform(appearingTransitionTo: content)
    case let .disappearing(content):
      perform(disappearingTransitionFrom: content)
    case let .transitioning(source, destination):
      performTransition(from: source, to: destination)
    }
  }

  private func perform(appearingTransitionTo destination: UIViewController) {
    addChildViewController(destination)

    DispatchQueue.main.async {

      destination.view.frame = self.view.bounds

      let animation: (() -> Void) = {
        self.view.removeSubviews()
        self.view.addSubview(destination.view)
      }

      let completion: ((Bool) -> Void) = { _ in
        destination.didMove(toParentViewController: self)
      }

      UIView.transition(
        with:       self.view,
        duration:   self._animationDuration,
        options:    self.animationOptions,
        animations: animation,
        completion: completion)
    }
  }

  private func perform(disappearingTransitionFrom current: UIViewController) {
    current.willMove(toParentViewController: nil)

    DispatchQueue.main.async {

      let animation: (() -> Void) = {
        // Must remember to load no content view.`
        current.view.removeFromSuperview()
      }

      let completion: ((Bool) -> Void) = { _ in
        current.removeFromParentViewController()
        current.didMove(toParentViewController: nil)
      }

      UIView.transition(
        with:       self.view,
        duration:   self._animationDuration,
        options:    self.animationOptions,
        animations: animation,
        completion: completion)
    }
  }

  private func performTransition(from source: UIViewController, to destination: UIViewController) {
    addChildViewController(destination)
    source.willMove(toParentViewController: nil)

    DispatchQueue.main.async {

      let completion: ((Bool) -> Void) = { _ in
        source.removeFromParentViewController()
        source.didMove(toParentViewController: nil)
        destination.didMove(toParentViewController: self)
      }

      self.transition(
        from:       source,
        to:         destination,
        duration:   self._animationDuration,
        options:    self.animationOptions,
        animations: nil,
        completion: completion)
    }
  }

}

fileprivate extension UIView {

  func removeSubviews() {
    subviews.forEach { $0.removeFromSuperview() }
  }

}
