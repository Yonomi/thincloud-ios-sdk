import UIKit
import ThinCloud

class ClientsTableViewController: UITableViewController {

    static let cellIdentifier = "clientCellIdentifier"
    static let clientDetailSegueIdentifier = "clientDetailSegueIdentifier"

    var clients = [Client]() {
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
        ThinCloud.shared.getClients { (error, clients) in
            sender.endRefreshing()

            if let error = error {
                return self.presentError(title: "Error Loading Clients", description: error.localizedDescription)
            }

            if let clients = clients {
                self.clients = clients
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return clients.count > 0 ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCellIdentifier", for: indexPath)
        cell.textLabel?.text = "Client Name"
        cell.detailTextLabel?.text = "Client Identifier"

        let client = clients[indexPath.row]
        cell.textLabel?.text = client.clientId
        cell.detailTextLabel?.text = client.installId

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ClientsTableViewController.clientDetailSegueIdentifier {
            guard let destination = segue.destination as? ClientViewController,
                let sender = sender as? UITableViewCell else {
                    return
            }

            let indexPath = tableView.indexPath(for: sender)!
            destination.client = clients[indexPath.row]
        }
    }

}
