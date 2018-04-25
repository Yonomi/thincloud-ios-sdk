import UIKit
import ThinCloud
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    var commandHandler: ExampleCommandHandler?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ThinCloud.shared.configure(instance: "your-instance", clientId: "your-client-id", apiKey: "your-api-key")
        ThinCloud.shared.virtualGateway.delegate = ExampleCommandHandler() // SDK consumer should bind a delegate that implements VirtualGatewayDelegate protocol

        // We're only registering for these for our ExampleCommandHandler's notification display
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { _, _ in }

        return true
    }

    // MARK: - Required ThinCloud Virtual Gateway Push Notification Hooks

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ThinCloud.shared.virtualGateway.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ThinCloud.shared.virtualGateway.didFailToRegisterForRemoteNotificationsWithError(error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ThinCloud.shared.virtualGateway.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }

    // MARK: - UNUserNotificationCenter Delegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }

}
