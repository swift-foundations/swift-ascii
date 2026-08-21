import ASCII
import Binary_Primitives
import Testing

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

        self.init(__unchecked: (), rawValue: value)
    }
}

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

                buffer.append(Byte(message.delimiter))
            }
            buffer.append(contentsOf: part.utf8)
        }
    }
}

extension DelimitedMessage {

    init<Bytes: Collection>(ascii bytes: Bytes, delimiter: UInt8) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else { throw .empty }

        var parts: [String] = []
        var current: [UInt8] = []

        for byte in bytes {

            if byte.underlying == delimiter {
                parts.append(String(decoding: current, as: UTF8.self))
                current = []
            } else {
                current.append(byte.underlying)
            }
        }

        parts.append(String(decoding: current, as: UTF8.self))

        self.init(__unchecked: (), parts: parts, delimiter: delimiter)
    }
}

extension DelimitedMessage: Hashable {}
extension DelimitedMessage: CustomStringConvertible {
    var description: String { String(self) }
}

extension Token {
    @Suite
    struct Test {
        @Test
        func `Parse from bytes using init(ascii:)`() throws {
            let bytes: [Byte] = [Byte]("hello-world".utf8)
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

            let serialized: [Byte] = Token.serialize(token)
            #expect(serialized == [Byte]("hello".utf8))
        }

        @Test
        func `Convert to String`() throws {
            let token: Token = try .init("world")

            #expect(String(token) == "world")
        }

        @Test
        func `Round-trip: bytes → Token → bytes`() throws {
            let original: [Byte] = [Byte]("round-trip".utf8)
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
            let bytes: [Byte] = [Byte]("hello world".utf8)

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
}

extension DelimitedMessage {
    @Suite
    struct Test {
        @Test
        func `Parse with delimiter using init(ascii:delimiter:)`() throws {
            let bytes: [Byte] = [Byte]("foo|bar|baz".utf8)

            let message = try DelimitedMessage(ascii: bytes, delimiter: .ascii.verticalLine)

            #expect(message.parts == ["foo", "bar", "baz"])
            #expect(message.delimiter == .ascii.verticalLine)
        }

        @Test
        func `Different delimiters produce different parses`() throws {
            let bytes: [Byte] = [Byte]("a,b|c".utf8)

            let commaMessage = try DelimitedMessage(ascii: bytes, delimiter: .ascii.comma)
            #expect(commaMessage.parts == ["a", "b|c"])

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

            let serialized: [Byte] = DelimitedMessage.serialize(message)
            #expect(serialized == [Byte]("hello-world".utf8))
        }

        @Test
        func `Round-trip: bytes → Message → bytes`() throws {
            let original: [Byte] = [Byte]("one:two:three".utf8)

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

            let bytes: [Byte] = [Byte]("a,b,c".utf8)
            let message = try? DelimitedMessage(ascii: bytes, delimiter: .ascii.comma)

            #expect(message != nil)
        }
    }
}

@Suite
struct SerializationBehaviorTests {
    @Test
    func `Serialization is context-free (value is self-describing)`() throws {

        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["x", "y"],
            delimiter: .ascii.comma
        )

        let serialized: [Byte] = DelimitedMessage.serialize(message)
        #expect(serialized == [Byte]("x,y".utf8))
    }

    @Test
    func `Parse-serialize round-trip is identity (for well-formed input)`() throws {

        let original: [Byte] = [Byte]("valid-token".utf8)

        let token: Token = try .init(ascii: original)
        let serialized: [Byte] = token.bytes
        #expect(serialized == original)
    }
}

private struct HTMLAnchor: Binary.Serializable {
    let href: Token
    let text: String
}

extension HTMLAnchor {
    static func serialize<Buffer>(_ anchor: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == Byte {
        buffer.append(contentsOf: "<a href=\"".utf8)
        Token.serialize(anchor.href, into: &buffer)
        buffer.append(contentsOf: "\">".utf8)
        buffer.append(contentsOf: anchor.text.utf8)
        buffer.append(contentsOf: "</a>".utf8)
    }
}

@Suite
struct DirectConformanceTests {

    @Test
    func `Token conforms to Binary.Serializable directly and serializes`() throws {
        let token: Token = try .init("my-token")

        var buffer: [Byte] = []
        token.serialize(into: &buffer)

        #expect(buffer == [Byte]("my-token".utf8))
    }

    @Test
    func `Parameterized type conforms to Binary.Serializable directly and serializes`() {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b", "c"],
            delimiter: .ascii.comma
        )

        var buffer: [Byte] = []
        message.serialize(into: &buffer)

        #expect(buffer == [Byte]("a,b,c".utf8))
    }

    @Test
    func `Serialize into buffer using serialize(into:)`() throws {
        let token: Token = try .init("hello-world")

        var buffer: [Byte] = []
        token.serialize(into: &buffer)

        #expect(buffer == [Byte]("hello-world".utf8))
    }

    @Test
    func `Get bytes using .bytes property`() throws {
        let token: Token = try .init("swift-token")

        let bytes: [Byte] = token.bytes

        #expect(bytes == [Byte]("swift-token".utf8))
    }

    @Test
    func `Append to existing buffer content`() throws {
        let token: Token = try .init("suffix")

        var buffer: [Byte] = [Byte]("prefix-".utf8)
        token.serialize(into: &buffer)

        #expect(buffer == [Byte]("prefix-suffix".utf8))
    }

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

        var buffer: [Byte] = []
        token1.serialize(into: &buffer)
        buffer.append(Byte.ascii.hyphen)
        token2.serialize(into: &buffer)
        buffer.append(Byte.ascii.verticalLine)
        message.serialize(into: &buffer)

        #expect(buffer == [Byte]("first-second|a:b".utf8))
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

    @Test
    func `Round-trip through buffer produces same result as static serialize`() throws {
        let token: Token = try .init("roundtrip-test")

        let staticBytes: [Byte] = Token.serialize(token)

        var streamingBuffer: [Byte] = []
        token.serialize(into: &streamingBuffer)

        let propertyBytes: [Byte] = token.bytes

        #expect(staticBytes == streamingBuffer)
        #expect(staticBytes == propertyBytes)
    }
}

@Suite
struct APIPatternTests {

    @Test
    func `Pattern: Direct buffer writing for server response`() throws {

        var response: [Byte] = []

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

        let bytes: [Byte] = anchor.bytes

        let string = String(anchor)

        #expect(bytes == [Byte](string.utf8))
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
        #expect(results[0] == [Byte]("alpha".utf8))
        #expect(results[1] == [Byte]("beta".utf8))
        #expect(results[2] == [Byte]("gamma".utf8))
    }

    @Test
    func `Pattern: Streaming type wrapping ASCII type`() throws {

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

    var rawValue: String { String(self) }

    init?(rawValue: String) {
        try? self.init(rawValue)
    }
}

extension CorrectEmailAddress: CustomStringConvertible {
    var description: String { String(self) }
}

extension CorrectEmailAddress {
    @Suite
    struct Test {

        @Test
        func `Correct pattern avoids infinite recursion`() throws {
            let email = try CorrectEmailAddress("user@example.com")

            let rawValue = email.rawValue
            let description = email.description
            let bytes: [Byte] = email.bytes

            #expect(rawValue == "user@example.com")
            #expect(description == "user@example.com")
            #expect(bytes == [Byte]("user@example.com".utf8))
        }

        @Test
        func `RawValue is derived from serialization`() throws {
            let email = try CorrectEmailAddress("test@domain.org")

            #expect(email.rawValue == "test@domain.org")
        }

        @Test
        func `Round-trip through rawValue`() throws {
            let original = try CorrectEmailAddress("hello@world.net")

            let rawValue = original.rawValue
            let restored = try CorrectEmailAddress(rawValue)

            #expect(original == restored)
        }

        @Test
        func `Serialization does not access rawValue`() throws {
            let email = try CorrectEmailAddress("direct@serialize.test")

            var buffer: [Byte] = []
            CorrectEmailAddress.serialize(email, into: &buffer)

            #expect(buffer == [Byte]("direct@serialize.test".utf8))
        }

        @Test
        func `Checklist for Binary.Serializable + RawRepresentable conformance`() throws {

            let email = try CorrectEmailAddress("checklist@test.com")

            #expect(email.rawValue == "checklist@test.com")
            #expect(email.description == "checklist@test.com")
            #expect(String(email) == "checklist@test.com")
            let bytes: [Byte] = email.bytes
            #expect(bytes == [Byte]("checklist@test.com".utf8))

            var buffer: [Byte] = []
            email.serialize(into: &buffer)
            #expect(buffer == [Byte]("checklist@test.com".utf8))
        }
    }
}
