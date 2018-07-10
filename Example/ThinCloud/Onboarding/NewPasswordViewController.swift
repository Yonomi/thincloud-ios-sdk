import UIKit
import ThinCloud

class NewPasswordViewController: UIViewController {

    static let unwindToSignInSegueIdentifier = "unwindToSignInSegueIdentifier"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var changeButton: UIButton!

    @IBOutlet weak var environmentLabel: UILabel!

    var email: String?

    var isFormEnabled = true {
        didSet {
            emailTextField.isEnabled = isFormEnabled
            confirmationCodeTextField.isEnabled = isFormEnabled
            passwordTextField.isEnabled = isFormEnabled
            changeButton.isEnabled = isFormEnabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.text = email

        environmentLabel.text = ThinCloud.shared.instance
        changeButton.isEnabled = false
    }

    @IBAction func cancelTouched(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func changeTouched(_ sender: UIButton) {
        guard let email = emailTextField.text, let confirmationCode = confirmationCodeTextField.text, let password = passwordTextField.text else {
            return
        }

        isFormEnabled = false

        ThinCloud.shared.verifyResetPassword(email: email, password: password, confirmationCode: confirmationCode) { error in
            self.isFormEnabled = true

            if let error = error {
                return self.presentError(title: "Error Changing Password", description: error.localizedDescription)
            }

            let alertController = UIAlertController(title: "Password Changed Successfully", message: "Please sign in with your new password.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.performSegue(withIdentifier: NewPasswordViewController.unwindToSignInSegueIdentifier, sender: sender)
            }
            alertController.addAction(okAction)

            self.present(alertController, animated: true)
        }
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let email = emailTextField.text, let confirmationCode = confirmationCodeTextField.text, let password = passwordTextField.text else {
            return
        }

        changeButton.isEnabled = !email.isEmpty && !confirmationCode.isEmpty && !password.isEmpty
    }

}
