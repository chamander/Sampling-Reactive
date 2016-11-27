//  Copyright © 2016 Gavan Chan. All rights reserved.

protocol OptionalProtocol {

  associatedtype Wrapped

  var optional: Wrapped? { get }

}

extension Optional: OptionalProtocol {

  var optional: Wrapped? { return self }

}
