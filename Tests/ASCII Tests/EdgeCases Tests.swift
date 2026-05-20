// EdgeCases Tests.swift
// swift-incits-4-1986
//
// Edge case tests that catch issues other ASCII libraries miss.
//
// Substrate per the ASCII-domain retyping arc (2026-05-19):
// - `[ASCII.Code]` for code-domain fixtures; `[Byte]` for byte-domain
//   sequences that may include non-ASCII (the validation surface).
// - Predicates on `byte: UInt8` go through `byte.ascii.isLetter` etc.
//   (`byte.ascii` returns `ASCII.Code`; predicates live directly on
//   `ASCII.Code`).
// - Boundary arithmetic (`UInt8.ascii.A - 1`) drops to `.underlying`
//   because `ASCII.Code` has no arithmetic by design per [API-BYTE-002].

import Testing
@testable import ASCII

// File-private helper bridging "is [Byte] all ASCII?" to the
// constructor-lift form. Successful `[ASCII.Code]` lift IS validation.
private func isAllASCII(_ bytes: [Byte]) -> Bool {
    (try? [ASCII.Code](bytes)) != nil
}

// MARK: - Boundary Value Edge Cases

@Suite
struct `Edge Cases Tests` {
    @Suite
    struct `Edge Cases - ASCII Boundaries Tests` {
        @Test
        func `boundary at 0x7F is valid ASCII`() {
            #expect(isAllASCII([Byte.ascii.del]))
        }

        @Test
        func `boundary at 0x80 is invalid ASCII`() {
            #expect(!isAllASCII([0x80]))
        }

        @Test
        func `off-by-one below ASCII range`() {
            // 0x00 is valid (NUL), but verify it's not treated as empty/invalid
            #expect(isAllASCII([Byte.ascii.nul]))
            #expect(UInt8.ascii.nul.isControl)
        }

        @Test
        func `off-by-one above ASCII range`() {
            // 0x80 is first non-ASCII byte (extended ASCII)
            let extendedASCII: UInt8 = 0x80
            #expect(!isAllASCII([Byte(extendedASCII)]))
            #expect(!extendedASCII.ascii.isControl)
            #expect(!extendedASCII.ascii.isPrintable)
        }

        @Test
        func `letter boundaries are precise`() {
            // A-Z: 0x41-0x5A, a-z: 0x61-0x7A.
            // Boundary arithmetic drops to `.underlying` because
            // `ASCII.Code` has no arithmetic per [API-BYTE-002].
            #expect((UInt8.ascii.A.underlying - 1).ascii.isLetter == false)  // 0x40 '@'
            #expect(UInt8.ascii.A.isLetter == true)  // 0x41 'A'
            #expect(UInt8.ascii.Z.isLetter == true)  // 0x5A 'Z'
            #expect((UInt8.ascii.Z.underlying + 1).ascii.isLetter == false)  // 0x5B '['

            #expect((UInt8.ascii.a.underlying - 1).ascii.isLetter == false)  // 0x60 '`'
            #expect(UInt8.ascii.a.isLetter == true)  // 0x61 'a'
            #expect(UInt8.ascii.z.isLetter == true)  // 0x7A 'z'
            #expect((UInt8.ascii.z.underlying + 1).ascii.isLetter == false)  // 0x7B '{'
        }

        @Test
        func `digit boundaries are precise`() {
            // 0-9: 0x30-0x39
            #expect((UInt8.ascii.`0`.underlying - 1).ascii.isDigit == false)  // 0x2F '/'
            #expect(UInt8.ascii.`0`.isDigit == true)  // 0x30 '0'
            #expect(UInt8.ascii.`9`.isDigit == true)  // 0x39 '9'
            #expect((UInt8.ascii.`9`.underlying + 1).ascii.isDigit == false)  // 0x3A ':'
        }

        @Test
        func `printable boundaries are precise`() {
            // Printable: 0x20-0x7E (space through tilde)
            #expect((UInt8.ascii.sp.underlying - 1).ascii.isPrintable == false)  // 0x1F (US)
            #expect(UInt8.ascii.sp.isPrintable == true)  // 0x20 (space)
            #expect(UInt8.ascii.tilde.isPrintable == true)  // 0x7E (~)
            #expect((UInt8.ascii.tilde.underlying + 1).ascii.isPrintable == false)  // 0x7F (DEL)
        }

        @Test
        func `visible boundaries are precise`() {
            // Visible: 0x21-0x7E (exclamation through tilde, excludes space)
            #expect(UInt8.ascii.sp.isVisible == false)  // 0x20 (space)
            #expect(UInt8.ascii.exclamationPoint.isVisible == true)  // 0x21 (!)
            #expect(UInt8.ascii.tilde.isVisible == true)  // 0x7E (~)
            #expect((UInt8.ascii.tilde.underlying + 1).ascii.isVisible == false)  // 0x7F (DEL)
        }
    }

    // MARK: - Case Conversion Edge Cases

    @Suite
    struct `Edge Cases - Case Conversion` {
        @Test
        func `already uppercase string unchanged`() {
            let codes: [ASCII.Code] = [.H, .E, .L, .L, .O]
            #expect(codes.ascii(case: .upper) == codes)
        }

        @Test
        func `already lowercase string unchanged`() {
            let codes: [ASCII.Code] = [.h, .e, .l, .l, .o]
            #expect(codes.ascii(case: .lower) == codes)
        }

        @Test
        func `string with no letters unchanged`() {
            let codes: [ASCII.Code] = [.`0`, .`1`, .`2`, .sp, .exclamationPoint]
            #expect(codes.ascii(case: .upper) == codes)
            #expect(codes.ascii(case: .lower) == codes)
        }

        @Test
        func `control characters unchanged during case conversion`() {
            let codes: [ASCII.Code] = [.nul, .htab, .lf, .cr, .esc, .del]
            #expect(codes.ascii(case: .upper) == codes)
            #expect(codes.ascii(case: .lower) == codes)
        }

        @Test
        func `symbols unchanged during case conversion`() {
            let symbols: [ASCII.Code] = [
                .exclamationPoint, .commercialAt, .numberSign, .dollarSign,
                .percentSign, .circumflexAccent, .ampersand, .asterisk,
            ]
            #expect(symbols.ascii(case: .upper) == symbols)
            #expect(symbols.ascii(case: .lower) == symbols)
        }

        @Test
        func `empty array case conversion`() {
            let empty: [ASCII.Code] = []
            #expect(empty.ascii(case: .upper) == [])
            #expect(empty.ascii(case: .lower) == [])
        }

        @Test
        func `mixed letters and non-letters preserves structure`() {
            let codes: [ASCII.Code] = [.H, .e, .l, .`3`, .exclamationPoint]
            let upper = codes.ascii(case: .upper)
            #expect(upper == [.H, .E, .L, .`3`, .exclamationPoint])
        }

        @Test
        func `case conversion at letter boundaries`() {
            // Test characters just outside letter ranges remain unchanged.
            // Use integer literals for the boundary codes (0x40, 0x5B, 0x60, 0x7B)
            // since `ASCII.Code` has no arithmetic per [API-BYTE-002].
            let nonLetters: [ASCII.Code] = [
                0x40,  // '@' — UInt8.ascii.A - 1
                0x5B,  // '[' — UInt8.ascii.Z + 1
                0x60,  // '`' — UInt8.ascii.a - 1
                0x7B,  // '{' — UInt8.ascii.z + 1
            ]
            #expect(nonLetters.ascii(case: .upper) == nonLetters)
            #expect(nonLetters.ascii(case: .lower) == nonLetters)
        }

        @Test
        func `string case conversion works correctly`() {
            let str = "HeLLo123!"
            #expect(str.ascii(case: .upper) == "HELLO123!")
            #expect(str.ascii(case: .lower) == "hello123!")
        }
    }

    // MARK: - Validation Edge Cases

    @Suite
    struct `Edge Cases - Validation` {
        @Test
        func `empty array is valid ASCII`() {
            let empty: [Byte] = []
            #expect(isAllASCII(empty))
        }

        @Test
        func `single NUL byte is valid`() {
            #expect(isAllASCII([Byte.ascii.nul]))
        }

        @Test
        func `single DEL byte is valid`() {
            #expect(isAllASCII([Byte.ascii.del]))
        }

        @Test
        func `all zeros array is valid ASCII`() {
            let zeros: [Byte] = Array(repeating: Byte.ascii.nul, count: 1000)
            #expect(isAllASCII(zeros))
        }

        @Test
        func `all DEL array is valid ASCII`() {
            let dels: [Byte] = Array(repeating: Byte.ascii.del, count: 1000)
            #expect(isAllASCII(dels))
        }

        @Test
        func `non-ASCII at start fails immediately`() {
            let bytes: [Byte] = [0x80, Byte.ascii.A, .ascii.B, .ascii.C]
            #expect(!isAllASCII(bytes))
        }

        @Test
        func `non-ASCII at end detected`() {
            let bytes: [Byte] = [Byte.ascii.A, .ascii.B, .ascii.C, 0x80]
            #expect(!isAllASCII(bytes))
        }

        @Test
        func `non-ASCII in middle detected`() {
            let bytes: [Byte] = [Byte.ascii.A, 0x80, Byte.ascii.B]
            #expect(!isAllASCII(bytes))
        }

        @Test
        func `all extended ASCII bytes invalid`() {
            for value in UInt8(0x80)...UInt8(0xFF) {
                #expect(!isAllASCII([Byte(value)]), "Byte 0x\(String(value, radix: 16)) should be invalid")
            }
        }

        @Test
        func `all standard ASCII bytes valid`() {
            // `Byte` is not Strideable per [API-BYTE-002]; iterate on UInt8
            // and bridge to Byte at the lift site.
            let allASCII: [Byte] = (UInt8.ascii.nul.underlying...UInt8.ascii.del.underlying).map(Byte.init)
            #expect(isAllASCII(allASCII))
        }
    }

    // MARK: - Character Conversion Edge Cases

    @Suite
    struct `Edge Cases - Character Conversion` {
        @Test
        func `non-ASCII character returns nil`() {
            #expect(UInt8(ascii: "é") == nil)
            #expect(UInt8(ascii: "ñ") == nil)
            #expect(UInt8(ascii: "ü") == nil)
        }

        @Test
        func `emoji returns nil`() {
            #expect(UInt8(ascii: "😀") == nil)
            #expect(UInt8(ascii: "🎉") == nil)
            #expect(UInt8(ascii: "❤️") == nil)
        }

        @Test
        func `CJK characters return nil`() {
            #expect(UInt8(ascii: "中") == nil)
            #expect(UInt8(ascii: "文") == nil)
            #expect(UInt8(ascii: "日") == nil)
            #expect(UInt8(ascii: "本") == nil)
        }

        @Test
        func `control characters convert correctly`() {
            #expect(UInt8(ascii: "\t") == UInt8.ascii.htab.underlying)
            #expect(UInt8(ascii: "\n") == UInt8.ascii.lf.underlying)
            #expect(UInt8(ascii: "\r") == UInt8.ascii.cr.underlying)
        }

        @Test
        func `all ASCII characters roundtrip`() {
            // Every ASCII byte should convert to a character and back.
            // Range iteration on `.underlying` (UInt8); `ASCII.Code` is not
            // Strideable per [API-BYTE-002].
            for byte in UInt8.ascii.nul.underlying...UInt8.ascii.del.underlying {
                let scalar = UnicodeScalar(byte)
                let char = Character(scalar)
                if let converted = UInt8(ascii: char) {
                    #expect(converted == byte, "Byte 0x\(String(byte, radix: 16)) failed roundtrip")
                }
            }
        }

        @Test
        func `character predicate handles non-ASCII gracefully`() {
            let nonASCII = Character("é")
            #expect(nonASCII.ascii.isLetter == false)
            #expect(nonASCII.ascii.isDigit == false)
            #expect(nonASCII.ascii.isWhitespace == false)
        }
    }

    // MARK: - Line Ending Edge Cases

    @Suite
    struct `Edge Cases - Line Endings` {
        @Test
        func `empty string normalization`() {
            #expect("".normalized(to: .lf).isEmpty)
            #expect("".normalized(to: .crlf).isEmpty)
        }

        @Test
        func `no line endings unchanged`() {
            let text = "Hello World"
            #expect(text.normalized(to: .lf) == text)
            #expect(text.normalized(to: .crlf) == text)
        }

        @Test
        func `mixed line endings normalized`() {
            let mixed = "line1\r\nline2\nline3\rline4"
            #expect(mixed.normalized(to: .lf) == "line1\nline2\nline3\nline4")
            #expect(mixed.normalized(to: .crlf) == "line1\r\nline2\r\nline3\r\nline4")
        }

        @Test
        func `consecutive CRLF preserved`() {
            let text = "line1\r\n\r\nline2"
            #expect(text.normalized(to: .lf) == "line1\n\nline2")
            #expect(text.normalized(to: .crlf) == "line1\r\n\r\nline2")
        }

        @Test
        func `consecutive LF preserved`() {
            let text = "line1\n\n\nline2"
            #expect(text.normalized(to: .lf) == text)
            #expect(text.normalized(to: .crlf) == "line1\r\n\r\n\r\nline2")
        }

        @Test
        func `consecutive CR preserved`() {
            let text = "line1\r\r\rline2"
            #expect(text.normalized(to: .lf) == "line1\n\n\nline2")
            #expect(text.normalized(to: .crlf) == "line1\r\n\r\n\r\nline2")
        }

        @Test
        func `line ending at start`() {
            #expect("\ntext".normalized(to: .lf) == "\ntext")
            #expect("\r\ntext".normalized(to: .lf) == "\ntext")
            #expect("\ntext".normalized(to: .crlf) == "\r\ntext")
        }

        @Test
        func `line ending at end`() {
            #expect("text\n".normalized(to: .lf) == "text\n")
            #expect("text\r\n".normalized(to: .lf) == "text\n")
            #expect("text\n".normalized(to: .crlf) == "text\r\n")
        }

        @Test
        func `only line endings`() {
            #expect("\n\n\n".normalized(to: .lf) == "\n\n\n")
            #expect("\r\n\r\n".normalized(to: .lf) == "\n\n")
            #expect("\n\n".normalized(to: .crlf) == "\r\n\r\n")
        }

        @Test
        func `CR followed by non-LF character`() {
            // Standalone CR should be normalized
            let text = "line1\rX"
            #expect(text.normalized(to: .lf) == "line1\nX")
            #expect(text.normalized(to: .crlf) == "line1\r\nX")
        }

        @Test
        func `normalize already normalized CRLF to CRLF`() {
            let text = "line1\r\nline2\r\n"
            #expect(text.normalized(to: .crlf) == text)
        }

        @Test
        func `normalize already normalized LF to LF`() {
            let text = "line1\nline2\n"
            #expect(text.normalized(to: .lf) == text)
        }
    }

    // MARK: - Trimming Edge Cases

    @Suite
    struct `Edge Cases - String Trimming` {
        @Test
        func `empty string trimming`() {
            #expect("".trimming(.ascii.whitespaces).isEmpty)
        }

        @Test
        func `all whitespace string becomes empty`() {
            #expect("    ".trimming(.ascii.whitespaces).isEmpty)
            #expect("\t\t\t".trimming(.ascii.whitespaces).isEmpty)
            #expect("\n\n".trimming(.ascii.whitespaces).isEmpty)
            #expect(" \t\n\r ".trimming(.ascii.whitespaces).isEmpty)
        }

        @Test
        func `no whitespace unchanged`() {
            let text = "HelloWorld"
            #expect(text.trimming(.ascii.whitespaces) == text)
        }

        @Test
        func `internal whitespace preserved`() {
            let text = "Hello World"
            #expect(text.trimming(.ascii.whitespaces) == text)
        }

        @Test
        func `mixed leading whitespace removed`() {
            let text = " \t\n  Hello"
            #expect(text.trimming(.ascii.whitespaces) == "Hello")
        }

        @Test
        func `mixed trailing whitespace removed`() {
            let text = "Hello  \n\t "
            #expect(text.trimming(.ascii.whitespaces) == "Hello")
        }

        @Test
        func `single space leading`() {
            #expect(" Hello".trimming(.ascii.whitespaces) == "Hello")
        }

        @Test
        func `single space trailing`() {
            #expect("Hello ".trimming(.ascii.whitespaces) == "Hello")
        }

        @Test
        func `only internal whitespace`() {
            let text = "A B C"
            #expect(text.trimming(.ascii.whitespaces) == text)
        }

        @Test
        func `multiple consecutive internal whitespace preserved`() {
            let text = "A    B"
            #expect(text.trimming(.ascii.whitespaces) == text)
        }

        @Test
        func `whitespace at start middle and end`() {
            let text = "  Hello   World  "
            #expect(text.trimming(.ascii.whitespaces) == "Hello   World")
        }

        @Test
        func `trim custom character set`() {
            let custom: Set<Character> = ["x", "y", "z"]
            #expect("xxHelloxx".trimming(custom) == "Hello")
            #expect("xyHellozyx".trimming(custom) == "Hello")
        }

        @Test
        func `trim empty set does nothing`() {
            let text = "  Hello  "
            #expect(text.trimming(Set<Character>()) == text)
        }
    }

    // MARK: - Whitespace Set Edge Cases

    @Suite
    struct `Edge Cases - Whitespace Set` {
        @Test
        func `INCITS whitespace set is exactly 4 characters`() {
            #expect(INCITS_4_1986.whitespaces.count == 4)
        }

        @Test
        func `whitespace set is exactly 5 characters`() {
            #expect(Set<Character>.ascii.whitespaces.count == 5)
        }

        @Test
        func `whitespace set contains only ASCII whitespace`() {
            // `INCITS_4_1986.whitespaces` is `Set<ASCII.Code>` post-cascade;
            // bridge to `[Byte]` at the `String(ascii:)` boundary.
            let ws = INCITS_4_1986.whitespaces.compactMap { String(ascii: [$0.byte]) }
            #expect(ws.contains(" "))
            #expect(ws.contains("\t"))
            #expect(ws.contains("\n"))
            #expect(ws.contains("\r"))
            #expect(ws.count == 4)
        }

        @Test
        func `whitespace set does not contain vertical tab`() {
            // VTAB (0x0B) is a control character but NOT in ASCII whitespace set
            let vtab = Character(UnicodeScalar(0x0B))
            #expect(!Set<Character>.ascii.whitespaces.contains(vtab))
        }

        @Test
        func `whitespace set does not contain form feed`() {
            // FF (0x0C) is a control character but NOT in ASCII whitespace set
            let ff = Character(UnicodeScalar(0x0C))
            #expect(!Set<Character>.ascii.whitespaces.contains(ff))
        }

        @Test
        func `whitespace set does not contain non-breaking space`() {
            // U+00A0 is Unicode whitespace but NOT ASCII
            let nbsp = Character("\u{00A0}")
            #expect(!Set<Character>.ascii.whitespaces.contains(nbsp))
        }

        @Test
        func `whitespace bytes are control characters`() {
            // All ASCII whitespace bytes are also control characters except space
            #expect(UInt8.ascii.htab.isControl)
            #expect(UInt8.ascii.lf.isControl)
            #expect(UInt8.ascii.cr.isControl)
            #expect(!UInt8.ascii.sp.isControl)
        }
    }

    // MARK: - Constants Edge Cases

    @Suite
    struct `Edge Cases - Constants` {
        @Test
        func `whitespaces constant has 4 bytes`() {
            #expect(INCITS_4_1986.whitespaces.count == 4)
            #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.htab))
            #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.lf))
            #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.cr))
            #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.sp))
        }

        @Test
        func `crlf constant is exactly two bytes`() {
            #expect(INCITS_4_1986.Character.Control.crlf.count == 2)
            #expect(INCITS_4_1986.Character.Control.crlf == [UInt8.ascii.cr, UInt8.ascii.lf])
        }

        @Test
        func `crlf order is CR then LF`() {
            #expect(INCITS_4_1986.Character.Control.crlf[0] == UInt8.ascii.cr)
            #expect(INCITS_4_1986.Character.Control.crlf[1] == UInt8.ascii.lf)
        }
    }
}

// MARK: - Performance Edge Cases

//extension `Performance Tests` {
//    @Suite
//    struct `Edge Cases - Performance` {
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `validate worst case - non-ASCII at end of 1M bytes`() {
//            var bytes = Array(repeating: UInt8.ascii.A, count: 1_000_000)
//            bytes[999_999] = 0x80
//            _ = bytes.ascii.isAllASCII
//        }
//
//        @Test(.timed(threshold: .milliseconds(50)))
//        func `validate best case - non-ASCII at start of 1M bytes`() {
//            var bytes = Array(repeating: UInt8.ascii.A, count: 1_000_000)
//            bytes[0] = 0x80
//            _ = bytes.ascii.isAllASCII
//        }
//
//        @Test(.timed(threshold: .milliseconds(150)))
//        func `case conversion of already uppercase 100K bytes`() {
//            let bytes = Array(repeating: UInt8.ascii.A, count: 100_000)
//            for _ in 0..<10 {
//                _ = bytes.ascii(case: .upper)
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(150)))
//        func `case conversion of already lowercase 100K bytes`() {
//            let bytes = Array(repeating: UInt8.ascii.a, count: 100_000)
//            for _ in 0..<10 {
//                _ = bytes.ascii(case: .lower)
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(150)))
//        func `trim all-whitespace string 10K times`() {
//            let allWhitespace = "                    "  // 20 spaces
//            for _ in 0..<10000 {
//                _ = allWhitespace.trimming(.ascii.whitespaces)
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(150)))
//        func `normalize already-normalized text 10K times`() {
//            let text = "line1\nline2\nline3\nline4\n"
//            for _ in 0..<10000 {
//                _ = text.normalized(to: .lf)
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(300)))
//        func `boundary checks 1M times`() {
//            for _ in 0..<1_000_000 {
//                _ = UInt8.ascii.del.ascii.isControl  // Upper boundary
//                _ = (UInt8.ascii.A - 1).ascii.isLetter  // Letter lower boundary
//                _ = (UInt8.ascii.z + 1).ascii.isLetter  // Letter upper boundary
//            }
//        }
//    }
//}
