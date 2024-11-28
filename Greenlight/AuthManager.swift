//
//  AuthManager.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userName: String? = nil // Store user's name
    
    init() {
        self.isAuthenticated = Auth.auth().currentUser != nil
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self?.isAuthenticated = true
                    self?.fetchUserName() // Fetch name after login
                    print("DEBUG: User logged in")
                }
                completion(nil)
            }
        }
    }

    func signUp(email: String, password: String, name: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error.localizedDescription)
            } else if let user = Auth.auth().currentUser {
                DispatchQueue.main.async {
                    self?.isAuthenticated = true
                    self?.userName = name // Save name locally
                    self?.saveUserName(userID: user.uid, name: name) // Save name in database
                    print("DEBUG: User signed up")
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
                self.userName = nil
            }
            print("DEBUG: User logged out")
        } catch {
            print("ERROR: Logout failed: \(error.localizedDescription)")
        }
    }

    private func saveUserName(userID: String, name: String) {
        let ref = Database.database().reference()
        ref.child("users").child(userID).setValue(["name": name]) { error, _ in
            if let error = error {
                print("Error saving user name: \(error.localizedDescription)")
            }
        }
    }

    private func fetchUserName() {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No authenticated user found.")
            return
        }
        let ref = Database.database().reference()
        ref.child("users").child(user.uid).observeSingleEvent(of: .value) { [weak self] snapshot in
            if let data = snapshot.value as? [String: Any], let name = data["name"] as? String {
                DispatchQueue.main.async {
                    self?.userName = name
                    print("DEBUG: User name fetched - \(name)")
                }
            } else {
                print("ERROR: Failed to fetch user name: No data found")
            }
        }
    }
}
