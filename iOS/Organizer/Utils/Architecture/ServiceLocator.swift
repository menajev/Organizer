//
//  ServiceLocator.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import Foundation

class ServiceLocator {
    
    private static let instance = ServiceLocator()
    private var services = [ObjectIdentifier: Any]()
    
    static func inject<T>() -> T {
        return instance.inject()
    }
    
    static func register<T>(singleton: T) {
        instance.register(singleton: singleton)
    }
    
    static func register<T>(factory: @escaping () -> T) {
        instance.register(factory: factory)
    }
    
    private init() {}
    
    private func inject<T>() -> T {
        let service = services[ObjectIdentifier(T.self)]
        
        if let singleton = service as? T {
            return singleton
        } else if let factory = service as? () -> T {
            return factory()
        } else {
            fatalError("Could not inject unregistered service: \(T.self)")
        }
    }
    
    private func register<T>(factory: @escaping () -> T) {
        services[ObjectIdentifier(T.self)] = factory
    }
    
    private func register<T>(singleton: T) {
        services[ObjectIdentifier(T.self)] = singleton
    }
}
