//  Copyright © 2016 Gavan Chan. All rights reserved.

internal enum Transition<Content> {

  case appearing(Content)
  case transitioning(Content, Content)
  case disappearing(Content)

  init?(from previous: Content?, to next: Content?) {
    switch (previous, next) {
    case let (nil, destination?):
      self = .appearing(destination)
    case let (source?, destination?):
      self = .transitioning(source, destination)
    case let (source?, nil):
      self = .disappearing(source)
    case (nil, nil):
      return nil
    }
  }

}
