//
//  AppDelegate.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupServices()
        return true
    }
    
    func setupServices() {
        let apiClient = ApiClient()
        ServiceLocator.register(singleton: apiClient)
        ServiceLocator.register(singleton: apiClient as ProjectsApi)
        ServiceLocator.register(singleton: apiClient as UserApi)
        
        ServiceLocator.register(singleton: ProjectsDataSource())
    }
}
