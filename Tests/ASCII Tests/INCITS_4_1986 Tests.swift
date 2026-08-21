import Testing

@testable import ASCII

@Suite
struct `INCITS_4_1986 - Constants Tests` {
    @Test
    func `whitespaces set contains exactly 4 characters`() {
        #expect(INCITS_4_1986.whitespaces.count == 4)
    }

    @Test
    func `whitespaces contains SPACE, TAB, LF, CR`() {
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.sp))
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.htab))
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.lf))
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.cr))
    }

    @Test
    func `CRLF sequence is correct`() {
        #expect(INCITS_4_1986.Character.Control.crlf == [UInt8.ascii.cr, UInt8.ascii.lf])
    }

    @Test
    func `case conversion offset is 0x20`() {
        #expect(INCITS_4_1986.Case.Conversion.offset == UInt8.ascii.sp)
        #expect(INCITS_4_1986.Case.Conversion.offset == 32)
    }

    @Test
    func `case conversion offset matches letter distance`() {

        #expect(
            ASCII.Code.a.underlying &- ASCII.Code.A.underlying
                == INCITS_4_1986.Case.Conversion.offset
        )
    }
}
