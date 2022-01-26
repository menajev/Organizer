//
//  ApiClient.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-24.
//

import Foundation
import Combine
import Alamofire
import SwiftKeychainWrapper

class ApiClient {
    // TODO: Clean & order
    // TODO: Handle expired token
    @Published private(set) var hasToken: Bool
    
    internal var bag = Set<AnyCancellable>()
    internal let emptyParams: EmptyEncodable? = nil
    
    var basePath: String?
    private var token: String?
    
    private let basePathKey = "BasePath"
    private let tokenKey = "Token"
    
    init() {
        basePath = KeychainWrapper.standard.string(forKey: basePathKey)
        token = KeychainWrapper.standard.string(forKey: tokenKey)
        hasToken = token != nil
    }
    
    func save(token: String?) {
        self.token = token
        hasToken = token != nil
        
        if let basePath = basePath {
            KeychainWrapper.standard.set(basePath, forKey: basePathKey)
        } else {
            KeychainWrapper.standard.removeObject(forKey: basePathKey)
        }
        if let token = token {
            KeychainWrapper.standard.set(token, forKey: tokenKey)
        } else {
            KeychainWrapper.standard.removeObject(forKey: tokenKey)
        }
    }
    
    func request<Parameters: Encodable>(_ endpoint: String,
                                        method: HTTPMethod,
                                        parameters: Parameters?,
                                        encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                        headers: HTTPHeaders? = nil) -> Future<Data, Error> {
        var headers = headers ?? HTTPHeaders()
        if let token = token {
            headers.add(.authorization(bearerToken: token))
        }
        
        return Future<Data, Error> { [weak self] promise in
            guard let basePath = self?.basePath else {
                promise(.failure(ApiError.noBaseUrl))
                return
            }
            let url = basePath + endpoint
            // TODO: RequestInterceptor
            let request = AF.request(url, method: method, parameters: parameters, encoder: encoder, headers: headers)
            request.validate().responseData { [weak self] response in
                switch response.result {
                case .success(let data):
#if DEBUG
                    let preview = String(data: data, encoding: .utf8)
#endif
                    promise(.success(data))                    
                case .failure(let error):
                    let retError = self?.parseError(response, code: error.responseCode ?? -1) ?? error
                    promise(.failure(retError))
                }
            }
        }
    }
    
    func parseError(_ response: AFDataResponse<Data>, code: Int) -> Error? {
        if let data = response.data {
            if let errorMessage = try? JSONDecoder().decode(ErrorMessage.self, from: data), let msg = errorMessage.error  {
                return ApiError.message(mesage: msg, errorCode: code)
            }
        }
        return nil
    }
}
