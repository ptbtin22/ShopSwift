//
//  SceneDelegateTests.swift
//  ShoppingAppTests
//
//  Created by Tin Pham on 29/10/25.
//

import XCTest
import GoogleSignIn


final class SceneDelegateTests: XCTest {
    // In SceneDelegate or any ViewController
    func testGoogleCallback() {
        // Simulate what Google would send
        let testURL = URL(string: "com.googleusercontent.apps.1013505634363-otpkhje9g2n0unlh666qucoda0pgr6g8://oauth2redirect/google?code=TEST123&state=abc")!
        
        // This should trigger the same flow
        GIDSignIn.sharedInstance.handle(testURL)
    }
}
