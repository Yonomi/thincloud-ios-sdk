import UIKit
import ThinCloud

class SignInViewController: UIViewController {

    static let signInToAppSegueIdentifier = "signInToAppSegueIdentifier"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var environmentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        environmentLabel.text = ThinCloud.shared.instance
        signInButton.isEnabled = false
    }

    @IBAction func signInTouched(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
                return
        }

        sender.isEnabled = false

        // SDK consumer is responsible for passing in an initial e-mail and password

        ThinCloud.shared.signIn(email: email, password: password) { (error, _) in
            sender.isEnabled = true

            if let error = error {
                return self.presentError(title: "Error Signing In", description: error.localizedDescription)
            }

            // SDK consumer is responsible for initial call to register client, to provide most flexibility around APNs dialog

            ThinCloud.shared.registerClient()

            self.performSegue(withIdentifier: SignInViewController.signInToAppSegueIdentifier, sender: sender)
        }
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }

        signInButton.isEnabled = !email.isEmpty && !password.isEmpty
    }

}
