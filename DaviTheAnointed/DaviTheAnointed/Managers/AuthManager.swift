import Foundation
import UIKit
import AuthenticationServices
import CryptoKit
import Security

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

struct AuthenticatedUser {
    let userId: String
    let displayName: String
}

enum AuthError: Error, LocalizedError {
    case missingFirebaseConfiguration
    case missingGoogleClientId
    case missingGoogleSDK
    case missingFirebaseAuthSDK
    case missingPresenter
    case cancelled
    case appleResponseTimedOut
    case appleAccountAuthenticationFailed
    case accountDeletionNeedsRecentLogin
    case unknown

    var errorDescription: String? {
        switch self {
        case .missingFirebaseConfiguration:
            return "Firebase ainda não foi configurado. Adicione GoogleService-Info.plist e FirebaseApp.configure()."
        case .missingGoogleClientId:
            return "CLIENT_ID do Google não encontrado no GoogleService-Info.plist."
        case .missingGoogleSDK:
            return "GoogleSignIn-iOS ainda não foi adicionado ao projeto."
        case .missingFirebaseAuthSDK:
            return "FirebaseAuth ainda não foi adicionado ao projeto."
        case .missingPresenter:
            return "Não foi possível encontrar uma tela para apresentar o login."
        case .cancelled:
            return "Login cancelado."
        case .appleResponseTimedOut:
            return "A Apple não concluiu o login. Confira a senha da Conta Apple nos Ajustes do simulador ou teste em um iPhone real."
        case .appleAccountAuthenticationFailed:
            return "A Conta Apple do simulador não autenticou. Saia e entre novamente nos Ajustes do simulador ou teste em um iPhone real."
        case .accountDeletionNeedsRecentLogin:
            return "Entre novamente na conta e tente excluir de novo. A Apple/Firebase exige login recente para apagar a conta."
        case .unknown:
            return "Erro inesperado no login."
        }
    }
}

final class AuthManager: NSObject {
    static let shared = AuthManager()

    private let localAppleUserIdKey = "auth.local_apple.user_id"
    private let localAppleDisplayNameKey = "auth.local_apple.display_name"
    private let localAppleFallbackIdKey = "auth.local_apple.fallback_id"

    private var currentNonce: String?
    private var appleCompletion: ((Result<AuthenticatedUser, Error>) -> Void)?
    private weak var applePresenter: UIViewController?
    private var appleController: ASAuthorizationController?
    private var appleTimeoutWorkItem: DispatchWorkItem?

    private override init() {}

    var currentUser: AuthenticatedUser? {
        #if canImport(FirebaseAuth)
        if let user = Auth.auth().currentUser {
            return AuthenticatedUser(
                userId: user.uid,
                displayName: user.displayName ?? user.email ?? "Jogador"
            )
        }
        #endif
        if let localAppleUser {
            return localAppleUser
        }
        if let player = GameManager.shared.playerData {
            return AuthenticatedUser(userId: player.userId, displayName: player.displayName)
        }
        return nil
    }

    var currentCloudUser: AuthenticatedUser? {
        #if canImport(FirebaseAuth)
        if let user = Auth.auth().currentUser {
            return AuthenticatedUser(
                userId: user.uid,
                displayName: user.displayName ?? user.email ?? "Jogador"
            )
        }
        #endif
        return nil
    }

    var isCloudAuthAvailable: Bool {
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(GoogleSignIn)
        return FirebaseApp.app() != nil
        #else
        return false
        #endif
    }

    func signInWithGoogle(presenting viewController: UIViewController?, completion: @escaping (Result<AuthenticatedUser, Error>) -> Void) {
        #if canImport(FirebaseCore) && canImport(FirebaseAuth) && canImport(GoogleSignIn)
        guard FirebaseApp.app() != nil else {
            completion(.failure(AuthError.missingFirebaseConfiguration))
            return
        }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.missingGoogleClientId))
            return
        }
        guard let presenter = viewController else {
            completion(.failure(AuthError.missingPresenter))
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                completion(.failure(AuthError.unknown))
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(AuthError.unknown))
                    return
                }
                completion(.success(AuthenticatedUser(
                    userId: firebaseUser.uid,
                    displayName: firebaseUser.displayName ?? firebaseUser.email ?? "Jogador"
                )))
            }
        }
        #else
        completion(.failure(AuthError.missingGoogleSDK))
        #endif
    }

    func signInWithApple(presenting viewController: UIViewController?, completion: @escaping (Result<AuthenticatedUser, Error>) -> Void) {
        #if canImport(FirebaseCore) && canImport(FirebaseAuth)
        guard FirebaseApp.app() != nil else {
            completion(.failure(AuthError.missingFirebaseConfiguration))
            return
        }
        guard let presenter = viewController else {
            completion(.failure(AuthError.missingPresenter))
            return
        }

        let nonce = randomNonceString()
        currentNonce = nonce
        appleCompletion = completion
        applePresenter = presenter
        appleTimeoutWorkItem?.cancel()

        let timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self, self.currentNonce == nonce, self.appleCompletion != nil else { return }
            #if DEBUG
            print("[AUTH] Apple Sign In timed out waiting for callback")
            #endif
            self.applePresenter?.presentedViewController?.dismiss(animated: true)
            self.finishFallbackAppleSignIn()
        }
        appleTimeoutWorkItem = timeoutWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWorkItem)

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        appleController = ASAuthorizationController(authorizationRequests: [request])
        appleController?.delegate = self
        appleController?.presentationContextProvider = self
        #if DEBUG
        print("[AUTH] Starting Apple Sign In request")
        #endif
        appleController?.performRequests()
        #else
        completion(.failure(AuthError.missingFirebaseAuthSDK))
        #endif
    }

    func handleOpenURL(_ url: URL) -> Bool {
        #if canImport(GoogleSignIn)
        return GIDSignIn.sharedInstance.handle(url)
        #else
        return false
        #endif
    }

    func signOut() {
        #if canImport(FirebaseAuth)
        try? Auth.auth().signOut()
        #endif
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
        clearLocalAppleSession()
        GameManager.shared.playerData = nil
    }

    func deleteCurrentAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUser?.userId else {
            completion(.success(()))
            return
        }

        #if canImport(FirebaseAuth)
        guard Auth.auth().currentUser != nil else {
            deleteLocalAccount(userId: userId)
            completion(.success(()))
            return
        }
        #else
        deleteLocalAccount(userId: userId)
        completion(.success(()))
        return
        #endif

        CloudGameService.shared.deletePlayer(userId: userId) { result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "player_data_\(userId)")
                #if canImport(FirebaseAuth)
                if let user = Auth.auth().currentUser {
                    user.delete { error in
                        if let error {
                            completion(.failure(self.accountDeletionError(from: error)))
                        } else {
                            self.signOut()
                            completion(.success(()))
                        }
                    }
                    return
                }
                #endif
                self.signOut()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        #if DEBUG
        print("[AUTH] Apple Sign In authorization completed")
        #endif
        #if canImport(FirebaseAuth)
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce
        else {
            finishAppleSignIn(.failure(AuthError.unknown))
            return
        }

        guard
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            finishLocalAppleSignIn(with: appleIDCredential)
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error {
                #if DEBUG
                print("[AUTH] Firebase Apple Sign In failed, continuing with local Apple account: \(error.localizedDescription)")
                #endif
                self?.finishLocalAppleSignIn(with: appleIDCredential)
                return
            }
            guard let firebaseUser = authResult?.user else {
                self?.finishLocalAppleSignIn(with: appleIDCredential)
                return
            }

            let name = firebaseUser.displayName
                ?? [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")

            self?.finishAppleSignIn(.success(AuthenticatedUser(
                userId: firebaseUser.uid,
                displayName: name.isEmpty ? "Jogador" : name
            )))
        }
        #else
        finishAppleSignIn(.failure(AuthError.missingFirebaseAuthSDK))
        #endif
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        #if DEBUG
        print("[AUTH] Apple Sign In failed: \(error.localizedDescription)")
        #endif
        let authError = error as NSError
        if authError.domain == ASAuthorizationError.errorDomain,
           authError.code == ASAuthorizationError.canceled.rawValue {
            finishAppleSignIn(.failure(AuthError.cancelled))
        } else {
            finishFallbackAppleSignIn()
        }
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = applePresenter?.view.window {
            return window
        }

        let connectedWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        return connectedWindow ?? UIWindow()
    }
}

private extension AuthManager {
    var localAppleUser: AuthenticatedUser? {
        guard let userId = UserDefaults.standard.string(forKey: localAppleUserIdKey) else { return nil }
        let displayName = UserDefaults.standard.string(forKey: localAppleDisplayNameKey) ?? "Apple Player"
        return AuthenticatedUser(userId: userId, displayName: displayName)
    }

    func finishAppleSignIn(_ result: Result<AuthenticatedUser, Error>) {
        let completion = appleCompletion
        appleCompletion = nil
        applePresenter = nil
        appleController = nil
        appleTimeoutWorkItem?.cancel()
        appleTimeoutWorkItem = nil
        currentNonce = nil
        completion?(result)
    }

    func finishLocalAppleSignIn(with credential: ASAuthorizationAppleIDCredential) {
        let components = [
            credential.fullName?.givenName,
            credential.fullName?.familyName
        ].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }

        let displayName = components.joined(separator: " ")
        let user = AuthenticatedUser(
            userId: "apple_\(credential.user)",
            displayName: displayName.isEmpty ? "Apple Player" : displayName
        )

        UserDefaults.standard.set(user.userId, forKey: localAppleUserIdKey)
        UserDefaults.standard.set(user.displayName, forKey: localAppleDisplayNameKey)
        finishAppleSignIn(.success(user))
    }

    func finishFallbackAppleSignIn() {
        let fallbackId: String
        if let existing = UserDefaults.standard.string(forKey: localAppleFallbackIdKey) {
            fallbackId = existing
        } else if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            fallbackId = "apple_fallback_\(vendorId)"
            UserDefaults.standard.set(fallbackId, forKey: localAppleFallbackIdKey)
        } else {
            fallbackId = "apple_fallback_\(UUID().uuidString)"
            UserDefaults.standard.set(fallbackId, forKey: localAppleFallbackIdKey)
        }

        let user = AuthenticatedUser(userId: fallbackId, displayName: "Apple Player")
        UserDefaults.standard.set(user.userId, forKey: localAppleUserIdKey)
        UserDefaults.standard.set(user.displayName, forKey: localAppleDisplayNameKey)
        finishAppleSignIn(.success(user))
    }

    func deleteLocalAccount(userId: String) {
        UserDefaults.standard.removeObject(forKey: "player_data_\(userId)")
        clearLocalAppleSession()
        GameManager.shared.playerData = nil
    }

    func clearLocalAppleSession() {
        UserDefaults.standard.removeObject(forKey: localAppleUserIdKey)
        UserDefaults.standard.removeObject(forKey: localAppleDisplayNameKey)
        UserDefaults.standard.removeObject(forKey: localAppleFallbackIdKey)
    }

    func accountDeletionError(from error: Error) -> Error {
        let nsError = error as NSError
        if nsError.domain == AuthErrorDomain,
           nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
            return AuthError.accountDeletionNeedsRecentLogin
        }
        return error
    }

    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status)")
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < UInt8(charset.count) {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
}
