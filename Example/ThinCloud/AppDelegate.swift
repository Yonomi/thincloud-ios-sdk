import UIKit
import ThinCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var commandHandler: ExampleCommandHandler?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ThinCloud.shared.configure(instance: "your-instance-id-here", clientId: "client-id-here")
        ThinCloud.shared.virtualGateway.delegate = ExampleCommandHandler() // SDK consumer should bind a delegate that implements VirtualGatewayDelegate protocol

        return true
    }

    // MARK: - ThinCloud Virtual Gateway Push Notification Hooks

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ThinCloud.shared.virtualGateway.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ThinCloud.shared.virtualGateway.didFailToRegisterForRemoteNotificationsWithError(error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ThinCloud.shared.virtualGateway.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }

}
