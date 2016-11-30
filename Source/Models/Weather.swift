//  Copyright © 2016 Gavan Chan. All rights reserved.

import Argo
import Curry
import Runes

typealias Temperature = Double
typealias Percentage = Double

struct Weather {
  let city: City
  let current: Temperature
  let cloudiness: Percentage
}

extension Weather: Decodable {
  static func decode(_ json: JSON) -> Decoded<Weather> {
    let city: Decoded<City> = City.decode(json)
    let current: Decoded<Temperature> = json <| ["main", "temp"]
    let cloudiness: Decoded<Percentage> = json <| ["clouds", "all"]

    let initialiser: ((City) -> (Temperature) -> (Percentage) -> Weather) = curry(Weather.init)

    return initialiser <^> city <*> current <*> cloudiness
  }
}
