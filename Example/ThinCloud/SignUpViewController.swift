import UIKit
import ThinCloud

class SignUpViewController: UIViewController {

    static let signInToAppFromSignUpSegueIdentifier = "signInToAppFromSignUpSegueIdentifier"

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var environmentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        environmentLabel.text = ThinCloud.shared.instance
        signUpButton.isEnabled = false
    }

    @IBAction func cancelTouched(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func signUpTouched(_ sender: UIButton) {
        guard let name = nameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }

        ThinCloud.shared.createUser(name: name, email: email, password: password) { error, _ in
            if let error = error {
                return self.presentError(title: "Error Creating User", description: error.localizedDescription)
            }

            // SDK consumer is responsible for signing in after successfully creating a user

            ThinCloud.shared.signIn(email: email, password: password) { error, _ in
                if let error = error {
                    return self.presentError(title: "Error Signing In", description: error.localizedDescription)
                }

                self.performSegue(withIdentifier: SignUpViewController.signInToAppFromSignUpSegueIdentifier, sender: sender)
            }
        }
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }

        signUpButton.isEnabled = !name.isEmpty && !email.isEmpty && !password.isEmpty
    }
}
