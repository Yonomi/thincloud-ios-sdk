import UIKit
import ThinCloud

extension Device: CustomStringConvertible {
    public var description: String {
        return ""
    }
}

class DeviceViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    var device: Device!

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = device.description
    }

}
