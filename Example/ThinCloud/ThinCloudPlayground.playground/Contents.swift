import ThinCloud

let instance = "your-instance"
let clientId = "your-client-id"
let apiKey = "your-api-key"

ThinCloud.shared.configure(instance: instance, clientId: clientId, apiKey: apiKey)

let email = "example@email.com"
let password = "password"

if let currentUser = ThinCloud.shared.currentUser {
    // User sessions are automatically resumed on subsequent runs...
    print(currentUser)

    ThinCloud.shared.getDevices { (error, devices) in
        if let devices = devices {
            devices.forEach { print($0) }
            for device in devices {
                print(device)
            }
        }
    }
} else {
    // ... but you'll need to sign in first otherwise.

    ThinCloud.shared.signIn(email: email, password: password) { (error, user) in
        guard user != nil else { return }
    }
}
