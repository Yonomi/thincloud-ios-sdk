// Copyright 2018 Yonomi, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    /// A call was made to an account that is not verified.
    case accountNotVerified(String)
    /// A call was made to an account that already exists.
    case accountAlreadyExists
}
