//
//  UInt8.ASCII.Serializable Tests.swift
//  swift-ascii
//
//  Serialization tests migrated off the retired `Binary.ASCII.Serializable`
//  tier (W4) onto `Binary.Serializable` (Byte substrate — the model the
//  package's own Sources landed on). Parsing is expressed as plain
//  initializers (`init(ascii:)`, `init(ascii:delimiter:)`), not a parse
//  protocol: the flat `ASCII.Parseable` is context-free and owned by L1, so
//  parameterized parses (a delimiter) are ordinary operation parameters.
//
//  ASCII byte constants / classifiers (`.ascii.hyphen`, `byte.ascii.isAlphanumeric`)
//  come from the live `ASCII_Primitives` module, unaffected by the tier retirement.
//

import Binary_Primitives
import ASCII
import Testing

// MARK: - Context-Free Type Example

/// A simple token type that requires no parsing context.
/// Serializes via `Binary.Serializable`; parses via a plain `init(ascii:)`.
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

extension Token: Binary.Serializable {
    static func serialize<Buffer>(_ token: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(contentsOf: token.rawValue.utf8)
    }
}

extension Token {
    /// Plain byte-parse convenience (context-free) — NOT a protocol requirement.
    init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        try self.init(String(decoding: bytes, as: UTF8.self))
    }
}

extension Token: Hashable {}
extension Token: CustomStringConvertible {
    var description: String { String(self) }
}
extension Token: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        // String literals in tests are known-valid tokens.
        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - Parameterized (Delimiter) Type Example

/// A message type whose parse takes a delimiter parameter.
/// Serializes via `Binary.Serializable` (self-describing, no parameter); parses
/// via a plain `init(ascii:delimiter:)` — the delimiter is an operation
/// parameter, so it lives on the initializer, not a parameter-free protocol.
struct DelimitedMessage: Sendable, Codable {
    let parts: [String]
    let delimiter: UInt8

    init(__unchecked: Void, parts: [String], delimiter: UInt8) {
        self.parts = parts
        self.delimiter = delimiter
    }
}

extension DelimitedMessage: Binary.Serializable {
    enum Error: Swift.Error, Sendable, Equatable {
        case empty
    }

    static func serialize<Buffer>(_ message: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        for (index, part) in message.parts.enumerated() {
            if index > 0 {
                // delimiter is UInt8 arithmetic-domain; wrap to byte-domain for append.
                buffer.append(Byte(message.delimiter))
            }
            buffer.append(contentsOf: part.utf8)
        }
    }
}

extension DelimitedMessage {
    /// Plain parameterized parse — the delimiter is an operation parameter,
    /// NOT a protocol requirement (the flat parse protocol is parameter-free).
    init<Bytes: Collection>(ascii bytes: Bytes, delimiter: UInt8) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else { throw .empty }

        // Split on delimiter
        var parts: [String] = []
        var current: [UInt8] = []

        for byte in bytes {
            // Delimiter is UInt8 in this test type; bridge byte-domain element
            // to UInt8 for arithmetic-domain equality.
            if byte.underlying == delimiter {
                parts.append(String(decoding: current, as: UTF8.self))
                current = []
            } else {
                current.append(byte.underlying)
            }
        }
        // Add final part
        parts.append(String(decoding: current, as: UTF8.self))

        self.init(__unchecked: (), parts: parts, delimiter: delimiter)
    }
}

extension DelimitedMessage: Hashable {}
extension DelimitedMessage: CustomStringConvertible {
    var description: String { String(self) }
}

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

        // `Token.serialize(_:)` (Binary.Serializable) returns `[Byte]`.
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

        let serialized: [Byte] = token.bytes
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

// MARK: - Parameterized Parsing Tests

@Suite("Serializable - Parameterized (Delimiter) Types")
struct ParameterizedSerializableTests {
    @Test
    func `Parse with delimiter using init(ascii:delimiter:)`() throws {
        let bytes: [Byte] = Array<Byte>("foo|bar|baz".utf8)

        let message = try DelimitedMessage(ascii: bytes, delimiter: .ascii.verticalLine)

        #expect(message.parts == ["foo", "bar", "baz"])
        #expect(message.delimiter == .ascii.verticalLine)
    }

    @Test
    func `Different delimiters produce different parses`() throws {
        let bytes: [Byte] = Array<Byte>("a,b|c".utf8)

        // Parse with comma delimiter
        let commaMessage = try DelimitedMessage(ascii: bytes, delimiter: .ascii.comma)
        #expect(commaMessage.parts == ["a", "b|c"])

        // Parse with pipe delimiter
        let pipeMessage = try DelimitedMessage(ascii: bytes, delimiter: .ascii.verticalLine)
        #expect(pipeMessage.parts == ["a,b", "c"])
    }

    @Test
    func `Serialize to bytes`() throws {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["hello", "world"],
            delimiter: .ascii.hyphen
        )

        // `DelimitedMessage.serialize(_:)` (Binary.Serializable) returns `[Byte]`.
        let serialized: [Byte] = DelimitedMessage.serialize(message)
        #expect(serialized == Array<Byte>("hello-world".utf8))
    }

    @Test
    func `Round-trip: bytes → Message → bytes`() throws {
        let original: [Byte] = Array<Byte>("one:two:three".utf8)

        let message = try DelimitedMessage(ascii: original, delimiter: .ascii.colon)

        let serialized: [Byte] = message.bytes
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

        #expect(throws: DelimitedMessage.Error.empty) {
            try DelimitedMessage(ascii: bytes, delimiter: .ascii.comma)
        }
    }

    @Test
    func `Parameterized type requires a delimiter (no unparameterized init)`() {
        // The parse is parameterized: a delimiter is always required.
        // The following would not compile — there is no `init(_ String)` and
        // no unparameterized `init(ascii:)`:
        //   let message = try DelimitedMessage("a,b,c")  // Error: no delimiter!

        // Instead, you must provide the delimiter:
        let bytes: [Byte] = Array<Byte>("a,b,c".utf8)
        let message = try? DelimitedMessage(ascii: bytes, delimiter: .ascii.comma)

        #expect(message != nil)
    }
}

// MARK: - Serialization Behavior Properties

@Suite("Serializable - Serialization Behavior Properties")
struct SerializationBehaviorTests {
    @Test
    func `Serialization is context-free (value is self-describing)`() throws {
        // Even for parameterized-parse types, serialization needs no parameter.
        // The value itself contains all information needed to serialize.

        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["x", "y"],
            delimiter: .ascii.comma
        )

        // Serialize without needing any parameter:
        let serialized: [Byte] = DelimitedMessage.serialize(message)
        #expect(serialized == Array<Byte>("x,y".utf8))
    }

    @Test
    func `Parse-serialize round-trip is identity (for well-formed input)`() throws {
        // For well-formed input, parse ∘ serialize = id
        let original: [Byte] = Array<Byte>("valid-token".utf8)

        let token: Token = try .init(ascii: original)
        let serialized: [Byte] = token.bytes
        #expect(serialized == original)
    }
}

// MARK: - Binary.Serializable Conformance Tests

/// Example HTML-like element that composes with `Binary.Serializable` types.
/// Demonstrates how streaming types can embed ASCII-serializing types seamlessly.
///
/// `HTMLAnchor` is a pure `Binary.Serializable` (Byte substrate). The `.utf8`
/// appends go through the BSLI `append(contentsOf: Sequence<UInt8>)` bridge.
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

    // MARK: - Direct Conformance

    @Test
    func `Token conforms to Binary.Serializable directly and serializes`() throws {
        let token: Token = try .init("my-token")

        // Token conforms to Binary.Serializable directly (Byte substrate).
        var buffer: [Byte] = []
        token.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("my-token".utf8))
    }

    @Test
    func `Parameterized type conforms to Binary.Serializable directly and serializes`() {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b", "c"],
            delimiter: .ascii.comma
        )

        // DelimitedMessage conforms to Binary.Serializable directly.
        var buffer: [Byte] = []
        message.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("a,b,c".utf8))
    }

    // MARK: - Buffer-Based Serialization

    @Test
    func `Serialize into buffer using serialize(into:)`() throws {
        let token: Token = try .init("hello-world")

        // Ideal streaming usage pattern ([Byte] buffer).
        var buffer: [Byte] = []
        token.serialize(into: &buffer)

        #expect(buffer == Array<Byte>("hello-world".utf8))
    }

    @Test
    func `Get bytes using .bytes property`() throws {
        let token: Token = try .init("swift-token")

        // `.bytes` convenience from Binary.Serializable returns `[Byte]`.
        let bytes: [Byte] = token.bytes

        #expect(bytes == Array<Byte>("swift-token".utf8))
    }

    @Test
    func `Append to existing buffer content`() throws {
        let token: Token = try .init("suffix")

        var buffer: [Byte] = Array<Byte>("prefix-".utf8)
        token.serialize(into: &buffer)

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

        // Accumulate all into one buffer ([Byte])
        var buffer: [Byte] = []
        token1.serialize(into: &buffer)
        buffer.append(Byte.ascii.hyphen)
        token2.serialize(into: &buffer)
        buffer.append(Byte.ascii.verticalLine)
        message.serialize(into: &buffer)

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
            token.serialize(into: &buffer)
        }

        let result = String(decoding: buffer, as: UTF8.self)
        #expect(result.hasPrefix("token-1,token-2"))
        #expect(result.hasSuffix("token-10"))
    }

    // MARK: - Round-Trip via Streaming

    @Test
    func `Round-trip through buffer produces same result as static serialize`() throws {
        let token: Token = try .init("roundtrip-test")

        // Via static Binary.Serializable (returns [Byte]).
        let staticBytes: [Byte] = Token.serialize(token)

        // Via streaming serialize(into:) ([Byte]).
        var streamingBuffer: [Byte] = []
        token.serialize(into: &streamingBuffer)

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
        // Simulating building an HTTP-like response ([Byte])
        var response: [Byte] = []

        // Add header
        response.append(contentsOf: "X-Token: ".utf8)
        let token: Token = try .init("auth-token-123")
        token.serialize(into: &response)
        response.append(contentsOf: "\r\n".utf8)

        let result = String(decoding: response, as: UTF8.self)
        #expect(result == "X-Token: auth-token-123\r\n")
    }

    @Test
    func `Pattern: Building HTML with embedded types`() throws {
        let anchor = try HTMLAnchor(
            href: .init("https-link"),
            text: "Visit site"
        )

        // Get bytes for HTTP response (Binary.Serializable, [Byte]).
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
            token.serialize(into: &buffer)
            results.append(buffer)
        }

        #expect(results.count == 3)
        #expect(results[0] == Array<Byte>("alpha".utf8))
        #expect(results[1] == Array<Byte>("beta".utf8))
        #expect(results[2] == Array<Byte>("gamma".utf8))
    }

    @Test
    func `Pattern: Streaming type wrapping ASCII type`() throws {
        // HTMLAnchor is a streaming type that wraps Token
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

/// Example type demonstrating the CORRECT pattern for a `Binary.Serializable`
/// type that also conforms to `Swift.RawRepresentable` with a `String` raw value
/// derived from serialization.
///
/// Such a type MUST implement `serialize(_:into:)` explicitly. Relying on the
/// `Binary.Serializable where Self: RawRepresentable, RawValue: StringProtocol`
/// default (which serializes `rawValue.utf8`) would recurse when `rawValue` is
/// itself derived from serialization (`String(self)`):
///   rawValue → String(self) → serialize (default) → rawValue → …
private struct CorrectEmailAddress: Sendable, Codable, Hashable {
    let localPart: String
    let domain: String

    init(__unchecked: Void, localPart: String, domain: String) {
        self.localPart = localPart
        self.domain = domain
    }
}

extension CorrectEmailAddress: Binary.Serializable {
    enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case missingAtSign
    }

    /// CORRECT: Explicit serialize implementation that does NOT use `rawValue`.
    ///
    /// This is REQUIRED because the `RawRepresentable`-defaulted serialize would
    /// read `rawValue` (= `String(self)` = serialize), causing infinite recursion.
    static func serialize<Buffer: RangeReplaceableCollection>(
        _ email: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: email.localPart.utf8)
        buffer.append(Byte.ascii.commercialAt)
        buffer.append(contentsOf: email.domain.utf8)
    }
}

extension CorrectEmailAddress {
    /// Plain byte-parse convenience (context-free).
    init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
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

    init(_ value: String) throws(Error) {
        try self.init(ascii: [Byte](value.utf8))
    }
}

extension CorrectEmailAddress: Swift.RawRepresentable {
    /// Raw value derived from serialization (not stored).
    var rawValue: String { String(self) }

    init?(rawValue: String) {
        try? self.init(rawValue)
    }
}

extension CorrectEmailAddress: CustomStringConvertible {
    var description: String { String(self) }
}

@Suite("Serializable - Infinite Recursion Prevention")
struct InfiniteRecursionPreventionTests {

    // MARK: - Documentation of the Problem

    /// Documents the infinite-recursion hazard for a `Binary.Serializable` type
    /// that also conforms to `Swift.RawRepresentable` (`RawValue: StringProtocol`)
    /// with a `rawValue` derived from serialization, WITHOUT an explicit
    /// `serialize(_:into:)`.
    ///
    /// ## Why It Crashes
    ///
    /// 1. `rawValue` (derived) evaluates `String(self)`, which serializes.
    /// 2. The `RawRepresentable`-defaulted `serialize(_:into:)` reads `rawValue.utf8`.
    /// 3. That reads `rawValue` again → INFINITE RECURSION → stack overflow.
    ///
    /// ## The Solution
    ///
    /// Provide an explicit `serialize(_:into:)` that serializes from stored
    /// properties, NOT from `rawValue`.
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
    func `RawValue is derived from serialization`() throws {
        let email = try CorrectEmailAddress("test@domain.org")

        // rawValue should be derived from serialize(_:into:)
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

        // serialize(_:into:) should work without ever touching rawValue ([Byte])
        var buffer: [Byte] = []
        CorrectEmailAddress.serialize(email, into: &buffer)

        #expect(buffer == Array<Byte>("direct@serialize.test".utf8))
    }

    // MARK: - API Design Guidance

    @Test
    func `Checklist for Binary.Serializable + RawRepresentable conformance`() throws {
        // This test serves as documentation for the required pattern:
        //
        // ✅ 1. Implement serialize(_:into:) explicitly
        // ✅ 2. Do NOT use rawValue in serialize implementation
        // ✅ 3. Add `Swift.RawRepresentable` with a derived `rawValue`
        // ✅ 4. Test that rawValue, description, and bytes all work

        let email = try CorrectEmailAddress("checklist@test.com")

        // All of these should work without recursion:
        #expect(email.rawValue == "checklist@test.com")
        #expect(email.description == "checklist@test.com")
        #expect(String(email) == "checklist@test.com")
        let bytes: [Byte] = email.bytes
        #expect(bytes == Array<Byte>("checklist@test.com".utf8))

        // [Byte] buffer
        var buffer: [Byte] = []
        email.serialize(into: &buffer)
        #expect(buffer == Array<Byte>("checklist@test.com".utf8))
    }
}
