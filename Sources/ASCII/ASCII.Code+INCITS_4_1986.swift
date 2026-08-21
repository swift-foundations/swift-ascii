public import ASCII_Primitives
public import ASCII_Primitives_Standard_Library_Integration

extension ASCII.Code {

    @inlinable
    public func callAsFunction(case: Character.Case) -> UInt8 {
        INCITS_4_1986.Case.Conversion.convert(underlying, to: `case`)
    }
}
