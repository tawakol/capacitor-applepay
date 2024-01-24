import Foundation
import PassKit

struct PaymentTokenDTO: Encodable {
    let transactionIdentifier: String
    /// base64 encoded data
    let paymentData: String
    let paymentMethod: PaymentMethodDTO?

    init (with pkPaymentToken: PKPaymentToken) {
        self.transactionIdentifier = pkPaymentToken.transactionIdentifier
        self.paymentData = pkPaymentToken.paymentData.base64EncodedString()
        self.paymentMethod = PaymentMethodDTO(with: pkPaymentToken.paymentMethod)
    }
}

struct BillingContactDTO: Encodable {
    let emailAddress: String?
    let postalAddress: PostalAddressDTO?
    let phoneNumber: String?
    let name: NameDTO?

    init(with pkContact: PKContact?) {
        self.emailAddress = pkContact?.emailAddress
        self.postalAddress = PostalAddressDTO(with: pkContact?.postalAddress)
        self.phoneNumber = pkContact?.phoneNumber?.stringValue
        self.name = NameDTO(with: pkContact?.name)
    }
}

typealias ShippingContactDTO = BillingContactDTO

struct NameDTO: Encodable {
    public let namePrefix: String?
    public let givenName: String?
    public let middleName: String?
    public let familyName: String?
    public let nameSuffix: String?
    public let nickname: String?

    init(with nameComponents: PersonNameComponents?) {
        self.namePrefix = nameComponents?.namePrefix
        self.givenName = nameComponents?.givenName
        self.middleName = nameComponents?.middleName
        self.familyName = nameComponents?.familyName
        self.nameSuffix = nameComponents?.nameSuffix
        self.nickname = nameComponents?.nickname
    }
}

struct PaymentMethodDTO: Encodable {
    let displayName: String?
    let network: String?
    let type: String?
    let billingAddress: AddressDTO?

    init (with pkPaymentMethod: PKPaymentMethod) {
        self.displayName = pkPaymentMethod.displayName
        self.network = pkPaymentMethod.network?.rawValue
        self.type = paymentMethodTypeToString(paymentMethodType: pkPaymentMethod.type)
        if #available(iOS 13.0, *) {
            self.billingAddress = AddressDTO(with: pkPaymentMethod.billingAddress)
        } else {
            self.billingAddress = nil
        }
    }
}

func paymentMethodTypeToString(paymentMethodType: PKPaymentMethodType) -> String {
    switch paymentMethodType {
    case .credit:
        return "credit"
    case .debit:
        return "debit"
    case .prepaid:
        return "prepaid"
    case .store:
        return "store"
    case .unknown:
        return "unknown"
    case .eMoney:
        return "unknown"
    @unknown default:
        return "unknown"
    }
}

struct AddressDTO: Encodable {
    let namePrefix: String?
    let givenName: String?
    let middleName: String?
    let familyName: String?
    let nameSuffix: String?
    let nickname: String?

    init(with cnContact: CNContact?) {
        self.namePrefix = cnContact?.namePrefix
        self.givenName = cnContact?.givenName
        self.middleName = cnContact?.middleName
        self.familyName = cnContact?.familyName
        self.nameSuffix = cnContact?.nameSuffix
        self.nickname = cnContact?.nickname
    }
}

struct PostalAddressDTO: Encodable {
    let street: String?
    let subLocality: String?
    let city: String?
    let subAdministrativeArea: String?
    let state: String?
    let postalCode: String?
    let country: String?
    let isoCountryCode: String?

    init(with cnPostalAddress: CNPostalAddress?) {
        self.street = cnPostalAddress?.street
        self.subLocality = cnPostalAddress?.subLocality
        self.city = cnPostalAddress?.city
        self.subAdministrativeArea = cnPostalAddress?.subAdministrativeArea
        self.state = cnPostalAddress?.state
        self.postalCode = cnPostalAddress?.postalCode
        self.country = cnPostalAddress?.country
        self.isoCountryCode = cnPostalAddress?.isoCountryCode
    }
}

struct PaymentCallResponseDTO: Encodable {
    let token: PaymentTokenDTO
    let billingContact: BillingContactDTO?
    let shippingContact: ShippingContactDTO?
    let shippingMethod: ShippingMethodDTO?

    init(with pkPayment: PKPayment) {
        self.token = PaymentTokenDTO(with: pkPayment.token)
        self.billingContact = BillingContactDTO(with: pkPayment.billingContact)
        self.shippingContact = ShippingContactDTO(with: pkPayment.shippingContact)
        self.shippingMethod = ShippingMethodDTO(with: pkPayment.shippingMethod)
    }
}
