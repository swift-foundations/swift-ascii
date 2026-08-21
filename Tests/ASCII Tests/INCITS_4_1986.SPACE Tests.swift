import Testing

@testable import ASCII

@Suite
struct `SPACE` {

    @Suite
    struct `Character Tests` {
        @Test
        func `SPACE constant is 0x20`() {
            #expect(INCITS_4_1986.SPACE.sp == 0x20)
            #expect(UInt8.ascii.sp == 0x20)
        }

        @Test
        func `SPACE is recognized as whitespace`() {
            let sp = UInt8.ascii.sp
            #expect(sp.isWhitespace)
        }

        @Test
        func `SPACE is printable`() {
            let sp = UInt8.ascii.sp
            #expect(sp.isPrintable)
        }

        @Test
        func `SPACE is not a control character`() {
            let sp = UInt8.ascii.sp
            #expect(!sp.isControl)
        }

        @Test
        func `SPACE is not visible (visible = graphic characters only)`() {
            let sp = UInt8.ascii.sp
            #expect(!sp.isVisible, "SPACE is printable but not visible (visible = 0x21-0x7E)")
        }

        @Test
        func `SPACE accessible directly without namespace`() {
            #expect(UInt8.ascii.sp == INCITS_4_1986.SPACE.sp)
        }
    }
}
