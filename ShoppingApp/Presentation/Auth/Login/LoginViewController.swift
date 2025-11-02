//
//  LoginViewController.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 27/10/25.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController {
    
    weak var coordinator: AppCoordinator?
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository = FirestoreUserRepository()) {
        self.userRepository = userRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to ShopSwift"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign in to continue shopping"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(googleSignInButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Google Sign-In Button
            googleSignInButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 20)
        ])
    }

    // MARK: - Google Sign-In
    
    @objc private func googleSignInTapped() {
        print("🔵 Google Sign-In button tapped")
        
        // Show loading indicator
        activityIndicator.startAnimating()
        googleSignInButton.isEnabled = false
        
        // Use self as the presenting view controller (correct approach)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            
            // Stop loading
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.googleSignInButton.isEnabled = true
            }
            
            // Handle errors
            if let error = error {
                print("[LOG] Google Sign-In error: \(error.localizedDescription)")
                self.showAlert(title: "Sign-In Failed", message: error.localizedDescription)
                return
            }
            
            // Check if we have a result
            guard let signInResult = result,
                  let idToken = signInResult.user.idToken?.tokenString else {
                print("[LOG] Failed to get ID token")
                return
            }
            
            print("[LOG] User has image: \(String(describing: signInResult.user.profile?.hasImage))")
            
            do {
                try KeychainHelper.shared.save(key: "googleIDToken", string: idToken)
                print("[LOG] Saved ID token to Keychain")
            } catch {
                print("[LOG] Failed to save token: \(error)")
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    // Print full error details for debugging
                    print("❌ Firebase Auth Error:")
                    print("   Description: \(error.localizedDescription)")
                    print("   Error: \(error)")
                    if let nsError = error as NSError? {
                        print("   Domain: \(nsError.domain)")
                        print("   Code: \(nsError.code)")
                        print("   UserInfo: \(nsError.userInfo)")
                    }
                    
                    self.showAlert(
                        title: "Authentication Failed",
                        message: "Please make sure Google Sign-In is enabled in Firebase Console.\n\nError: \(error.localizedDescription)"
                    )
                    return
                }
                
                guard let firebaseUser = authResult?.user else { return }
                
                let user = User(
                    uid: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName,
                    photoURL: firebaseUser.photoURL,
                    createdAt: Date()
                )
                
                Task {
                    do {
                        try await self.userRepository.saveUser(user)
                        print("[LOG] User saved to Firestore")
                        
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(user.email, forKey: "userEmail")
                        UserDefaults.standard.set(user.displayName, forKey: "userName")
                        
                        await MainActor.run {
                            self.coordinator?.didFinishLogin()
                        }
                    } catch {
                        print("[LOG] Failed to save user: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
