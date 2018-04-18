import Foundation
import Alamofire

protocol OAuth2TokenDelegate: class {
    func didUpdateAccessToken(_ accessToken: String)
    func didUpdateRefreshToken(_ refreshToken: String)
}

class OAuth2Handler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void

    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders

        return SessionManager(configuration: configuration)
    }()

    private var delegate: OAuth2TokenDelegate?

    private let lock = NSLock()

    private var clientID: String
    private var baseURLString: String
    private var accessToken: String {
        didSet {
            delegate?.didUpdateAccessToken(accessToken)
        }
    }
    private var refreshToken: String {
        didSet {
            delegate?.didUpdateRefreshToken(refreshToken)
        }
    }

    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []

    // MARK: - Initialization

    public init(clientID: String, baseURLString: String, accessToken: String, refreshToken: String, delegate: OAuth2TokenDelegate) {
        self.clientID = clientID
        self.baseURLString = baseURLString
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.delegate = delegate
    }

    // MARK: - RequestAdapter

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest

        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")

        return urlRequest
    }

    // MARK: - RequestRetrier

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }

        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)

            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }

                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }

                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }

                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }

    // MARK: - Private - Refresh Tokens

    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }

        isRefreshing = true

        let urlString = "\(baseURLString)/oauth2/token"

        let parameters = [
            "access_token": accessToken,
            "refresh_token": refreshToken,
            "client_id": clientID,
            "grant_type": "refresh_token"
        ]

        sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .response { [weak self] response in
                guard let strongSelf = self else { return }

                guard let data = response.data else { return completion(false, nil, nil) }

                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

                if let oauthResponse = try? jsonDecoder.decode(OAuth2Response.self, from: data) {
                    completion(true, oauthResponse.accessToken, oauthResponse.refreshToken)
                } else {
                    completion(false, nil, nil)
                }

                strongSelf.isRefreshing = false
        }
    }
}
