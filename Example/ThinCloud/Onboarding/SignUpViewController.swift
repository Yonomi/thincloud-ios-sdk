import UIKit
import ThinCloud

class SignUpViewController: UIViewController {

    static let confirmationCodeSegueIdentifier = "confirmationCodeSegueIdentifier"

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var environmentLabel: UILabel!

    var isFormEnabled = true {
        didSet {
            nameTextField.isEnabled = isFormEnabled
            emailTextField.isEnabled = isFormEnabled
            passwordTextField.isEnabled = isFormEnabled
            signUpButton.isEnabled = isFormEnabled
        }
    }

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

        isFormEnabled = false

        ThinCloud.shared.createUser(name: name, email: email, password: password) { error, _ in
            if let error = error {
                self.isFormEnabled = true
                return self.presentError(title: "Error Creating User", description: error.localizedDescription)
            }

            // A user must verify their account before they can sign in.

            self.performSegue(withIdentifier: SignUpViewController.confirmationCodeSegueIdentifier, sender: sender)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SignUpViewController.confirmationCodeSegueIdentifier {
            guard let destination = segue.destination as? VerifyUserViewController else {
                return
            }

            destination.email = emailTextField.text
            destination.password = passwordTextField.text
        }
    }
}
