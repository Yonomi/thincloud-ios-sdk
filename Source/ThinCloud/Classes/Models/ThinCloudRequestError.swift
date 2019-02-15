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

/// An request error returned from ThinCloud.
public struct ThinCloudRequestError: Error, LocalizedError, Codable {
    /// The HTTP status code.
    let statusCode: Int
    /// The message returned with the error response.
    let message: String

    public var errorDescription: String? {
        return message
    }
}