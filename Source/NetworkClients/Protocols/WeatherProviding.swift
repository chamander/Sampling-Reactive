//  Copyright © 2016 Gavan Chan. All rights reserved.

protocol WeatherProviding {
  func weather(for cityID: City.Identifier, in metric: UnitTemperature) -> Observable<Weather>
}

import Foundation
import RxSwift
