import UIKit
import ThinCloud

class VerifyUserViewController: UIViewController {

    static let signInToAppFromSignUpVerificationSegueIdentifier = "signInToAppFromSignUpVerificationSegueIdentifier"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmationCodeTextField: UITextField!

    @IBOutlet weak var verifyButton: UIButton!

    @IBOutlet weak var environmentLabel: UILabel!

    var email: String?
    var password: String?

    var isFormEnabled = true {
        didSet {
            confirmationCodeTextField.isEnabled = isFormEnabled
            verifyButton.isEnabled = isFormEnabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.text = email

        environmentLabel.text = ThinCloud.shared.instance
        verifyButton.isEnabled = false
    }

    @IBAction func verifyTouched(_ sender: UIButton) {
        guard let email = emailTextField.text, let confirmationCode = confirmationCodeTextField.text else {
            return
        }

        isFormEnabled = false

        ThinCloud.shared.verifyUser(email: email, confirmationCode: confirmationCode) { error in

            if let error = error {
                self.isFormEnabled = true
                return self.presentError(title: "Error Verifying User", description: error.localizedDescription)
            }

            guard let password = self.password else {
                return
            }

            // SDK consumer is responsible for passing in an initial e-mail and password

            ThinCloud.shared.signIn(email: email, password: password) { (error, _) in
                self.isFormEnabled = true

                if let error = error {
                    return self.presentError(title: "Error Signing In", description: error.localizedDescription)
                }

                // SDK consumer is responsible for initial call to register client, to provide most flexibility around APNs dialog

                ThinCloud.shared.registerClient()

                self.performSegue(withIdentifier: VerifyUserViewController.signInToAppFromSignUpVerificationSegueIdentifier, sender: sender)
            }
        }
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let email = emailTextField.text, let confirmationCode = confirmationCodeTextField.text else {
                return
        }

        verifyButton.isEnabled =  !email.isEmpty && !confirmationCode.isEmpty
    }

}
