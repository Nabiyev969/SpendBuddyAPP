//
//  AuthService.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 07.10.25.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

protocol AuthService {
    var currentUserId: String? { get }
    
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func authWithGoogle(presenting: UIViewController) async throws
    func authWithApple(presenting: UIViewController) async throws
}

final class FirebaseAuthService: AuthService {
    
    var currentUserId: String? { Auth.auth().currentUser?.uid }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func authWithGoogle(presenting: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing Google clientID"])
            }

            GIDSignIn.sharedInstance.configuration = .init(clientID: clientID)

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)

            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Auth", code: 2, userInfo: [NSLocalizedDescriptionKey: "No Google ID token"])
            }
            let accessToken = result.user.accessToken.tokenString

            _ = try await Auth.auth().signIn(with: GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken))
    }
    
    func authWithApple(presenting: UIViewController) async throws {
                let nonce = Self.randomNonce()
                let hashed = Self.sha256(nonce)

                // 2) Запрос Apple
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email]
                request.nonce = hashed

                // 3) Проксируем делегаты в async через continuation
                let proxy = AppleSignInProxy(presenting: presenting)
                let credential = try await proxy.perform(request: request) // ждём результат/ошибку

                // 4) Готовим credential для Firebase
                guard let tokenData = credential.identityToken,
                      let idToken = String(data: tokenData, encoding: .utf8) else {
                    throw NSError(domain: "Auth", code: 2001,
                                  userInfo: [NSLocalizedDescriptionKey: "No Apple identity token"])
                }

                let firebaseCred = OAuthProvider.appleCredential(
                    withIDToken: idToken,
                    rawNonce: nonce,
                    fullName: credential.fullName // может быть nil (при повторных входах)
                )

                // 5) Firebase sign-in
                _ = try await Auth.auth().signIn(with: firebaseCred)
    }
    
    private static func randomNonce(length: Int = 32) -> String {
            precondition(length > 0)
            let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
            var result = ""
            var remainingLength = length

            while remainingLength > 0 {
                var random: UInt8 = 0
                let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if status != errSecSuccess { fatalError("Unable to generate nonce") }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
            return result
        }

        private static func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashed = SHA256.hash(data: inputData)
            return hashed.map { String(format: "%02x", $0) }.joined()
        }
}

private final class AppleSignInProxy: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private weak var presenting: UIViewController?
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    init(presenting: UIViewController) { self.presenting = presenting }

    func perform(request: ASAuthorizationAppleIDRequest) async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>) in
            self.continuation = cont
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presenting?.view.window ?? ASPresentationAnchor()
    }

    // ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: NSError(domain: "Auth", code: 2000,
                                                   userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"]))
            continuation = nil
            return
        }
        continuation?.resume(returning: cred)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
