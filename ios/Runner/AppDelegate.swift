import UIKit
import Flutter
import Firebase // <-- **1. AJOUTER CET IMPORT**

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // --- 2. AJOUTER CETTE LIGNE ---
    FirebaseApp.configure()
    // -----------------------------

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}