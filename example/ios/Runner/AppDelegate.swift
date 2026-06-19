import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  static var allowedOrientations: UIInterfaceOrientationMask = .portrait

  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )
  }

  func didInitializeImplicitFlutterEngine(
      _ engineBridge: FlutterImplicitEngineBridge
  ) {
    GeneratedPluginRegistrant.register(
        with: engineBridge.pluginRegistry
    )

    guard let registrar = engineBridge.pluginRegistry.registrar(
        forPlugin: "com.apogee.OrientationPlugin"
    ) else {
      return
    }

    let channel = FlutterMethodChannel(
        name: "com.apogee/orientation",
        binaryMessenger: registrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {

      case "toLandscape":
        print("=== TO LANDSCAPE ===")
        AppDelegate.allowedOrientations = .landscape
        self.requestSceneOrientation(
            .landscape,
            result: result
        )

      case "toPortrait":
        print("=== TO PORTRAIT ===")
        AppDelegate.allowedOrientations = .portrait
        self.requestSceneOrientation(
            .portrait,
            result: result
        )

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func requestSceneOrientation(
      _ mask: UIInterfaceOrientationMask,
      result: @escaping FlutterResult
  ) {
    if #available(iOS 16.0, *) {

      guard let windowScene = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .first else {

        result(
            FlutterError(
                code: "NO_SCENE",
                message: "No window scene",
                details: nil
            )
        )
        return
      }

      let preferences =
          UIWindowScene.GeometryPreferences.iOS(
              interfaceOrientations: mask
          )

      windowScene.requestGeometryUpdate(preferences) { error in
        print(
            "[Orientation] requestGeometryUpdate error: \(error.localizedDescription)"
        )
      }

      windowScene.windows.first?.rootViewController?
          .setNeedsUpdateOfSupportedInterfaceOrientations()

    } else {

      let targetOrientation: UIInterfaceOrientation =
          (mask == .portrait)
              ? .portrait
              : .landscapeLeft

      UIDevice.current.setValue(
          targetOrientation.rawValue,
          forKey: "orientation"
      )

      UIViewController.attemptRotationToDeviceOrientation()
    }

    result(nil)
  }

  // Single source of truth for allowed orientations
  override func application(
      _ application: UIApplication,
      supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {

    // Always allow landscape if WKWebView fullscreen is active
    for scene in application.connectedScenes {

      if let windowScene = scene as? UIWindowScene {

        for win in windowScene.windows {

          if isVideoFullscreen(
              viewController: win.rootViewController
          ) {
            return .landscape
          }
        }
      }
    }

    return AppDelegate.allowedOrientations
  }

  private func isVideoFullscreen(
      viewController: UIViewController?
  ) -> Bool {

    guard let vc = viewController else {
      return false
    }

    let name = String(describing: type(of: vc))

    if name.contains("FullScreen") ||
           name.contains("AVPlayer") {
      return true
    }

    for child in vc.children {
      if isVideoFullscreen(
          viewController: child
      ) {
        return true
      }
    }

    if let presented = vc.presentedViewController {
      return isVideoFullscreen(
          viewController: presented
      )
    }

    return false
  }
}
