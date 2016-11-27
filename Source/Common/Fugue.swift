//  Copyright © 2016 Gavan Chan. All rights reserved.

func const<Input, Element>(_ element: Element) -> ((Input) -> Element) {
  return { _ in element }
}
