import UIKit
import ThinCloud

class ResetPasswordViewController: UIViewController {

    static let newPasswordSegueIdentifier = "newPasswordSegueIdentifier"

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var resetButton: UIButton!

    @IBOutlet weak var environmentLabel: UILabel!

    var isFormEnabled = true {
        didSet {
            emailTextField.isEnabled = isFormEnabled
            resetButton.isEnabled = isFormEnabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        environmentLabel.text = ThinCloud.shared.instance
        resetButton.isEnabled = false
    }

    @IBAction func cancelTouched(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func resetTouched(_ sender: UIButton) {
        guard let email = emailTextField.text else {
                return
        }

        isFormEnabled = false

        ThinCloud.shared.resetPassword(email: email) { (error) in
            self.isFormEnabled = true

            if let error = error {
                return self.presentError(title: "Error Resetting Password", description: error.localizedDescription)
            }

            self.performSegue(withIdentifier: ResetPasswordViewController.newPasswordSegueIdentifier, sender: sender)
        }
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let email = emailTextField.text else {
                return
        }

        resetButton.isEnabled = !email.isEmpty
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ResetPasswordViewController.newPasswordSegueIdentifier, let destination = segue.destination as? NewPasswordViewController {
            destination.email = emailTextField.text
        }
    }

}
