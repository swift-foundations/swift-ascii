// INCITS_4_1986.FormatEffectors.Line.Ending+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986.FormatEffectors.Line.Ending support

import Testing
@testable import ASCII

// MARK: - Line Ending Constants

@Suite
struct `INCITS_4_1986.FormatEffectors.Line.Ending` {
    @Suite
    struct `INCITS_4_1986.FormatEffectors.Line.Ending - Constants` {
        @Test(arguments: [
            (INCITS_4_1986.FormatEffectors.Line.Ending.lf, "LF", [UInt8.ascii.lf]),
            (INCITS_4_1986.FormatEffectors.Line.Ending.cr, "CR", [UInt8.ascii.cr]),
            (INCITS_4_1986.FormatEffectors.Line.Ending.crlf, "CRLF", [UInt8.ascii.cr, UInt8.ascii.lf]),
        ])
        func `line ending conversions to bytes`(
            ending: INCITS_4_1986.FormatEffectors.Line.Ending, name: String, expected: [UInt8]
        ) {
            #expect([UInt8](ascii: ending) == expected, "\(name) should produce correct bytes")
        }

        @Test(arguments: [
            (INCITS_4_1986.FormatEffectors.Line.Ending.lf, "\n"),
            (INCITS_4_1986.FormatEffectors.Line.Ending.cr, "\r"),
            (INCITS_4_1986.FormatEffectors.Line.Ending.crlf, "\r\n"),
        ])
        func `line ending conversions to string`(ending: INCITS_4_1986.FormatEffectors.Line.Ending, expected: String) {
            #expect(String(ascii: ending) == expected)
        }

        @Test
        func `line ending round-trip through bytes`() {
            for ending in [INCITS_4_1986.FormatEffectors.Line.Ending.lf, .cr, .crlf] {
                let bytes = [UInt8](ascii: ending)
                let string = String(ascii: bytes)!
                let expectedString = String(ascii: ending)
                #expect(string == expectedString)
            }
        }
    }
}

// MARK: - Performance

//extension `Performance Tests` {
//    @Suite
//    struct `INCITS_4_1986.FormatEffectors.Line.Ending - Performance` {
//        @Test(.timed(threshold: .milliseconds(200)))
//        func `line ending to bytes conversion 10K times`() {
//            for _ in 0..<10000 {
//                _ = [UInt8](ascii: .lf)
//                _ = [UInt8](ascii: .cr)
//                _ = [UInt8](ascii: .crlf)
//            }
//        }
//    }
//}
