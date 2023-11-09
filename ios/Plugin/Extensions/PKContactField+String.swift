import PassKit

extension PKContactField {

    init?(field: String) {
        switch field.lowercased() {
        case "name": self.init(rawValue: PKContactField.name.rawValue)
        case "emailaddress": self.init(rawValue: PKContactField.emailAddress.rawValue)
        case "phonenumber": self.init(rawValue: PKContactField.phoneNumber.rawValue)
        case "phoneticname": self.init(rawValue: PKContactField.phoneticName.rawValue)
        case "postaladdress": self.init(rawValue: PKContactField.postalAddress.rawValue)
        default: return nil
        }
    }

    static func fromStringArray(fields: [String]) -> Set<PKContactField> {
        let lowercasedFields = fields.map { $0.lowercased() }
        let fields = lowercasedFields.compactMap({ field in
            return PKContactField(field: field)
        })

        return Set(fields)
    }
}
