//  Copyright © 2016 Gavan Chan. All rights reserved.

import Foundation

struct Environment {

  enum Variable: String {
    case networkStubbing = "NETWORK_STUBBING"
  }

  static let shared: Environment = .init()

  var isStubbingNetwork: Bool {
    return variables[.networkStubbing] == "true"
  }

  private init() { }

  private let variables: Dictionary<Variable, String> = {
    var variables: Dictionary<Variable, String> = Dictionary()

    let conversion: ((String, String) -> (Variable, String)?) = {
      guard let variable: Variable = Variable(rawValue: $0) else { return nil }
      return (variable, $1)
    }

    ProcessInfo.processInfo.environment.flatMap(conversion).forEach { variables.updateValue($0.1, forKey: $0.0) }

    return variables
  }()

}
