import UIKit.UIViewController
import RxCocoa

public protocol DisplayError {
    func showError(error: Error, okAction: (() -> Void)?)
    func showError(title: String, message: String, okAction: (() -> Void)?)
}

extension UIViewController: DisplayError {
    public func showError(title: String, message: String, okAction: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.modalPresentationStyle = .overFullScreen
        alertController.modalPresentationCapturesStatusBarAppearance = true
        let okHandler: (UIAlertAction) -> Void = { _ in okAction?() }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        self.present(alertController, animated: true, completion: nil)
    }

    public func showError(error: Error, okAction: (() -> Void)?) {
        showError(title: "Something went wrong", message: error.localizedDescription, okAction: okAction)
    }
}
