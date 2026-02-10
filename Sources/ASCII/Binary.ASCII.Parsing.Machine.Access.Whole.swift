// Binary.ASCII.Parsing.Machine.Access.Whole.swift
// Zero-copy whole-input parsing wrapper for Machine parsers

public import Binary_Parser_Primitives

extension Binary.ASCII.Parsing.Machine.Access {
    /// Whole-input parsing capability for Machine parsers.
    ///
    /// Enforces that all input must be consumed by checking the consumed count
    /// at execution time. Uses `withBorrowed.whole` for zero-copy execution.
    public struct Whole {
        @usableFromInline
        internal let parser: Binary.Bytes.Machine.Parser<Output>

        @inlinable
        internal init(_ parser: Binary.Bytes.Machine.Parser<Output>) {
            self.parser = parser
        }
    }
}

extension Binary.ASCII.Parsing.Machine.Access.Whole {
    /// Parse entire byte array.
    ///
    /// Uses zero-copy borrowed path. Fails if any bytes remain after parsing.
    ///
    /// - Parameter bytes: The bytes to parse.
    /// - Returns: The parsed value.
    /// - Throws: `Machine.Fault` if parsing fails or input remains.
    @inlinable
    public func call(_ bytes: [UInt8]) throws(Binary.Bytes.Machine.Fault) -> Output {
        try Binary.Bytes.withBorrowed.whole(bytes, parser)
    }

    /// Parse entire string (UTF-8).
    ///
    /// Uses zero-copy borrowed path. Fails if any bytes remain after parsing.
    ///
    /// - Parameter string: The string to parse.
    /// - Returns: The parsed value.
    /// - Throws: `Machine.Fault` if parsing fails or input remains.
    @inlinable
    public func call(_ string: some StringProtocol) throws(Binary.Bytes.Machine.Fault) -> Output {
        try call(Array(string.utf8))
    }
}
