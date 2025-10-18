//
//  AuthViewModel.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 07.10.25.
//

import Foundation
import UIKit

final class AuthViewModel {
    private let auth: AuthService
    
    var onAuthSuccess: (() -> ())?
    var onRegisterSuccess: (() -> ())?
    
    @MainActor var isLoading = false
    @MainActor var errorMessage: String?
    
    init(auth: AuthService) { self.auth = auth }
    
    @MainActor
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do { try await self.auth.signIn(email: email, password: password)
                self.onAuthSuccess?()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    @MainActor
    func register(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do { try await self.auth.signUp(email: email, password: password)
                self.onRegisterSuccess?()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    @MainActor
    func loginWithGoogle(presenting: UIViewController) {
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.auth.authWithGoogle(presenting: presenting)
                await MainActor.run {
                    self.isLoading = false
                    self.onAuthSuccess?()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @MainActor
    func loginWithApple(presenting: UIViewController) {
        guard !isLoading else { return }
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.auth.authWithApple(presenting: presenting)
                await MainActor.run {
                    self.isLoading = false
                    self.onAuthSuccess?()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print(error.localizedDescription)
                }
            }
        }
    }
}
