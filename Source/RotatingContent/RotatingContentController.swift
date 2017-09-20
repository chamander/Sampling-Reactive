//  Copyright © 2016 Gavan Chan. All rights reserved.

import Foundation
import ReactiveSwift
import Result
import UIKit

final class RotatingContentController: UIViewController {

  private weak var currentController: UIViewController? = nil

  private let disposables: CompositeDisposable = CompositeDisposable()

  deinit { disposables.dispose() }

  internal var contentProducer: SignalProducer<UIViewController?, NoError> = .empty {
    didSet {
      let disposable: Disposable = transitions
        .observe(on: QueueScheduler.main)
        .startWithValues { [weak self] in self?.perform(transition: $0) }
      disposables.add(disposable)
    }
  }

  internal var animationDuration: TimeInterval = 0.5

  internal var animationOptions: UIViewAnimationOptions = [.transitionCrossDissolve]

  internal var animatesTransitions: Bool { return !animationOptions.isEmpty }

  override func viewDidLoad() {
    super.viewDidLoad()
    contentProducer = testObservable
  }

  private var _animationDuration: TimeInterval {
    return animatesTransitions ? animationDuration : 0.0
  }

  private var transitions: SignalProducer<Transition<UIViewController>, NoError> {
    return contentProducer
      .map(WeakBox.init)
      .combinePrevious(WeakBox(containing: currentController))
      .map { Transition(from: $0.value, to: $1.value) }
      .skipNil()
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
    currentController = destination

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
        self.currentController = nil
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
    currentController = destination
    source.willMove(toParentViewController: nil)

    DispatchQueue.main.async {

      let animation: () -> Void = {
        destination.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
          [
            self.view.topAnchor.constraint(equalTo: destination.view.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: destination.view.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: destination.view.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: destination.view.trailingAnchor),
          ]
        )
      }

      let completion: ((Bool) -> Void) = { _ in
        source.removeFromParentViewController()
        destination.didMove(toParentViewController: self)
      }

      self.transition(
        from:       source,
        to:         destination,
        duration:   self._animationDuration,
        options:    self.animationOptions,
        animations: animation,
        completion: completion)
    }
  }

  private var testObservable: SignalProducer<UIViewController?, NoError> {

    return SignalProducer<UIViewController, NoError> { observer, _ in

      var disposed: Bool = false

      func dispatch(_ work: @escaping (() -> Void)) {
        if !disposed { DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: work) }
      }

      let restartBlock: (() -> Void) = {
        let restart: UIViewController = PlaceholderActionViewController(withPlaceholderText: "Lorem Ipsum.", buttonText: "Restart") { [unowned self] in
          self.contentProducer = self.testObservable
        }
        observer.send(value: restart)
        observer.sendCompleted()
      }

      let quxBazBlock: (() -> Void) = {
        let quxBaz: UIViewController = PlaceholderTextViewController(with: "Qux Baz...!")
        observer.send(value: quxBaz)
        dispatch(restartBlock)
      }

      let fooBarBlock: (() -> Void) = {
        let fooBar: UIViewController = PlaceholderTextViewController(with: "Foo Bar?!")
        observer.send(value: fooBar)
        dispatch(quxBazBlock)
      }

      DispatchQueue.main.async {
        let helloWorld: UIViewController = PlaceholderTextViewController(with: "Hello World!")
        observer.send(value: helloWorld)
        dispatch(fooBarBlock)
      }

    }.map(Optional.init)

  }

}

fileprivate extension UIView {

  func removeSubviews() {
    subviews.forEach { $0.removeFromSuperview() }
  }

}
