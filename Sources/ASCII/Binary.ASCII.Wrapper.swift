//
//  Binary.ASCII.Wrapper.swift
//  swift-ascii
//
//  Wrapper for ASCII serializable types providing instance-level access.

public import Binary_Primitives

extension Binary.ASCII {
    /// Wrapper for ASCII serializable types
    ///
    /// Provides instance-level access to ASCII serialization methods.
    /// This wrapper enables the syntax `value.ascii.serialize(into:)` for types
    /// that have both binary and ASCII serializations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // For types with both binary and ASCII serialization:
    /// let address = try RFC_791.IPv4.Address("192.168.1.1")
    ///
    /// var binaryBuffer: [UInt8] = []
    /// address.serialize(into: &binaryBuffer)  // Binary: [192, 168, 1, 1]
    ///
    /// var asciiBuffer: [UInt8] = []
    /// address.ascii.serialize(into: &asciiBuffer)  // ASCII: "192.168.1.1"
    /// ```
    ///
    /// ## Category Theory
    ///
    /// This wrapper enables explicit selection of the ASCII serialization functor
    /// when multiple serialization morphisms are available:
    /// - `serialize(into:)` → binary bytes (for types with binary representation)
    /// - `ascii.serialize(into:)` → ASCII text representation
    public struct Wrapper<Wrapped: Binary.ASCII.Serializable>: Sendable where Wrapped: Sendable {
        /// The wrapped value
        public let wrapped: Wrapped

        /// Creates a wrapper around the given value
        @inlinable
        init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}

// MARK: - Wrapper Serialization Methods

extension Binary.ASCII.Wrapper {
    /// Serialize the wrapped value into an ASCII byte buffer
    ///
    /// - Parameter buffer: The buffer to append ASCII bytes to
    @inlinable
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        Wrapped.serialize(ascii: wrapped, into: &buffer)
    }

    /// Serialize to a new ASCII byte array
    ///
    /// - Returns: A new `[UInt8]` containing the ASCII representation
    @inlinable
    public var bytes: [UInt8] {
        var buffer: [UInt8] = []
        serialize(into: &buffer)
        return buffer
    }

    /// Provides zero-copy access to ASCII-serialized bytes via a Span.
    ///
    /// Enables `.ascii.withSerializedBytes { ... }` syntax.
    @inlinable
    public func withSerializedBytes<R, E: Error>(
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        var buffer: ContiguousArray<UInt8> = []
        Wrapped.serialize(ascii: wrapped, into: &buffer)
        var result: Result<R, E>!
        buffer.withUnsafeBufferPointer { bufferPointer in
            let span = Span(_unsafeElements: bufferPointer)
            do throws(E) {
                result = .success(try body(span))
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }
}

extension Binary.ASCII.Wrapper: CustomStringConvertible {
    /// The ASCII string representation
    @inlinable
    public var description: String {
        String(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - Serializable Extension

extension Binary.ASCII.Serializable where Self: Sendable {
    /// Access ASCII serialization wrapper
    ///
    /// Returns a wrapper that provides instance-level access to ASCII serialization.
    /// Use this when the type has both binary and ASCII serializations, and you need
    /// to explicitly select ASCII serialization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = try RFC_791.IPv4.Address("192.168.1.1")
    ///
    /// // Binary serialization (4 bytes)
    /// var binary: [UInt8] = []
    /// address.serialize(into: &binary)
    ///
    /// // ASCII serialization (dotted-decimal string)
    /// var ascii: [UInt8] = []
    /// address.ascii.serialize(into: &ascii)
    /// ```
    @inlinable
    public var ascii: Binary.ASCII.Wrapper<Self> {
        Binary.ASCII.Wrapper(self)
    }
}
