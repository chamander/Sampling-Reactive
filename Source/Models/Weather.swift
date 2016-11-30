//  Copyright © 2016 Gavan Chan. All rights reserved.

typealias Temperature = Double
typealias Percentage = Double

struct Weather {
  let city: City
  let current: Temperature
  let minimum: Temperature
  let maximum: Temperature
  let cloudiness: Percentage
}
