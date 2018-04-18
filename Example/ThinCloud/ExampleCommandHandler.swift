import Foundation
import ThinCloud

/// Example implementation of a VirtualGatewayDelegate.
class ExampleCommandHandler: VirtualGatewayDelegate {

    // MARK: - ThinCloud Virtual Gateway Command Handler

    func virtualGatewayDidReceiveCommand(_ command: DeviceCommand, completionHandler: (Bool) -> Void) {
        //Do Work {
            // work is done
            completionHandler(true)
        //}
    }

    // OR

    func virtualGatewayDidReceiveCommand(_ commands: [DeviceCommand], completionHandler: (_ commandId: String, _ success: Bool) -> Void) {
        for command in commands {
            //Do Work {
            // work is done
                completionHandler(command.commandId, true)
            //}
        }
    }

}
