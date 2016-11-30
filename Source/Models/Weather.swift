//  Copyright © 2016 Gavan Chan. All rights reserved.

import Foundation

typealias Temperature = Double
typealias Percentage = Double

struct Weather {
  let city: City
  let current: Temperature
  let cloudiness: Percentage
}

struct Forecast {
  let city: City
  let minimum: Temperature
  let maximum: Temperature
  let date: Date
}
