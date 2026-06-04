// Binary.ASCII.Parsing.Machine+call.swift
// Zero-copy borrowed parsing APIs for Machine parsers

public import Binary_Parser_Primitives
internal import Memory_Primitives
// W3 PRUNE: the binary parse engine re-homed from `Binary.Borrowed` (deleted)
// to `Span.`Protocol` where Element == Byte`; calling `.parse` on a
// `Swift.Span<Byte>` needs the `Swift.Span: Span.`Protocol``
// conformance in scope (Finding 3/8).
public import Span_Protocol_Primitives

// MARK: - Direct withBorrowed APIs

extension Binary.ASCII.Parsing.Machine {
    /// Parse bytes using zero-copy borrowed path.
    @inlinable
    public static func parse<Output>(
        _ bytes: [Byte],
        with parser: Binary_Parser_Primitives.Binary.Machine.Parser<Output>
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> Output {
        try Binary_Parser_Primitives.Binary(bytes).parse(parser)
    }

    /// Parse contiguous storage using zero-copy borrowed path.
    @inlinable
    public static func parse<C: Span.`Protocol`, Output>(
        _ source: borrowing C,
        with parser: Binary_Parser_Primitives.Binary.Machine.Parser<Output>
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> Output
    where C: ~Copyable, C.Element == Byte {
        // W3 PRUNE: the borrowed view IS the source's Swift.Span<Byte>.
        try source.span.parse(parser)
    }

    /// Parse string (UTF-8) using zero-copy borrowed path.
    @inlinable
    public static func parse<Output>(
        _ string: some StringProtocol,
        with parser: Binary_Parser_Primitives.Binary.Machine.Parser<Output>
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> Output {
        let bytes: [Byte] = .init(string.utf8)
        return try parse(bytes, with: parser)
    }
}

// MARK: - Convenience Integer Parsing

extension Binary.ASCII.Parsing.Machine {
    /// Parse an unsigned decimal integer from bytes.
    @inlinable
    public static func parseUnsignedDecimal<T: UnsignedInteger & FixedWidthInteger & Sendable>(
        _ bytes: [Byte],
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> T {
        try parse(bytes, with: Decimal.unsigned(type))
    }

    /// Parse an unsigned decimal integer from a string.
    @inlinable
    public static func parseUnsignedDecimal<T: UnsignedInteger & FixedWidthInteger & Sendable>(
        _ string: some StringProtocol,
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> T {
        try parse(string, with: Decimal.unsigned(type))
    }

    /// Parse a signed decimal integer from bytes.
    @inlinable
    public static func parseSignedDecimal<T: SignedInteger & FixedWidthInteger & Sendable>(
        _ bytes: [Byte],
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> T {
        try parse(bytes, with: Decimal.signed(type))
    }

    /// Parse a signed decimal integer from a string.
    @inlinable
    public static func parseSignedDecimal<T: SignedInteger & FixedWidthInteger & Sendable>(
        _ string: some StringProtocol,
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> T {
        try parse(string, with: Decimal.signed(type))
    }
}
