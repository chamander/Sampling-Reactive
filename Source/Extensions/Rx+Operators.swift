//  Copyright © 2016 Gavan Chan. All rights reserved.

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

import RxSwift
