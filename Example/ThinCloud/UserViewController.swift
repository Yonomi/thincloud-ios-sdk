import UIKit
import ThinCloud

class UserViewController: UIViewController {

    static let unwindToSignInSegueIdentifier = "unwindToSignInSegueIdentifier"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!

    @IBOutlet weak var signOutButton: UIButton!

    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        user = ThinCloud.shared.currentUser

        nameLabel.text = ""
        emailLabel.text = ""
        idLabel.text = ""
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UserViewController.unwindToSignInSegueIdentifier {
            ThinCloud.shared.signOut()
        }
    }

}
