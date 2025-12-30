/// A CMS/PKCS#7 version number.
public struct Version: RawRepresentable, Hashable, Sendable {
    /// The raw version value.
    public var rawValue: Int

    /// Creates a version with the specified raw value.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Version 0.
    public static let v0 = Self(rawValue: 0)

    /// Version 1.
    public static let v1 = Self(rawValue: 1)

    /// Version 2.
    public static let v2 = Self(rawValue: 2)

    /// Version 3.
    public static let v3 = Self(rawValue: 3)

    /// Version 4.
    public static let v4 = Self(rawValue: 4)

    /// Version 5.
    public static let v5 = Self(rawValue: 5)
}

extension Version: CustomStringConvertible {
    public var description: String {
        "CMSv\(rawValue)"
    }
}
