//
//  SignUpView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Create an Account")
                .font(.custom("Soulmeh", size: 30))
                .foregroundColor(Color("PrimaryAccentColor"))
                .fontWeight(.bold)
                .padding()

            TextField("Name", text: $name)
                .font(.custom("MonofontoRegular", size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Email", text: $email)
                .font(.custom("MonofontoRegular", size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .font(.custom("MonofontoRegular", size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Confirm Password", text: $confirmPassword)
                .font(.custom("MonofontoRegular", size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Button(action: signUpUser) {
                Text("Sign Up")
                    .font(.custom("MonofontoRegular", size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("PrimaryAccentColor"))
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .background(Color("TextColor").edgesIgnoringSafeArea(.all))
    }

    func signUpUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        authManager.signUp(email: email, password: password, name: name) { error in
            if let error = error {
                self.errorMessage = error
            }
        }
    }
}

#Preview {
    SignUpView()
}
