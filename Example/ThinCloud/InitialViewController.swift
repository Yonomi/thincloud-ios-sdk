import UIKit
import ThinCloud

class InitialViewController: UIViewController {

    static let proceedToApplicationSegueIdentifier = "proceedToApplicationSegueIdentifier"
    static let proceedToSignInSegueIdentifier = "proceedToSignInSegueIdentifier"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if ThinCloud.shared.currentUser != nil {
            return performSegue(withIdentifier: InitialViewController.proceedToApplicationSegueIdentifier, sender: self)
        }

        performSegue(withIdentifier: InitialViewController.proceedToSignInSegueIdentifier, sender: self)
    }

    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
        // No-op
    }
}
