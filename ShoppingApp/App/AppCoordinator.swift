//
//  AppCoordinator.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 27/10/25.
//

import UIKit
import GoogleSignIn

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

class AppCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // Dependencies
    private let repository: ProductRepository
    private let api: ProductAPI
    private let favorites: FavoritesStore
    private let cart: CartStore

    init(
        navigationController: UINavigationController,
        repository: ProductRepository,
        api: ProductAPI,
        favorites: FavoritesStore,
        cart: CartStore
    ) {
        self.navigationController = navigationController
        self.repository = repository
        self.api = api
        self.favorites = favorites
        self.cart = cart
    }

    func start() {
        // Start with login screen
        if (Auth.auth().currentUser != nil) {
            showMainApp()
        } else {
            showLogin()
        }
    }

    func showLogin() {
        let loginVC = LoginViewController()
        loginVC.coordinator = self
        navigationController.pushViewController(loginVC, animated: false)
    }

    func didFinishLogin() {
        // User successfully logged in, show main app
        showMainApp()
    }
    
    func logout() {
        print("🚪 Logging out...")
        
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        print("✅ Signed out from Google")
        
        // Clear user data from UserDefaults
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        
        // Get the window from SceneDelegate (reliable)
        guard let window = UIApplication.sceneDelegate?.window else {
            print("❌ Failed to get window")
            return
        }
        
        // Recreate navigation controller and show login
        let navigationController = UINavigationController()
        self.navigationController = navigationController
        
        // Replace window root with new navigation controller
        window.rootViewController = navigationController
        
        // Animate the transition
        UIView.transition(with: window,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: nil)
        
        // Show login screen
        print("✅ Showing login screen")
        showLogin()
    }

    func showMainApp() {
        // Create tab bar with home and favorites
        let tabBarController = createTabBar()
        
        // Replace the entire window root (removes navigation controller wrapping)
        // This prevents the large title padding issue
        if let window = navigationController.view.window {
            window.rootViewController = tabBarController
            
            // Animate the transition
            UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: nil)
        }
    }
    
    // MARK: - Tab Bar Setup
    
    private func createTabBar() -> UITabBarController {
        let tabbar = UITabBarController()
        
        // Appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        appearance.stackedLayoutAppearance.selected.iconColor = .systemPink
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemPink
        ]
        
        tabbar.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabbar.tabBar.scrollEdgeAppearance = appearance
        }
        tabbar.tabBar.tintColor = .systemPink
        
        // Create tabs
        let home = createMainTab()
        let favoritesTab = createFavoritesTab()
        
        tabbar.viewControllers = [home, favoritesTab]
        
        return tabbar
    }
    
    private func createMainTab() -> UINavigationController {
        let mainVC = MainViewController(productRepository: repository)
        mainVC.coordinator = self // Inject coordinator
        mainVC.title = "Home"
        
        let homeImage = UIImage(systemName: "house")
        let homeSelectedImage = UIImage(systemName: "house.fill")
        mainVC.tabBarItem = UITabBarItem(title: "Home", image: homeImage, selectedImage: homeSelectedImage)
        
        let nav = UINavigationController(rootViewController: mainVC)
        return nav
    }
    
    private func createFavoritesTab() -> UINavigationController {
        let favoritesVC = FavoritesViewController(api: api)
        favoritesVC.coordinator = self // Inject coordinator
        favoritesVC.title = "Favorites"
        
        let favoritesImage = UIImage(systemName: "heart")
        let favoritesSelectedImage = UIImage(systemName: "heart.fill")
        favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: favoritesImage, selectedImage: favoritesSelectedImage)
        
        let nav = UINavigationController(rootViewController: favoritesVC)
        return nav
    }
    
    // MARK: - Navigation (shared across the app)
    
    @MainActor
    func showProductDetails(_ product: Product, from viewController: UIViewController) {
        let viewModel = ProductDetailsViewModel(
            product: product,
            favorites: favorites,
            cartStore: cart
        )
        let detailsVC = ProductDetailsViewController(viewModel: viewModel)
        
        if let nav = viewController.navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else {
            viewController.present(detailsVC, animated: true)
        }
    }
    
    func showCart(from viewController: UIViewController) {
        // Pass the cart store to CartViewController
        let cartVC = CartViewController(cartStore: cart)
        
        if let nav = viewController.navigationController {
            nav.pushViewController(cartVC, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: cartVC)
            viewController.present(navController, animated: true)
        }
    }
}

