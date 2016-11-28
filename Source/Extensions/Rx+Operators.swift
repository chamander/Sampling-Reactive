//  Copyright © 2016 Gavan Chan. All rights reserved.

extension ObservableType {

  func subscribe(disposed: (() -> Void)? = nil, completed: (() -> Void)? = nil, error: ((Error) -> Void)? = nil, next: ((E) -> Void)? = nil) -> Disposable {
    return subscribe(onNext: next, onError: error, onCompleted: completed, onDisposed: disposed)
  }

  func then<U>(observable replacement: Observable<U>) -> Observable<U> {
    return Observable<U>.create { observer in
      let disposable: CompositeDisposable = CompositeDisposable()

      let outerDisposable = self.subscribe { event in
        switch event {
        case .next:
          break
        case let .error(error):
          observer.onError(error)
        case .completed:
          let innerDisposable: Disposable = replacement.subscribe(observer)
          _ = disposable.insert(innerDisposable)
        }
      }

      _ = disposable.insert(outerDisposable)
      return disposable
    }
  }

  func spacingSamples(by timeInterval: RxTimeInterval, on scheduler: SchedulerType) -> Observable<E> {
    return Observable<E>.create { observer in
      let disposable: CompositeDisposable = CompositeDisposable()

      var internalStorage: Array<E> = Array()

      var innerObservableCompleted: Bool = false

      let finishInnerObservable: (() -> Void) = {
        if internalStorage.isEmpty { observer.onCompleted() }
        innerObservableCompleted = true
      }

      let storeNextValue: ((E) -> Void) = {
        // TODO: Implement synchronized access.
        internalStorage.append($0)
      }

      _ = disposable.insert(self.subscribe(onNext: storeNextValue, onError: observer.onError, onCompleted: finishInnerObservable))

      let schedulerDisposable: Disposable = scheduler.schedulePeriodic((), startAfter: 0.0, period: timeInterval) {
        // TODO: Improve timing of first sent value to not be delayed.
        if internalStorage.first != nil {
          let value: E = internalStorage.removeFirst()
          observer.onNext(value)
        } else if innerObservableCompleted {
          observer.onCompleted()
        }
      }

      _ = disposable.insert(schedulerDisposable)

      return disposable
    }
  }

  func combiningPrevious(startingWith initialValue: E) -> Observable<(E, E)> {
    return scan((initialValue, initialValue)) { previousPair, newValue in (previousPair.1, newValue) }
  }

}

extension ObservableType where E: Collection {

  func mapArgumentsTo<First>(_ first: First.Type) -> Observable<First> {
    return map {
      let value: First! = $0.first as? First
      return value
    }
  }

  func mapArgumentsTo<First, Second>(_ first: First.Type, _ second: Second.Type) -> Observable<(First, Second)> {
    return map {
      var iterator: E.Iterator = $0.makeIterator()
      let first: First! = iterator.next() as? First
      let second: Second! = iterator.next() as? Second
      return (first, second)
    }
  }

}

extension ObservableType where E: OptionalProtocol {

  func ignoringNil() -> Observable<E.Wrapped> {
    return filter { $0.optional != nil }
      .map {
        guard let value = $0.optional else { fatalError() }
        return value
    }
  }

}

import RxSwift
