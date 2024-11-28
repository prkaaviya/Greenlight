//
//  LoginView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Greenlight Login")
                .font(.custom("Soulmeh", size: 30))
                .foregroundColor(Color("PrimaryAccentColor"))
                .fontWeight(.bold)
                .padding()

            TextField("Email", text: $email)
                .font(.custom("MonofontoRegular", size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .font(.custom("MonofontoRegular", size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Button(action: loginUser) {
                Text("Sign In")
                    .font(.custom("MonofontoRegular", size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("PrimaryAccentColor"))
                    .cornerRadius(10)
            }

            NavigationLink(destination: SignUpView()) {
                Text("Don't have an account? Sign Up now.")
                    .font(.custom("MonofontoRegular", size: 16))
                    .foregroundColor(Color("PrimaryAccentColor"))
            }

            Spacer()
        }
        .padding()
        .background(Color("TextColor").edgesIgnoringSafeArea(.all))
    }

    func loginUser() {
        print("DEBUG: isAuthenticated: \(authManager.isAuthenticated)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                DispatchQueue.main.async {
                    authManager.isAuthenticated = true
                    print("DEBUG: Login successful. isAuthenticated:  \(authManager.isAuthenticated)")
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
