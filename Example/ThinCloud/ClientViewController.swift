import UIKit
import ThinCloud

extension Client: CustomStringConvertible {
    public var description: String {
        return "Client Description"
    }
}

class ClientViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    var client: Client!

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = client.description
    }
}
