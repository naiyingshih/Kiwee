//
//  AuthenticationViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/5/2.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

//class AuthenticationViewModel {
//    
//    var user: User?
//    private var currentNonce: String?
//    
//    init() {
//        registerAuthStateHandler()
//    }
//    
//    private var authStateHandler: AuthStateDidChangeListenerHandle?
//    
//    func registerAuthStateHandler() {
//      if authStateHandler == nil {
//        authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
//          self.user = user
//        }
//      }
//    }
//    
//    func signOut() {
//        do {
//            try Auth.auth().signOut()
//        }
//        catch {
//            print(error.localizedDescription)
//        }
//    }
//    
//    func deleteAccount() async -> Bool {
//        guard let user = user else { return false }
//        guard let lastSignInDate = user.metadata.lastSignInDate else { return false }
//        let needsReauth = !lastSignInDate.isWithinPast(minutes: 5)
//        
//        let needsTokenRevocation = user.providerData.contains(where: { $0.providerID == "apple.com" })
//        
//        do {
//            if needsReauth || needsTokenRevocation {
//                let signInWithApple = SignInWithAppleMate()
//                let appleIDCredential = try await signInWithApple()
//                
//                guard let appleIDToken = appleIDCredential.identityToken else {
//                    print("Unable to fetdch identify token.")
//                    return false
//                }
//                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
//                    return false
//                }
//                
//                let nonce = randomNonceString()
//                let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                          idToken: idTokenString,
//                                                          rawNonce: nonce)
//                
//                if needsReauth {
//                    try await user.reauthenticate(with: credential)
//                }
//                if needsTokenRevocation {
//                    guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
//                    guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }
//                    
//                    try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
//                }
//            }
//            
//            try await user.delete()
//            return true
//        }
//        catch {
//            print(error.localizedDescription)
//            return false
//        }
//    }
//    
//}
//
//class TokenRevocationHelper: NSObject, ASAuthorizationControllerDelegate {
//    
//    private var continuation : CheckedContinuation<Void, Error>?
//    
//    func revokeToken() async throws {
//        try await withCheckedThrowingContinuation { continuation in
//            self.continuation = continuation
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            let request = appleIDProvider.createRequest()
//            request.requestedScopes = [.fullName, .email]
//            
//            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//            authorizationController.delegate = self
//            authorizationController.performRequests()
//        }
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
//            guard let authorizationCode = appleIDCredential.authorizationCode else { return }
//            guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return }
//            
//            Task {
//                try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
//                continuation?.resume()
//            }
//        }
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        continuation?.resume(throwing: error)
//    }
//}
//
//
//extension Date {
//    func isWithinPast(minutes: Int) -> Bool {
//        let now = Date.now
//        let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
//        let range = timeAgo...now
//        return range.contains(self)
//    }
//}
//
//
//// MARK: - Sign in with Apple
//
//class SignInWithAppleMate: NSObject, ASAuthorizationControllerDelegate {
//    
//    private var continuation : CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
//    
//    func callAsFunction() async throws -> ASAuthorizationAppleIDCredential {
//        return try await withCheckedThrowingContinuation { continuation in
//            self.continuation = continuation
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            let request = appleIDProvider.createRequest()
//            request.requestedScopes = [.fullName, .email]
//            
//            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//            authorizationController.delegate = self
//            authorizationController.performRequests()
//        }
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
//            continuation?.resume(returning: appleIDCredential)
//        }
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        continuation?.resume(throwing: error)
//    }
//    
//}
//
//// MARK: - Extension: handle sign in
//
//extension AuthenticationViewModel {
//    
//    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
//        request.requestedScopes = [.fullName, .email]
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        request.nonce = sha256(nonce)
//    }
//    
//    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
//        if case .failure(let failure) = result {
//            print(failure.localizedDescription)
//        }
//        else if case .success(let authorization) = result {
//            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//                guard let nonce = currentNonce else {
//                    fatalError("Invalid state: a login callback was received, but no login request was sent.")
//                }
//                guard let appleIDToken = appleIDCredential.identityToken else {
//                    print("Unable to fetdch identify token.")
//                    return
//                }
//                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
//                    return
//                }
//                
//                let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                          idToken: idTokenString,
//                                                          rawNonce: nonce)
//                Task {
//                    do {
//                        let result = try await Auth.auth().signIn(with: credential)
//                        self.checkAppleIDCredentialState(userID: user?.uid ?? "")
//                        print("log in successfully")
//                        //            await updateDisplayName(for: result.user, with: appleIDCredential)
//                    }
//                    catch {
//                        print("Error authenticating: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
//    
//    func checkAppleIDCredentialState(userID: String) {
//        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { credentialState, error in
//            switch credentialState {
//            case .authorized:
//                print("使用者已授權")
//            case .revoked:
//                print("使用者憑證已被註銷")
//            case .notFound:
//                print("使用者尚未使用過 Apple ID 登入")
//            case .transferred:
//                print("請與開發者團隊進行聯繫，以利進行使用者遷移")
//            default:
//                break
//            }
//        }
//    }
//}
//
//
//private func randomNonceString(length: Int = 32) -> String {
//    precondition(length > 0)
//    let charset: [Character] =
//    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//    var result = ""
//    var remainingLength = length
//    
//    while remainingLength > 0 {
//        let randoms: [UInt8] = (0 ..< 16).map { _ in
//            var random: UInt8 = 0
//            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
//            if errorCode != errSecSuccess {
//                fatalError(
//                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
//                )
//            }
//            return random
//        }
//        
//        randoms.forEach { random in
//            if remainingLength == 0 {
//                return
//            }
//            
//            if random < charset.count {
//                result.append(charset[Int(random)])
//                remainingLength -= 1
//            }
//        }
//    }
//    
//    return result
//}
//
//private func sha256(_ input: String) -> String {
//    let inputData = Data(input.utf8)
//    let hashedData = SHA256.hash(data: inputData)
//    let hashString = hashedData.compactMap {
//        String(format: "%02x", $0)
//    }.joined()
//    
//    return hashString
//}
