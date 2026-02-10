// Binary.ASCII.Parsing.Machine+call.swift
// Zero-copy borrowed parsing APIs for Machine parsers

public import Binary_Parser_Primitives

// MARK: - Direct withBorrowed APIs

extension Binary.ASCII.Parsing.Machine {
    /// Parse bytes using zero-copy borrowed path.
    ///
    /// This is the most efficient parsing path, with no copying or allocation
    /// for the input data. The parser runs directly on borrowed memory.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to parse.
    ///   - parser: The Machine parser to execute.
    /// - Returns: The parsed value.
    /// - Throws: `Machine.Fault` on parsing failure.
    @inlinable
    public static func parse<Output>(
        _ bytes: [UInt8],
        with parser: Binary_Parser_Primitives.Binary.Bytes.Machine.Parser<Output>
    ) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> Output {
        try Binary_Parser_Primitives.Binary.Bytes.withBorrowed(bytes, parser)
    }

    /// Parse string (UTF-8) using zero-copy borrowed path.
    ///
    /// - Parameters:
    ///   - string: The string to parse (UTF-8 encoded).
    ///   - parser: The Machine parser to execute.
    /// - Returns: The parsed value.
    /// - Throws: `Machine.Fault` on parsing failure.
    @inlinable
    public static func parse<Output>(
        _ string: some StringProtocol,
        with parser: Binary_Parser_Primitives.Binary.Bytes.Machine.Parser<Output>
    ) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> Output {
        try parse(Array(string.utf8), with: parser)
    }
}

// MARK: - Convenience Integer Parsing

extension Binary.ASCII.Parsing.Machine {
    /// Parse an unsigned decimal integer from bytes.
    ///
    /// Uses zero-copy borrowed parsing with the `fold` combinator for
    /// zero-allocation accumulation.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to parse.
    ///   - type: The unsigned integer type to parse into.
    /// - Returns: The parsed unsigned integer.
    /// - Throws: `Machine.Fault` if parsing fails.
    @inlinable
    public static func parseUnsignedDecimal<T: UnsignedInteger & FixedWidthInteger & Sendable>(
        _ bytes: [UInt8],
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> T {
        try parse(bytes, with: Decimal.unsigned(type))
    }

    /// Parse an unsigned decimal integer from a string.
    ///
    /// - Parameters:
    ///   - string: The string to parse (UTF-8 encoded).
    ///   - type: The unsigned integer type to parse into.
    /// - Returns: The parsed unsigned integer.
    /// - Throws: `Machine.Fault` if parsing fails.
    @inlinable
    public static func parseUnsignedDecimal<T: UnsignedInteger & FixedWidthInteger & Sendable>(
        _ string: some StringProtocol,
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> T {
        try parse(string, with: Decimal.unsigned(type))
    }

    /// Parse a signed decimal integer from bytes.
    ///
    /// Uses zero-copy borrowed parsing with the `fold` combinator for
    /// zero-allocation accumulation.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to parse.
    ///   - type: The signed integer type to parse into.
    /// - Returns: The parsed signed integer.
    /// - Throws: `Machine.Fault` if parsing fails.
    @inlinable
    public static func parseSignedDecimal<T: SignedInteger & FixedWidthInteger & Sendable>(
        _ bytes: [UInt8],
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> T {
        try parse(bytes, with: Decimal.signed(type))
    }

    /// Parse a signed decimal integer from a string.
    ///
    /// - Parameters:
    ///   - string: The string to parse (UTF-8 encoded).
    ///   - type: The signed integer type to parse into.
    /// - Returns: The parsed signed integer.
    /// - Throws: `Machine.Fault` if parsing fails.
    @inlinable
    public static func parseSignedDecimal<T: SignedInteger & FixedWidthInteger & Sendable>(
        _ string: some StringProtocol,
        as type: T.Type = T.self
    ) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> T {
        try parse(string, with: Decimal.signed(type))
    }
}
