//
//  AuthManager.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        // Check if user is already signed in
        self.isAuthenticated = Auth.auth().currentUser != nil
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self?.isAuthenticated = true
                }
                completion(nil)
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self?.isAuthenticated = true
                }
                completion(nil)
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}
