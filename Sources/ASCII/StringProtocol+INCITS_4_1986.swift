public import ASCII_Primitives
public import Binary_Primitives

extension StringProtocol {
    public typealias ASCII = INCITS_4_1986.ASCII<Self>

    public static var ascii: ASCII.Type {
        ASCII.self
    }

    @inlinable
    public var ascii: ASCII {
        INCITS_4_1986.ASCII(self)
    }
}

extension StringProtocol {

    public static func normalized<S: StringProtocol>(
        _ s: S,
        to lineEnding: INCITS_4_1986.FormatEffectors.Line.Ending
    ) -> S {
        return .init(
            decoding: INCITS_4_1986.normalized([UInt8](s.utf8), to: lineEnding),
            as: UTF8.self
        )
    }

    public func normalized(
        to lineEnding: INCITS_4_1986.FormatEffectors.Line.Ending
    ) -> Self {
        Self.normalized(self, to: lineEnding)
    }
}

extension StringProtocol {

    public init(ascii lineEnding: INCITS_4_1986.FormatEffectors.Line.Ending) {

        let codes = [ASCII_Primitives.ASCII.Code](ascii: lineEnding)
        self.init(decoding: codes.lazy.map(\.underlying), as: UTF8.self)
    }
}

extension StringProtocol {

    public init?(ascii bytes: [Byte]) {

        guard bytes.allSatisfy({ $0.underlying < 0x80 }) else { return nil }
        self.init(decoding: bytes.lazy.map(\.underlying), as: UTF8.self)
    }

    @inlinable
    public init<Codes: Sequence>(ascii codes: Codes)
    where Codes.Element == ASCII_Primitives.ASCII.Code {
        self.init(decoding: codes.lazy.map(\.underlying), as: UTF8.self)
    }

    public init?(ascii byte: Byte) {

        guard byte.underlying < 0x80 else { return nil }
        self.init(decoding: CollectionOfOne(byte.underlying), as: UTF8.self)
    }
}

extension StringProtocol {

    @_transparent
    public init<T: Binary.Serializable>(_ value: T) {

        let typed: [Byte] = value.bytes
        self = Self(decoding: typed.underlying, as: UTF8.self)
    }
}
