//
//  SceneDelegate.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit
import Firebase
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create a new UIWindow using the windowScene constructor which takes the windowScene as a parameter
        let window = UIWindow(windowScene: windowScene)

        // Determine which storyboard to use
//        let storyboardName: String
        
        let user = Auth.auth().currentUser
        
        if let user = user {
            // Reference to Firestore database
            let database = Firestore.firestore()
            
            // Check if a document exists for the current user
            database.collection("users").whereField("id", isEqualTo: user.uid).getDocuments { (querySnapshot, _) in
                let storyboardName: String
                if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                    // At least one document for user exists, proceed to Main storyboard
                    storyboardName = "Main"
                } else {
                    // No document for user, show Login storyboard
                    storyboardName = "Login"
                }
                
                // Load the storyboard
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
                    if let initialViewController = storyboard.instantiateInitialViewController() {
                        window.rootViewController = initialViewController
                        window.makeKeyAndVisible()
                    }
                }
            }
        } else {
            // No user logged in, show Login storyboard
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                window.rootViewController = initialViewController
                window.makeKeyAndVisible()
            }
        }
        
//        if user != nil {
//            storyboardName = "Main"
//        } else {
//            storyboardName = "Login"
//        }
//        // Load the storyboard
//        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
//
//        let initialViewController = storyboard.instantiateInitialViewController()
//
//        window.rootViewController = initialViewController
//        window.makeKeyAndVisible()

        // Assign the window to the scene's window property
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}
