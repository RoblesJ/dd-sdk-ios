/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at Datadog (https://www.datadoghq.com/).
* Copyright 2019-2020 Datadog, Inc.
*/

import XCTest
@testable import RUMModelsGeneratorCore

final class SwiftPrinterTests: XCTestCase {
    func testPrintingSwiftStruct() throws {
        let `struct` = SwiftStruct(
            name: "FooBar",
            comment: "Description of FooBar.",
            properties: [
                SwiftStruct.Property(
                    name: "bar",
                    comment: "Description of Bar.",
                    type: SwiftStruct(
                        name: "BAR",
                        comment: "Description of Bar.",
                        properties: [
                            SwiftStruct.Property(
                                name: "property1",
                                comment: "Description of Bar's `property1`.",
                                type: SwiftPrimitive<String>(),
                                isOptional: true,
                                isMutable: false,
                                defaultValue: nil,
                                codingKey: .static(value: "property1")
                            ),
                            SwiftStruct.Property(
                                name: "property2",
                                comment: "Description of Bar's `property2`.",
                                type: SwiftPrimitive<String>(),
                                isOptional: false,
                                isMutable: true,
                                defaultValue: nil,
                                codingKey: .static(value: "property2")
                            )
                        ],
                        conformance: [codableProtocol]
                    ),
                    isOptional: true,
                    isMutable: false,
                    defaultValue: nil,
                    codingKey: .static(value: "bar")
                ),
                SwiftStruct.Property(
                    name: "bizz",
                    comment: "Description of FooBar's `bizz`.",
                    type: SwiftEnum(
                        name: "Bizz",
                        comment: "Description of FooBar's `bizz`.",
                        cases: [
                            SwiftEnum.Case(label: "case1", rawValue: "case 1"),
                            SwiftEnum.Case(label: "case2", rawValue: "case 2"),
                            SwiftEnum.Case(label: "case3", rawValue: "case 3"),
                            SwiftEnum.Case(label: "case4", rawValue: "case 4"),
                        ],
                        conformance: [codableProtocol]
                    ),
                    isOptional: false,
                    isMutable: false,
                    defaultValue: SwiftEnum.Case(label: "case2", rawValue: "case2"),
                    codingKey: .static(value: "bizz")
                ),
                SwiftStruct.Property(
                    name: "buzz",
                    comment: "Description of FooBar's `buzz`.",
                    type: SwiftArray(
                        element: SwiftEnum(
                            name: "Buzz",
                            comment: nil,
                            cases: [
                                SwiftEnum.Case(label: "option1", rawValue: "option-1"),
                                SwiftEnum.Case(label: "option2", rawValue: "option-2"),
                                SwiftEnum.Case(label: "option3", rawValue: "option-3"),
                                SwiftEnum.Case(label: "option4", rawValue: "option-4"),
                            ],
                            conformance: [codableProtocol]
                        )
                    ),
                    isOptional: true,
                    isMutable: true,
                    defaultValue: nil,
                    codingKey: .static(value: "buzz")
                ),
                SwiftStruct.Property(
                    name: "propertiesByNames",
                    comment: "Description of FooBar's `propertiesByNames`.",
                    type: SwiftDictionary(value: SwiftPrimitive<String>()),
                    isOptional: true,
                    isMutable: false,
                    defaultValue: nil,
                    codingKey: .static(value: "propertiesByNames")
                )
            ],
            conformance: [SwiftProtocol(name: "RUMDataModel", conformance: [codableProtocol])]
        )

        let `enum` = SwiftEnum(
            name: "BizzBuzz",
            comment: nil,
            cases: [
                SwiftEnum.Case(label: "case1", rawValue: "case 1"),
                SwiftEnum.Case(label: "case2", rawValue: "case 2"),
                SwiftEnum.Case(label: "case3", rawValue: "case 3"),
            ],
            conformance: [codableProtocol]
        )

        let printer = SwiftPrinter()
        let actual = try printer.print(swiftTypes: [`struct`, `enum`])

        let expected = """

        /// Description of FooBar.
        public struct FooBar: RUMDataModel {
            /// Description of Bar.
            public let bar: BAR?

            /// Description of FooBar's `bizz`.
            public let bizz: Bizz = .case2

            /// Description of FooBar's `buzz`.
            public var buzz: [Buzz]?

            /// Description of FooBar's `propertiesByNames`.
            public let propertiesByNames: [String: String]?

            enum CodingKeys: String, CodingKey {
                case bar = "bar"
                case bizz = "bizz"
                case buzz = "buzz"
                case propertiesByNames = "propertiesByNames"
            }

            /// Description of Bar.
            public struct BAR: Codable {
                /// Description of Bar's `property1`.
                public let property1: String?

                /// Description of Bar's `property2`.
                public var property2: String

                enum CodingKeys: String, CodingKey {
                    case property1 = "property1"
                    case property2 = "property2"
                }
            }

            /// Description of FooBar's `bizz`.
            public enum Bizz: String, Codable {
                case case1 = "case 1"
                case case2 = "case 2"
                case case3 = "case 3"
                case case4 = "case 4"
            }

            public enum Buzz: String, Codable {
                case option1 = "option-1"
                case option2 = "option-2"
                case option3 = "option-3"
                case option4 = "option-4"
            }
        }

        public enum BizzBuzz: String, Codable {
            case case1 = "case 1"
            case case2 = "case 2"
            case case3 = "case 3"
        }

        """

        XCTAssertEqual(expected, actual)
    }

    func testPrintingSwiftStructWithStaticCodingKeys() throws {
        let `struct` = SwiftStruct(
            name: "Foo",
            comment: nil,
            properties: [
                SwiftStruct.Property(
                    name: "property1",
                    comment: nil,
                    type: SwiftPrimitive<String>(),
                    isOptional: false,
                    isMutable: false,
                    defaultValue: nil,
                    codingKey: .static(value: "property_1")
                ),
                SwiftStruct.Property(
                    name: "property2",
                    comment: nil,
                    type: SwiftDictionary(
                        value: SwiftPrimitive<Int>()
                    ),
                    isOptional: false,
                    isMutable: false,
                    defaultValue: nil,
                    codingKey: .static(value: "property_2")
                )
            ],
            conformance: [codableProtocol]
        )

        let printer = SwiftPrinter()
        let actual = try printer.print(swiftTypes: [`struct`])

        let expected = """

        public struct Foo: Codable {
            public let property1: String

            public let property2: [String: Int]

            enum CodingKeys: String, CodingKey {
                case property1 = "property_1"
                case property2 = "property_2"
            }
        }

        """

        XCTAssertEqual(expected, actual)
    }

    func testPrintingSwiftStructWithDynamicCodingKeys() throws {
        let `struct` = SwiftStruct(
            name: "Foo",
            comment: nil,
            properties: [
                SwiftStruct.Property(
                    name: "context",
                    comment: nil,
                    type: SwiftDictionary(
                        value: SwiftPrimitive<SwiftCodable>()
                    ),
                    isOptional: false,
                    isMutable: false,
                    defaultValue: nil,
                    codingKey: .dynamic
                )
            ],
            conformance: [codableProtocol]
        )

        let printer = SwiftPrinter()
        let actual = try printer.print(swiftTypes: [`struct`])

        let expected = """

        public struct Foo: Codable {
            public let context: [String: Codable]

            struct DynamicCodingKey: CodingKey {
                var stringValue: String
                var intValue: Int?
                init?(stringValue: String) { self.stringValue = stringValue }
                init?(intValue: Int) { return nil }
                init(_ string: String) { self.stringValue = string }
            }
        }

        extension Foo {
            public func encode(to encoder: Encoder) throws {
                // Encode dynamic properties:
                var dynamicContainer = encoder.container(keyedBy: DynamicCodingKey.self)
                try context.forEach {
                    let key = DynamicCodingKey($0)
                    try dynamicContainer.encode(EncodableValue($1), forKey: key)
                }
            }

            public init(from decoder: Decoder) throws {
                // Decode other properties into [String: Codable] dictionary:
                let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
                let dynamicKeys = dynamicContainer.allKeys
                var dictionary: [String: Codable] = [:]

                try dynamicKeys.forEach { codingKey in
                    dictionary[codingKey.stringValue] = try dynamicContainer.decodeIfPresent(CodableValue.self, forKey: codingKey)
                }

                self.context = dictionary
            }
        }

        """

        XCTAssertEqual(expected, actual)
    }

    func testPrintingSwiftStructWithStaticAndDynamicCodingKeys() throws {
        let `struct` = SwiftStruct(
            name: "Foo",
            comment: nil,
            properties: [
                SwiftStruct.Property(
                    name: "property1",
                    comment: nil,
                    type: SwiftPrimitive<Int>(),
                    isOptional: false,
                    isMutable: false,
                    defaultValue: nil,
                    codingKey: .static(value: "property_1")
                ),
                SwiftStruct.Property(
                    name: "context",
                    comment: nil,
                    type: SwiftDictionary(
                        value: SwiftPrimitive<SwiftCodable>()
                    ),
                    isOptional: false,
                    isMutable: false,
                    defaultValue: nil,
                    codingKey: .dynamic
                ),
                SwiftStruct.Property(
                    name: "property2",
                    comment: nil,
                    type: SwiftPrimitive<Bool>(),
                    isOptional: true,
                    isMutable: true,
                    defaultValue: nil,
                    codingKey: .static(value: "property_2")
                )
            ],
            conformance: [codableProtocol]
        )

        let printer = SwiftPrinter()
        let actual = try printer.print(swiftTypes: [`struct`])

        let expected = """

        public struct Foo: Codable {
            public let property1: Int

            public let context: [String: Codable]

            public var property2: Bool?

            enum StaticCodingKeys: String, CodingKey {
                case property1 = "property_1"
                case property2 = "property_2"
            }

            struct DynamicCodingKey: CodingKey {
                var stringValue: String
                var intValue: Int?
                init?(stringValue: String) { self.stringValue = stringValue }
                init?(intValue: Int) { return nil }
                init(_ string: String) { self.stringValue = string }
            }
        }

        extension Foo {
            public func encode(to encoder: Encoder) throws {
                // Encode static properties:
                var staticContainer = encoder.container(keyedBy: StaticCodingKeys.self)
                try staticContainer.encodeIfPresent(property1, forKey: .property1)
                try staticContainer.encodeIfPresent(property2, forKey: .property2)

                // Encode dynamic properties:
                var dynamicContainer = encoder.container(keyedBy: DynamicCodingKey.self)
                try context.forEach {
                    let key = DynamicCodingKey($0)
                    try dynamicContainer.encode(EncodableValue($1), forKey: key)
                }
            }

            public init(from decoder: Decoder) throws {
                // Decode static properties:
                let staticContainer = try decoder.container(keyedBy: StaticCodingKeys.self)
                self.property1 = try staticContainer.decode(Int.self, forKey: .property1)
                self.property2 = try staticContainer.decodeIfPresent(Bool.self, forKey: .property2)

                // Decode other properties into [String: Codable] dictionary:
                let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
                let allStaticKeys = Set(staticContainer.allKeys.map { $0.stringValue })
                let dynamicKeys = dynamicContainer.allKeys.filter { !allStaticKeys.contains($0.stringValue) }
                var dictionary: [String: Codable] = [:]

                try dynamicKeys.forEach { codingKey in
                    dictionary[codingKey.stringValue] = try dynamicContainer.decodeIfPresent(CodableValue.self, forKey: codingKey)
                }

                self.context = dictionary
            }
        }

        """

        XCTAssertEqual(expected, actual)
    }
}
