//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftCertificates open source project
//
// Copyright (c) 2022-2023 Apple Inc. and the SwiftCertificates project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftCertificates project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import SwiftASN1

// Time ::= CHOICE {
// utcTime        UTCTime,
// generalTime    GeneralizedTime }
extension Time: DERParseable, DERSerializable {
    @inlinable
    public init(derEncoded rootNode: ASN1Node) throws {
        switch rootNode.identifier {
        case GeneralizedTime.defaultIdentifier:
            self = try .generalTime(GeneralizedTime(derEncoded: rootNode))
        case UTCTime.defaultIdentifier:
            self = try .utcTime(UTCTime(derEncoded: rootNode))
        default:
            throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }

    @inlinable
    public func serialize(into coder: inout DER.Serializer) throws {
        switch self {
        case let .utcTime(utcTime):
            try coder.serialize(utcTime)
        case let .generalTime(generalizedTime):
            try coder.serialize(generalizedTime)
        }
    }
}
