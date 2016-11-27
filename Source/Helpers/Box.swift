//  Copyright © 2016 Gavan Chan. All rights reserved.

final class WeakBox<Element: AnyObject> {

  weak var value: Element?

  init(containing value: Element?) { self.value = value }

}
