import Foundation

/// ThinCloud SDK Errors.
public enum ThinCloudError: Error {
    /// A call was made to a resource that requires authentication.
    case notAuthenticated
    /// The ThinCloud backend returned an unexpected response.
    case responseError
    /// The ThinCloud backend returned a payload that could not be deserialized from JSON.
    case deserializationError
    /// An unknown error ocurred.
    case unknownError
}
