//
//  PuretoApp.swift
//  Pureto
//
//  Created by Pureto on 26/6/23.
//

import SwiftUI
import AppLovinSDK
import UIKit

@main
struct PuretoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var dataRequest = DataRequest.shared
    @StateObject var shortRequest = ShortRequest.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { newScenePhase in
                    switch newScenePhase {
                    case .active :
                        Task.detached {
                            await dataRequest.fetchAppUpdated(appId: "6452237640" )
                        }
                        print("App active")
                    case .background:
                        print("App background")
                    case .inactive:
                        print("App inactive")
                    @unknown default:
                        print("Others")
                    }
                }
        }
        
    }
}
// AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      ALSdk.shared()?.mediationProvider = ALMediationProviderMAX
      ALSdk.shared()?.settings.isMuted = true
      ALSdk.shared()?.settings.isVerboseLoggingEnabled = true
      ALSdk.shared()?.initializeSdk()

    return true
  }
}
