import Testing

@testable import ASCII

@Suite
struct `INCITS_4_1986.FormatEffectors.Line.Ending` {
    @Suite
    struct `INCITS_4_1986.FormatEffectors.Line.Ending - Constants` {
        @Test(arguments: [
            (INCITS_4_1986.FormatEffectors.Line.Ending.lf, "LF", [ASCII.Code.lf]),
            (INCITS_4_1986.FormatEffectors.Line.Ending.cr, "CR", [ASCII.Code.cr]),
            (
                INCITS_4_1986.FormatEffectors.Line.Ending.crlf, "CRLF",
                [ASCII.Code.cr, ASCII.Code.lf]
            ),
        ])
        func `line ending conversions to codes`(
            ending: INCITS_4_1986.FormatEffectors.Line.Ending,
            name: String,
            expected: [ASCII.Code]
        ) {
            #expect([ASCII.Code](ascii: ending) == expected, "\(name) should produce correct codes")
        }

        @Test(arguments: [
            (INCITS_4_1986.FormatEffectors.Line.Ending.lf, "\n"),
            (INCITS_4_1986.FormatEffectors.Line.Ending.cr, "\r"),
            (INCITS_4_1986.FormatEffectors.Line.Ending.crlf, "\r\n"),
        ])
        func `line ending conversions to string`(
            ending: INCITS_4_1986.FormatEffectors.Line.Ending,
            expected: String
        ) {
            #expect(String(ascii: ending) == expected)
        }

        @Test
        func `line ending round-trip through codes`() {
            for ending in [INCITS_4_1986.FormatEffectors.Line.Ending.lf, .cr, .crlf] {
                let codes = [ASCII.Code](ascii: ending)
                let string = String(ascii: codes)
                let expectedString = String(ascii: ending)
                #expect(string == expectedString)
            }
        }
    }
}
