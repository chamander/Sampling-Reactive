//  Copyright © 2016 Gavan Chan. All rights reserved.

import Foundation
import ReactiveSwift
import Result

protocol WeatherProviding {
  func weather(for cityID: City.Identifier, in unit: UnitTemperature) -> SignalProducer<Weather, AnyError>
}
