//  Copyright © 2016 Gavan Chan. All rights reserved.

import UIKit

final class PlaceholderActionViewController: UIViewController {

  convenience init(withPlaceholderText text: String, buttonText: String, andAction action: @escaping (() -> Void)) {
    self.init()
    self.text = text
    self.action = action
    self.buttonText = buttonText
  }

  override func viewDidLoad() {
    placeholderLabel.text = text
    placeholderButton.setTitle(buttonText, for: .normal)
  }

  @IBOutlet private weak var placeholderLabel: UILabel!
  @IBOutlet private weak var placeholderButton: UIButton!

  private var action: (() -> Void)?
  private var text: String?
  private var buttonText: String?

  @IBAction private func buttonWasTapped(_ sender: UIButton) {
    action?()
  }

}
