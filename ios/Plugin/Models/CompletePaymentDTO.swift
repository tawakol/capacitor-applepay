import Foundation
import PassKit

public class CompletePaymentDTO: NSObject, Codable {
    let status: String?

    func toPKResult() -> PKPaymentAuthorizationResult? {
        switch status {
        case "success":
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        case "failure":
            return PKPaymentAuthorizationResult(status: .failure, errors: nil)
        default:
            return nil
        }
    }
}
