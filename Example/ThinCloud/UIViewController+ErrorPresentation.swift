import UIKit

extension UIViewController {
    func presentError(title: String, description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}
