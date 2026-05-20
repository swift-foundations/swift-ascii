//
//  Binary.ASCII.Serializable Tests.swift
//  swift-incits-4-1986
//
//  Tests demonstrating the Binary.ASCII.Serializable protocol
//  with both context-free and context-dependent parsing.
//
//  Substrate per the ASCII-domain retyping arc (2026-05-19): conformer
//  signatures use Bytes.Element == Byte / Buffer.Element == Byte.

import Binary_Primitives
import ASCII
import Testing

// MARK: - Context-Free Type Example

/// A simple token type that requires no parsing context.
/// Demonstrates the standard Serializable conformance pattern.
private struct Token: Sendable, Codable {
    let rawValue: String

    internal init(
        __unchecked: Void,
        rawValue: String
    ) {
        self.rawValue = rawValue
    }

    public init(
        _ value: String
    ) throws(Error) {
        let bytes: [UInt8] = Array(value.utf8)
        guard !bytes.isEmpty else { throw .empty }

        for byte in bytes {
            guard byte.ascii.isAlphanumeric || byte == .ascii.hyphen else {
                throw .invalidCharacter(byte)
            }
        }

        self.init(
            __unchecked: (),
            rawValue: value
        )
    }
}

extension Token {
    enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

extension Token: Binary.ASCII.Serializable {

    // Context == Void (default), so we implement init(ascii:in:) with Void context
    init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == Byte {
        try self.init(String(decoding: bytes, as: UTF8.self))
    }

    static func serialize<Buffer>(ascii token: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(contentsOf: token.rawValue.utf8)
    }
}

extension Token: Hashable {}
extension Token: CustomStringConvertible {}
extension Token: ExpressibleByStringLiteral {}

// MARK: - Context-Dependent Type Example

/// A message type that requires a delimiter to parse.
/// Demonstrates context-dependent Serializable conformance.
struct DelimitedMessage: Sendable, Codable {
    let parts: [String]
    let delimiter: UInt8

    init(__unchecked: Void, parts: [String], delimiter: UInt8) {
        self.parts = parts
        self.delimiter = delimiter
    }
}

extension DelimitedMessage: Binary.ASCII.Serializable {
    //    static func serialize(ascii message: DelimitedMessage) -> [UInt8] {
    //        var result: [UInt8] = []
    //        for (index, part) in message.parts.enumerated() {
    //            if index > 0 {
    //                result.append(message.delimiter)
    //            }
    //            result.append(contentsOf: part.utf8)
    //        }
    //        return result
    //    }

    internal static func serialize<Buffer>(ascii message: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        for (index, part) in message.parts.enumerated() {
            if index > 0 {
                // delimiter is UInt8 arithmetic-domain; wrap to byte-domain for append.
                buffer.append(Byte(message.delimiter))
            }
            buffer.append(contentsOf: part.utf8)
        }
    }

    /// Context required for parsing - the delimiter byte
    struct Context: Sendable {
        let delimiter: UInt8
    }

    enum Error: Swift.Error, Sendable, Equatable {
        case empty
    }

    init<Bytes: Collection>(ascii bytes: Bytes, in context: Context) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else { throw .empty }

        // Split on delimiter
        var parts: [String] = []
        var current: [UInt8] = []

        for byte in bytes {
            // Delimiter is UInt8 in this test type; bridge byte-domain element
            // to UInt8 for arithmetic-domain equality.
            if byte.underlying == context.delimiter {
                parts.append(String(decoding: current, as: UTF8.self))
                current = []
            } else {
                current.append(byte.underlying)
            }
        }
        // Add final part
        parts.append(String(decoding: current, as: UTF8.self))

        self.init(__unchecked: (), parts: parts, delimiter: context.delimiter)
    }
}

extension DelimitedMessage: Hashable {}
extension DelimitedMessage: CustomStringConvertible {}

// MARK: - Context-Free Parsing Tests

@Suite("Serializable - Context-Free Types")
struct ContextFreeSerializableTests {
    @Test
    func `Parse from bytes using init(ascii:)`() throws {
        let bytes: [Byte] = Array<Byte>("hello-world".utf8)
        let token: Token = try .init(ascii: bytes)

        #expect(token.rawValue == "hello-world")
    }

    @Test
    func `Parse from bytes using init(ascii:in:) with Void`() throws {
        let bytes: [Byte] = Array<Byte>("test123".utf8)
        let token: Token = try .init(ascii: bytes, in: ())

        #expect(token.rawValue == "test123")
    }

    @Test
    func `Parse from string using init(_:)`() throws {
        let token: Token = try .init("my-token")

        #expect(token.rawValue == "my-token")
    }

    @Test
    func `String literal initialization`() {
        let token: Token = "literal-token"

        #expect(token.rawValue == "literal-token")
    }

    @Test
    func `Serialize to bytes`() throws {
        let token: Token = try .init("hello")

        // `Token.serialize(_:)` (from `Binary.Serializable`) returns
        // `Bytes where Bytes.Element == Byte` post-cascade.
        let serialized: [Byte] = Token.serialize(token)
        #expect(serialized == Array<Byte>("hello".utf8))
    }

    @Test
    func `Convert to String`() throws {
        let token: Token = try .init("world")

        #expect(String(token) == "world")
    }

    @Test
    func `Round-trip: bytes → Token → bytes`() throws {
        let original: [Byte] = Array<Byte>("round-trip".utf8)
        let token: Token = try .init(ascii: original)

        // ASCII-typed serialize returns [Byte]
        let serialized: [Byte] = Token.serialize(ascii: token)
        #expect(serialized == original)
    }

    @Test
    func `Round-trip: string → Token → string`() throws {
        let original = "test-value"
        let token: Token = try .init(original)
        let result = String(token)

        #expect(result == original)
    }

    @Test
    func `Invalid input throws error`() {
        let bytes: [Byte] = Array<Byte>("hello world".utf8)  // space is invalid

        #expect(throws: Token.Error.self) {
            try Token(ascii: bytes)
        }
    }

    @Test
    func `Empty input throws error`() {
        let bytes: [Byte] = []

        #expect(throws: Token.Error.empty) {
            try Token(ascii: bytes)
        }
    }
}

// MARK: - Context-Dependent Parsing Tests

@Suite("Serializable - Context-Dependent Types")
struct ContextDependentSerializableTests {
    @Test
    func `Parse with context using init(ascii:in:)`() throws {
        let bytes: [Byte] = Array<Byte>("foo|bar|baz".utf8)
        let context = DelimitedMessage.Context(delimiter: .ascii.verticalLine)

        let message = try DelimitedMessage(ascii: bytes, in: context)

        #expect(message.parts == ["foo", "bar", "baz"])
        #expect(message.delimiter == .ascii.verticalLine)
    }

    @Test
    func `Different delimiters produce different parses`() throws {
        let bytes: [Byte] = Array<Byte>("a,b|c".utf8)

        // Parse with comma delimiter
        let commaContext = DelimitedMessage.Context(delimiter: .ascii.comma)
        let commaMessage = try DelimitedMessage(ascii: bytes, in: commaContext)
        #expect(commaMessage.parts == ["a", "b|c"])

        // Parse with pipe delimiter
        let pipeContext = DelimitedMessage.Context(delimiter: .ascii.verticalLine)
        let pipeMessage = try DelimitedMessage(ascii: bytes, in: pipeContext)
        #expect(pipeMessage.parts == ["a,b", "c"])
    }

    @Test
    func `Serialize to bytes`() throws {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["hello", "world"],
            delimiter: .ascii.hyphen
        )

        // `DelimitedMessage.serialize(_:)` (Binary.Serializable) returns
        // `Bytes where Bytes.Element == Byte` post-cascade.
        let serialized: [Byte] = DelimitedMessage.serialize(message)
        #expect(serialized == Array<Byte>("hello-world".utf8))
    }

    @Test
    func `Round-trip: bytes → Message → bytes`() throws {
        let original: [Byte] = Array<Byte>("one:two:three".utf8)
        let context = DelimitedMessage.Context(delimiter: .ascii.colon)

        let message = try DelimitedMessage(ascii: original, in: context)

        // ASCII-typed serialize returns [Byte]
        let serialized: [Byte] = DelimitedMessage.serialize(ascii: message)
        #expect(serialized == original)
    }

    @Test
    func `Convert to String via serialize`() throws {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b", "c"],
            delimiter: .ascii.semicolon
        )

        let string = String(message)

        #expect(string == "a;b;c")
    }

    @Test
    func `Empty input throws error`() {
        let bytes: [Byte] = []
        let context = DelimitedMessage.Context(delimiter: .ascii.comma)

        #expect(throws: DelimitedMessage.Error.empty) {
            try DelimitedMessage(ascii: bytes, in: context)
        }
    }

    @Test
    func `Context-dependent type does NOT have init(_: String)`() {
        // This test documents that context-dependent types
        // don't get the automatic init(_: StringProtocol) convenience.
        // The following would not compile:
        // let message = try DelimitedMessage("a,b,c")  // Error: no context!

        // Instead, you must provide context:
        let bytes: [Byte] = Array<Byte>("a,b,c".utf8)
        let context = DelimitedMessage.Context(delimiter: .ascii.comma)
        let message = try? DelimitedMessage(ascii: bytes, in: context)

        #expect(message != nil)
    }
}

// MARK: - Category Theory Verification

@Suite("Serializable - Category Theory Properties")
struct CategoryTheoryTests {
    @Test
    func `Void context is the unit type (terminal object)`() {
        // In category theory, Void is the terminal object.
        // There's exactly one value: ()
        // A function (Void × A) → B is isomorphic to A → B

        // For context-free types, init(ascii:in:()) ≅ init(ascii:)
        let bytes: [Byte] = Array<Byte>("test".utf8)

        // Both should produce identical results:
        let viaConvenience = try? Token(ascii: bytes)
        let viaExplicit = try? Token(ascii: bytes, in: ())

        #expect(viaConvenience == viaExplicit)
    }

    @Test
    func `Serialization is context-free (value is self-describing)`() throws {
        // Even for context-dependent types, serialization doesn't need context.
        // The value itself contains all information needed to serialize.

        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["x", "y"],
            delimiter: .ascii.comma
        )

        // Serialize without needing any context:
        let serialized: [Byte] = DelimitedMessage.serialize(message)
        #expect(serialized == Array<Byte>("x,y".utf8))
    }

    @Test
    func `Parse-serialize round-trip is identity (for well-formed input)`() throws {
        // For well-formed input, parse ∘ serialize = id
        let original: [Byte] = Array<Byte>("valid-token".utf8)

        let token: Token = try .init(ascii: original)
        let serialized: [Byte] = Token.serialize(ascii: token)
        #expect(serialized == original)
    }
}

// MARK: - Binary.Serializable Conformance Tests

/// Example HTML-like element that composes with ASCII.Serializable types.
/// Demonstrates how streaming types can embed RFC/ASCII types seamlessly.
///
/// `HTMLAnchor` is a pure `Binary.Serializable` (Byte substrate per
/// [API-BYTE-003] post-W2 cascade). The `.utf8` appends go through the
/// BSLI `append(contentsOf: Sequence<UInt8>) where Element: Byte.Protocol`
/// bridge in `Byte_Primitives_Standard_Library_Integration`.
private struct HTMLAnchor: Binary.Serializable {
    let href: Token
    let text: String

    static func serialize<Buffer>(_ anchor: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(contentsOf: "<a href=\"".utf8)
        Token.serialize(anchor.href, into: &buffer)
        buffer.append(contentsOf: "\">".utf8)
        buffer.append(contentsOf: anchor.text.utf8)
        buffer.append(contentsOf: "</a>".utf8)
    }
}

@Suite("Serializable - Binary.Serializable Conformance")
struct StreamingConformanceTests {

    // MARK: - Automatic Conformance

    @Test
    func `ASCII.Serializable types automatically conform to Binary.Serializable`() throws {
        let token: Token = try .init("my-token")

        // Token conforms to Binary.Serializable via ASCII.Serializable.
        // The ASCII wrapper path uses the Byte substrate.
        var buffer: [Byte] = []
        token.ascii.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("my-token".utf8))
    }

    @Test
    func `Context-dependent types also conform to Binary.Serializable`() {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b", "c"],
            delimiter: .ascii.comma
        )

        // DelimitedMessage conforms to Binary.Serializable via ASCII.Serializable
        var buffer: [Byte] = []
        message.ascii.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("a,b,c".utf8))
    }

    // MARK: - Buffer-Based Serialization

    @Test
    func `Serialize into buffer using serialize(into:)`() throws {
        let token: Token = try .init("hello-world")

        // Ideal streaming usage pattern (ASCII substrate, [Byte] buffer).
        var buffer: [Byte] = []
        token.ascii.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("hello-world".utf8))
    }

    @Test
    func `Get bytes using .bytes property`() throws {
        let token: Token = try .init("swift-token")

        // `.bytes` convenience from Binary.Serializable returns `[Byte]`
        // post-cascade.
        let bytes: [Byte] = token.bytes

        #expect(bytes == Array<Byte>("swift-token".utf8))
    }

    @Test
    func `Append to existing buffer content`() throws {
        let token: Token = try .init("suffix")

        var buffer: [Byte] = Array<Byte>("prefix-".utf8)
        token.ascii.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("prefix-suffix".utf8))
    }

    // MARK: - Composition with Streaming Types

    @Test
    func `ASCII types compose with pure streaming types`() throws {
        let anchor = try HTMLAnchor(
            href: .init("example-link"),
            text: "Click here"
        )

        let result = String(anchor)

        #expect(result == "<a href=\"example-link\">Click here</a>")
    }

    @Test
    func `Multiple ASCII types serialize into shared buffer`() throws {
        let token1: Token = try .init("first")
        let token2: Token = try .init("second")
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b"],
            delimiter: .ascii.colon
        )

        // Accumulate all into one buffer ([Byte] for ASCII substrate)
        var buffer: [Byte] = []
        token1.ascii.serialize(into: &buffer)
        buffer.append(Byte.ascii.hyphen)
        token2.ascii.serialize(into: &buffer)
        buffer.append(Byte.ascii.verticalLine)
        message.ascii.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("first-second|a:b".utf8))
    }

    @Test
    func `Pre-allocate buffer for efficiency`() throws {
        let tokens = try (1...10).map { try Token("token-\($0)") }

        var buffer: [Byte] = []
        buffer.reserveCapacity(200)

        for (index, token) in tokens.enumerated() {
            if index > 0 {
                buffer.append(Byte.ascii.comma)
            }
            token.ascii.serialize(into: &buffer)
        }

        let result = String(decoding: buffer, as: UTF8.self)
        #expect(result.hasPrefix("token-1,token-2"))
        #expect(result.hasSuffix("token-10"))
    }

    // MARK: - Round-Trip via Streaming

    @Test
    func `Round-trip through buffer produces same result as static serialize`() throws {
        let token: Token = try .init("roundtrip-test")

        // Via static Binary.Serializable (returns [Byte] post-cascade).
        let staticBytes: [Byte] = Token.serialize(token)

        // Via streaming serialize(into:) on ASCII substrate ([Byte]).
        var streamingBuffer: [Byte] = []
        token.ascii.serialize(into: &streamingBuffer)

        // Via .bytes property (Binary.Serializable, [Byte]).
        let propertyBytes: [Byte] = token.bytes

        // All three paths produce identical [Byte] output.
        #expect(staticBytes == streamingBuffer)
        #expect(staticBytes == propertyBytes)
    }
}

// MARK: - API Pattern Demonstrations

@Suite("Serializable - Streaming API Patterns")
struct StreamingAPIPatternTests {

    @Test
    func `Pattern: Direct buffer writing for server response`() throws {
        // Simulating building an HTTP-like response ([Byte] for ASCII substrate)
        var response: [Byte] = []

        // Add header
        response.append(contentsOf: "X-Token: ".utf8)
        let token: Token = try .init("auth-token-123")
        token.ascii.serialize(into: &response)
        response.append(contentsOf: "\r\n".utf8)

        let result = String(decoding: response, as: UTF8.self)
        #expect(result == "X-Token: auth-token-123\r\n")
    }

    @Test
    func `Pattern: Building HTML with embedded RFC types`() throws {
        let anchor = try HTMLAnchor(
            href: .init("https-link"),
            text: "Visit site"
        )

        // Get bytes for HTTP response (Binary.Serializable, [Byte] post-cascade).
        let bytes: [Byte] = anchor.bytes

        // Or get String for debugging/logging
        let string = String(anchor)

        #expect(bytes == Array<Byte>(string.utf8))
        #expect(string == "<a href=\"https-link\">Visit site</a>")
    }

    @Test
    func `Pattern: Reusable buffer for batch processing`() throws {
        var buffer: [Byte] = []
        var results: [[Byte]] = []

        let inputs = ["alpha", "beta", "gamma"]

        for input in inputs {
            buffer.removeAll(keepingCapacity: true)
            let token: Token = try .init(input)
            token.ascii.serialize(into: &buffer)
            results.append(buffer)
        }

        #expect(results.count == 3)
        #expect(results[0] == Array<Byte>("alpha".utf8))
        #expect(results[1] == Array<Byte>("beta".utf8))
        #expect(results[2] == Array<Byte>("gamma".utf8))
    }

    @Test
    func `Pattern: Streaming type wrapping ASCII type`() throws {
        // HTMLAnchor is a streaming type that wraps Token (ASCII type)
        struct Document: Binary.Serializable {
            let title: Token
            let links: [HTMLAnchor]

            static func serialize<Buffer>(_ doc: Self, into buffer: inout Buffer)
            where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
                buffer.append(contentsOf: "<html><head><title>".utf8)
                Token.serialize(doc.title, into: &buffer)
                buffer.append(contentsOf: "</title></head><body>".utf8)
                for link in doc.links {
                    link.serialize(into: &buffer)
                }
                buffer.append(contentsOf: "</body></html>".utf8)
            }
        }

        let doc = try Document(
            title: .init("My-Page"),
            links: [
                HTMLAnchor(href: .init("link1"), text: "First"),
                HTMLAnchor(href: .init("link2"), text: "Second"),
            ]
        )

        let html = String(doc)

        #expect(html.contains("<title>My-Page</title>"))
        #expect(html.contains("<a href=\"link1\">First</a>"))
        #expect(html.contains("<a href=\"link2\">Second</a>"))
    }
}

// MARK: - Infinite Recursion Prevention Tests

/// Example type demonstrating the CORRECT pattern for Binary.ASCII.RawRepresentable
///
/// Types conforming to both `Binary.ASCII.Serializable` and `Binary.ASCII.RawRepresentable`
/// MUST implement `serialize(ascii:into:)` explicitly to avoid infinite recursion.
private struct CorrectEmailAddress: Sendable, Codable, Hashable {
    let localPart: String
    let domain: String

    init(__unchecked: Void, localPart: String, domain: String) {
        self.localPart = localPart
        self.domain = domain
    }
}

extension CorrectEmailAddress: Binary.ASCII.Serializable {
    enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case missingAtSign
    }

    init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else { throw .empty }

        let byteArray: [Byte] = Array(bytes)
        guard let atIndex = byteArray.firstIndex(of: .ascii.commercialAt) else {
            throw .missingAtSign
        }

        self.init(
            __unchecked: (),
            localPart: String(decoding: byteArray[..<atIndex], as: UTF8.self),
            domain: String(decoding: byteArray[byteArray.index(after: atIndex)...], as: UTF8.self)
        )
    }

    /// CORRECT: Explicit serialize implementation that does NOT use rawValue
    ///
    /// This is REQUIRED when conforming to Binary.ASCII.RawRepresentable.
    /// Using rawValue here would cause infinite recursion because:
    ///   rawValue → String(ascii: self) → serialize(ascii:into:) → rawValue → ...
    static func serialize<Buffer: RangeReplaceableCollection>(
        ascii email: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: email.localPart.utf8)
        buffer.append(Byte.ascii.commercialAt)
        buffer.append(contentsOf: email.domain.utf8)
    }
}

extension CorrectEmailAddress: Binary.ASCII.RawRepresentable {
    typealias RawValue = String
}

extension CorrectEmailAddress: CustomStringConvertible {}

@Suite("Serializable - Infinite Recursion Prevention")
struct InfiniteRecursionPreventionTests {

    // MARK: - Documentation of the Problem

    /// This test documents the infinite recursion problem that occurs when
    /// a type conforms to both Binary.ASCII.Serializable and Binary.ASCII.RawRepresentable
    /// WITHOUT providing an explicit serialize(ascii:into:) implementation.
    ///
    /// ## The Problem Pattern (DO NOT USE)
    ///
    /// ```swift
    /// // WRONG: This causes infinite recursion!
    /// extension MyType: Binary.ASCII.Serializable {
    ///     // Relying on default implementation from RawRepresentable
    /// }
    ///
    /// extension MyType: Binary.ASCII.RawRepresentable {
    ///     typealias RawValue = String
    /// }
    /// ```
    ///
    /// ## Why It Crashes
    ///
    /// 1. `rawValue` getter (from Binary.ASCII.RawRepresentable) calls `String(ascii: self)`
    /// 2. `String(ascii:)` calls `T.serialize(ascii:into:)` to get bytes
    /// 3. Default `serialize(ascii:into:)` for RawRepresentable uses `rawValue.utf8`
    /// 4. This accesses `rawValue` again → INFINITE RECURSION → Stack overflow
    ///
    /// ## The Solution
    ///
    /// Always provide an explicit `serialize(ascii:into:)` that does NOT use `rawValue`:
    ///
    /// ```swift
    /// extension MyType: Binary.ASCII.Serializable {
    ///     static func serialize<Buffer: RangeReplaceableCollection>(
    ///         ascii value: Self,
    ///         into buffer: inout Buffer
    ///     ) where Buffer.Element == UInt8 {
    ///         // Serialize directly from stored properties, NOT from rawValue
    ///         buffer.append(contentsOf: value.someProperty.utf8)
    ///     }
    /// }
    /// ```
    @Test
    func `Correct pattern avoids infinite recursion`() throws {
        let email = try CorrectEmailAddress("user@example.com")

        // These should all work without infinite recursion:
        let rawValue = email.rawValue
        let description = email.description
        let bytes: [Byte] = email.bytes

        #expect(rawValue == "user@example.com")
        #expect(description == "user@example.com")
        #expect(bytes == Array<Byte>("user@example.com".utf8))
    }

    @Test
    func `RawValue is synthesized from serialization`() throws {
        let email = try CorrectEmailAddress("test@domain.org")

        // rawValue should be derived from serialize(ascii:into:)
        #expect(email.rawValue == "test@domain.org")
    }

    @Test
    func `Round-trip through rawValue`() throws {
        let original = try CorrectEmailAddress("hello@world.net")

        // rawValue → String → bytes → parse → compare
        let rawValue = original.rawValue
        let restored = try CorrectEmailAddress(rawValue)

        #expect(original == restored)
    }

    @Test
    func `Serialization does not access rawValue`() throws {
        let email = try CorrectEmailAddress("direct@serialize.test")

        // serialize(ascii:into:) should work without ever touching rawValue
        // ([Byte] for ASCII substrate)
        var buffer: [Byte] = []
        CorrectEmailAddress.serialize(ascii: email, into: &buffer)

        #expect(buffer == Array<Byte>("direct@serialize.test".utf8))
    }

    // MARK: - API Design Guidance

    @Test
    func `Checklist for Binary.ASCII.RawRepresentable conformance`() throws {
        // This test serves as documentation for the required pattern:
        //
        // ✅ 1. Implement serialize(ascii:into:) explicitly
        // ✅ 2. Do NOT use rawValue in serialize implementation
        // ✅ 3. Add `typealias RawValue = String` to RawRepresentable conformance
        // ✅ 4. Test that rawValue, description, and bytes all work

        let email = try CorrectEmailAddress("checklist@test.com")

        // All of these should work without recursion:
        #expect(email.rawValue == "checklist@test.com")
        #expect(email.description == "checklist@test.com")
        #expect(String(ascii: email) == "checklist@test.com")
        let bytes: [Byte] = email.bytes
        #expect(bytes == Array<Byte>("checklist@test.com".utf8))

        // [Byte] for ASCII substrate
        var buffer: [Byte] = []
        email.ascii.serialize(into: &buffer)
        #expect(buffer == Array<Byte>("checklist@test.com".utf8))
    }
}
