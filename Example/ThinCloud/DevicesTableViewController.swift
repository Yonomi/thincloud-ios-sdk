import UIKit
import ThinCloud

class DevicesTableViewController: UITableViewController {

    static let cellIdentifier = "deviceCellIdentifier"
    static let deviceDetailSegueIdentifier = "deviceDetailSegueIdentifier"

    var devices = [Device]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.beginRefreshing()
        refreshControl?.sendActions(for: .valueChanged)
    }

    @IBAction func refreshControlValueChanged(_ sender: UIRefreshControl) {
        ThinCloud.shared.getDevices { (error, devices) in
            sender.endRefreshing()

            if let error = error {
                return self.presentError(title: "Error Loading Devices", description: error.localizedDescription)
            }

            if let devices = devices {
                self.devices = devices
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return devices.count > 0 ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DevicesTableViewController.cellIdentifier, for: indexPath)
        cell.textLabel?.text = "Device Name"
        cell.detailTextLabel?.text = "Device Identifier"

        let device = devices[indexPath.row]

        cell.textLabel?.text = "\(device.physicalId) (\(device.devicetypeId))"
        cell.detailTextLabel?.text = device.deviceId

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DevicesTableViewController.deviceDetailSegueIdentifier {
            guard let destination = segue.destination as? DeviceViewController,
                let sender = sender as? UITableViewCell else {
                    return
            }

            let indexPath = tableView.indexPath(for: sender)!
            destination.device = devices[indexPath.row]
        }
    }
}
