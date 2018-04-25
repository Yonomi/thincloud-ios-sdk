import UIKit
import ThinCloud

class ClientViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    var client: Client!

    override func viewDidLoad() {
        super.viewDidLoad()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let json = try? encoder.encode(client)

        label.text = String(data: json!, encoding: .utf8)!
    }
}
