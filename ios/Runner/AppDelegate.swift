import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyD29H51dsdU1Cbn_3cAHZTRCAw9fiVAs1k")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
