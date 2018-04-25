import UIKit
import ThinCloud

class DeviceViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    var device: Device!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = device.physicalId

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let json = try? encoder.encode(device)

        label.text = String(data: json!, encoding: .utf8)!
    }

}
