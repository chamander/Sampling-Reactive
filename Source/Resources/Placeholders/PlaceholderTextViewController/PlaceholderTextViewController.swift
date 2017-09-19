//  Copyright © 2016 Gavan Chan. All rights reserved.

import UIKit

final class PlaceholderTextViewController: UIViewController {

  @IBOutlet private weak var placeholderLabel: UILabel!

  private var text: String?

  convenience init(with text: String) {
    self.init()
    self.text = text
  }

  override func viewWillAppear(_ animated: Bool) {
    placeholderLabel.text = text
  }

}
