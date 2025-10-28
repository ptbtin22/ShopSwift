////
////  LoginViewController.swift
////  ShoppingApp
////
////  Created by Tín Phạm on 27/10/25.
////
//
//import UIKit
//
//class LoginViewController: UIViewController {
//    
//    weak var coordinator: AppCoordinator?
//    
//    private lazy var loginButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Login", for: .normal)
//        button.backgroundColor = .systemPink
//        button.layer.cornerRadius = 12
//        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private var loginLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Welcome to ShopSwift"
//        label.font = .systemFont(ofSize: 28, weight: .bold)
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private var subtitleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Login to continue shopping"
//        label.font = .systemFont(ofSize: 16, weight: .regular)
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        return label
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        config()
//    }
//    
//    private func config() {
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(loginLabel)
//        view.addSubview(subtitleLabel)
//        view.addSubview(loginButton)
//        
//        NSLayoutConstraint.activate([
//            loginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loginLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
//            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            loginLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
//        
//        NSLayoutConstraint.activate([
//            subtitleLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 12),
//            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
//        
//        NSLayoutConstraint.activate([
//            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
//            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            loginButton.heightAnchor.constraint(equalToConstant: 56)
//        ])
//    }
//    
//    @objc private func loginButtonTapped() {
//        // Simulate login (in production, you'd validate credentials here)
//        print("🔐 Login button tapped!")
//        
//        // Notify coordinator that login is complete
//        coordinator?.didFinishLogin()
//    }
//
//}

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the official Google Sign-In button
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.center = view.center
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        view.addSubview(googleSignInButton)
    }

    @objc func googleSignInTapped() {
        // 1. Get the top-most view controller to present the login screen
        guard let presentingViewController = self.view.window?.rootViewController else { return }

        // 2. Start the sign-in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            
            // 3. Handle the result
            guard error == nil else {
                // An error occurred
                print("Error signing in: \(error!.localizedDescription)")
                return
            }

            guard let signInResult = result else {
                // The flow was cancelled by the user
                print("Sign-in cancelled.")
                return
            }

            // If we are here, sign-in was successful!
            let user = signInResult.user
            
            print("Successfully signed in as \(user.profile?.name ?? "User")!")

            // Get user information
            let email = user.profile?.email
            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName
            let profilePicUrl = user.profile?.imageURL(withDimension: 320)

            // IMPORTANT: Get the ID Token to send to your backend server
            if let idToken = user.idToken?.tokenString {
                print("User ID Token: \(idToken)")
                // Send this idToken to your backend server to verify the user
            }
            
            // Now you can navigate to the main part of your app
            // self.showMainAppScreen()
        }
    }
}
