//  Copyright © 2016 Gavan Chan. All rights reserved.

import Argo
import Curry
import Runes

struct City {
  typealias Identifier = Int
  typealias Name = String

  let identifier: Identifier
  let name: Name
}

extension City: Argo.Decodable {
  static func decode(_ json: JSON) -> Decoded<City> {
    let identifier: Decoded<Identifier> = json <| "id"
    let name: Decoded<Name> = json <| "name"

    let initialiser: ((Identifier) -> (Name) -> City) = curry(City.init)

    return initialiser <^> identifier <*> name
  }
}
