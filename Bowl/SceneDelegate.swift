//
//  SceneDelegate.swift
//  Bowl
//
//  Created by Hyojung Jang on 7/3/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // 100% code-based bootstrapping — no storyboard.
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)

    // The app uses custom in-screen navigation bars, so the system bar is hidden.
    let onboardingViewController = OnboardingViewController(viewModel: OnboardingViewModel())
    let navigationController = UINavigationController(rootViewController: onboardingViewController)
    navigationController.setNavigationBarHidden(true, animated: false)

    onboardingViewController.onFinishOnboarding = { [weak navigationController] in
      let step1 = ProfilePhotoNameViewController(viewModel: ProfilePhotoNameViewModel())
      step1.onCompleteStep = { draft in
        // TODO: Route to profile step 2 (묘종 & 생일), carrying `draft`.
        print("Profile step 1 complete → name: \(draft.name), hasPhoto: \(draft.photo != nil)")
      }
      navigationController?.pushViewController(step1, animated: true)
    }

    window.rootViewController = navigationController
    window.makeKeyAndVisible()
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

