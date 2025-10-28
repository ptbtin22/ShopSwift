//
//  SceneDelegate.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 23/10/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    // MARK: - Scene Lifecycle
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Build dependencies (DI)
        let baseURL = URL(string: "https://api.escuelajs.co/api/v1")!
        let http = URLSessionHTTPClient(baseURL: baseURL)
        let api = URLSessionProductAPI(http: http)
        let repository: ProductRepository = ProductRepositoryImpl(api: api)
        
        // Shared stores
        let favorites = UserDefaultsFavoritesStore()
        let cart = UserDefaultsCartStore()
        
        // Create root navigation controller
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        
        // Initialize AppCoordinator with dependencies
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            repository: repository,
            api: api,
            favorites: favorites,
            cart: cart
        )
        self.appCoordinator = coordinator
        
        // Setup window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        
        // 🔥 Step 5: Start coordinator (this triggers the app flow)
        coordinator.start()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}

// MARK: - Convenience Accessor

extension UIApplication {
    static var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return nil
        }
        return sceneDelegate
    }
    
    /// Quick access to AppCoordinator for navigation
    static var coordinator: AppCoordinator? {
        return sceneDelegate?.appCoordinator
    }
}

