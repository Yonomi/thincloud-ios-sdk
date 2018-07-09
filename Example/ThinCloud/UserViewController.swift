import UIKit
import ThinCloud

class UserViewController: UIViewController {

    static let unwindToSignInSegueIdentifier = "unwindToSignInSegueIdentifier"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!

    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        user = ThinCloud.shared.currentUser

        nameLabel.text = "Name: \(user.name)"
        emailLabel.text = "E-mail: \(user.email)"
        idLabel.text = "userId: \(user.userId)"
    }

    @IBAction func refreshButtonTouched(_ sender: UIButton) {
        sender.isEnabled = false

        ThinCloud.shared.getUser { (error, user) in
            sender.isEnabled = true

            if let error = error {
                return self.presentError(title: "Error Refreshing User", description: error.localizedDescription)
            }

            self.user = user
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UserViewController.unwindToSignInSegueIdentifier {
            ThinCloud.shared.signOut()
        }
    }

}
