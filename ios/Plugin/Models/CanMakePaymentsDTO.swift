import Foundation

public class CanMakePaymentsDTO: NSObject, Codable {
    let networks: [String]?
    let capabilities: [String]?

    init(networks: [String]? = nil, capabilities: [String]? = nil) {
        self.networks = networks
        self.capabilities = capabilities
    }
}
