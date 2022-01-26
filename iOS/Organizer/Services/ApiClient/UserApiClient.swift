//
//  UserApiClient.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-25.
//

import Foundation
import Combine
import Alamofire

protocol UserApi {
    var isLoggedIn: Published<Bool>.Publisher { get }
    
    func login(loginRequest: LoginRequest, serverUrl: String) -> Future<Void, Error>
    func logout()
}

extension ApiClient: UserApi {
    static private let loginEndpoint = "/login.php"
    static private let logoutEndpoint = "/login.php"
    
    var isLoggedIn: Published<Bool>.Publisher { $hasToken }
    
    func login(loginRequest: LoginRequest, serverUrl: String) -> Future<Void, Error> {
        basePath = serverUrl
        return Future<Void, Error> { [weak self] promise in
            self?.request(ApiClient.loginEndpoint,
                          method: .post,
                          parameters: loginRequest,
                          encoder: JSONParameterEncoder.default)
                .decode(type: LoginResponse.self, decoder: JSONDecoder())
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: promise(.success(()))
                    case .failure(let error): promise(.failure(error))
                    }
                }, receiveValue: { response in
                    self?.save(token: response.token)
                }).store(in: &self!.bag)
        }
    }
    
    func logout() {
        request(ApiClient.logoutEndpoint, method: .get, parameters: LogoutRequest(), encoder: URLEncodedFormParameterEncoder.default)
            .decode(type: [String: String].self, decoder: JSONDecoder()).sink(receiveCompletion: { _ in}, receiveValue: { _ in })
            .store(in: &bag)
        save(token: nil)
    }
}
