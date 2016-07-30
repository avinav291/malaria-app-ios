import UIKit
import Toast_Swift

class ToastHelper {
  typealias ToastCompletion = ((didTap: Bool) -> Void)
  
  /// Presents a toast in the root View Controller.
  
  static func makeToast(message: String?,
                        duration: NSTimeInterval = 3,
                        position: ToastPosition = .Bottom,
                        title: String? = nil,
                        image: UIImage? = nil,
                        style: ToastStyle? = nil,
                        completion: ToastCompletion? = nil) {
    
    let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
    alertWindow.rootViewController = UIViewController()
    alertWindow.windowLevel = UIWindowLevelAlert + 1;
    alertWindow.makeKeyAndVisible()
    
    // Show alert message.
    UIApplication.sharedApplication().keyWindow?.rootViewController?
      .view.makeToast(message,
                      duration: duration,
                      position: position,
                      title: title,
                      image: image,
                      style: style,
                      completion: completion)
  }
}