// INCITS_4_1986.Case.Conversion Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986 case conversion operations.
//
// Substrate per the ASCII-domain retyping arc (2026-05-19):
// collection-level case conversion (`bytes.ascii(case: ...)`) is rooted
// at `Collection where Element == ASCII.Code` per the L3 cascade —
// fixtures use `[ASCII.Code]` and bridge via `[UInt8]`-mapping where
// the receiving API (`String.ascii.unchecked`) takes stdlib bytes.

import Testing
@testable import ASCII

// MARK: - String Case Conversion

@Suite
struct `Case Conversion Tests` {
    @Suite
    struct `String Case Conversion - Correctness` {
        @Test
        func `String case conversion to uppercase`() {
            #expect("hello".ascii(case: .upper) == "HELLO")
            #expect("Hello World".ascii(case: .upper) == "HELLO WORLD")
        }

        @Test
        func `String case conversion to lowercase`() {
            #expect("HELLO".ascii(case: .lower) == "hello")
            #expect("Hello World".ascii(case: .lower) == "hello world")
        }

        @Test
        func `String case conversion preserves non-ASCII`() {
            #expect("hello🌍".ascii(case: .upper) == "HELLO🌍")
            #expect("HELLO🌍".ascii(case: .lower) == "hello🌍")
        }

        @Test
        func `Array case conversion matches String case conversion`() {
            let str = "Hello World"
            let strUpper = str.ascii(case: .upper)
            // [ASCII.Code] is the canonical substrate for the byte-level
            // case conversion. Bridge to [UInt8] at the
            // `String.ascii.unchecked` boundary (it takes stdlib bytes).
            let codes: [ASCII.Code] = [ASCII.Code].ascii.unchecked(str)
            let bytesUpper = String.ascii.unchecked(
                codes.ascii(case: .upper).map(\.underlying)
            )
            #expect(strUpper == bytesUpper)
        }

        @Test
        func `Case conversion round-trip`() {
            let original = "Hello World"
            let upper = original.ascii(case: .upper)
            let lower = upper.ascii(case: .lower)
            #expect(lower == "hello world")
        }
    }

    // MARK: - Byte-Level Case Conversion

    @Suite
    struct `UInt8 Case Conversion - Correctness` {
        @Test(arguments: [
            ("a", "A"), ("b", "B"), ("z", "Z"),
            ("m", "M"), ("n", "N"),
        ])
        func `lowercase to uppercase`(lower: Character, upper: Character) {
            let lowerByte = UInt8(ascii: lower)!
            let upperByte = UInt8(ascii: upper)!
            #expect(lowerByte.ascii(case: .upper) == upperByte)
        }

        @Test(arguments: [
            ("A", "a"), ("B", "b"), ("Z", "z"),
            ("M", "m"), ("N", "n"),
        ])
        func `uppercase to lowercase`(upper: Character, lower: Character) {
            let upperByte = UInt8(ascii: upper)!
            let lowerByte = UInt8(ascii: lower)!
            #expect(upperByte.ascii(case: .lower) == lowerByte)
        }

        @Test(arguments: ["0", "1", "9", "!", "@", " "])
        func `non-letters unchanged`(char: Character) {
            let byte = UInt8(ascii: char)!
            #expect(byte.ascii(case: .upper) == byte)
            #expect(byte.ascii(case: .lower) == byte)
        }
    }

    // MARK: - Idempotence

    @Suite
    struct `Case Conversion - Idempotence` {
        @Test
        func `uppercase is idempotent on strings`() {
            let str = "Hello World 123!"
            let upper1 = str.ascii(case: .upper)
            let upper2 = upper1.ascii(case: .upper)
            #expect(upper1 == upper2, "Applying uppercase twice should be idempotent")
        }

        @Test
        func `lowercase is idempotent on strings`() {
            let str = "Hello World 123!"
            let lower1 = str.ascii(case: .lower)
            let lower2 = lower1.ascii(case: .lower)
            #expect(lower1 == lower2, "Applying lowercase twice should be idempotent")
        }

        @Test
        func `uppercase is idempotent on bytes`() {
            // [ASCII.Code] substrate per L3 cascade — `[T](ascii: String)?`
            // is the typed init on [ASCII.Code], not [UInt8].
            let codes = [ASCII.Code](ascii: "Hello World 123!")!
            let upper1 = codes.ascii(case: .upper)
            let upper2 = upper1.ascii(case: .upper)
            #expect(upper1 == upper2, "Applying uppercase twice should be idempotent")
        }

        @Test
        func `lowercase is idempotent on bytes`() {
            let codes = [ASCII.Code](ascii: "Hello World 123!")!
            let lower1 = codes.ascii(case: .lower)
            let lower2 = lower1.ascii(case: .lower)
            #expect(lower1 == lower2, "Applying lowercase twice should be idempotent")
        }
    }

    // MARK: - Mathematical Properties

    @Suite
    struct `Case Conversion - Mathematical Properties` {
        @Test
        func `conversion offset is exactly 32`() {
            let a = UInt8(ascii: "a")!
            let A = UInt8(ascii: "A")!
            #expect(a - A == 32)
            #expect(a - A == INCITS_4_1986.Case.Conversion.offset)
        }

        @Test(arguments: Array(zip(
            UInt8.ascii.a.underlying...UInt8.ascii.z.underlying,
            UInt8.ascii.A.underlying...UInt8.ascii.Z.underlying
        )))
        func `all letter pairs have correct offset`(lower: UInt8, upper: UInt8) {
            // Range iteration requires Strideable; `ASCII.Code` is not Strideable
            // per [API-BYTE-002], so drop to `.underlying` (UInt8) for the
            // a...z / A...Z enumeration.
            #expect(
                lower - upper == 32,
                "Offset between '\(Character(UnicodeScalar(lower)))' and '\(Character(UnicodeScalar(upper)))' should be 32"
            )
        }
    }
}

// MARK: - Performance

//extension `Performance Tests` {
//    @Suite
//    struct `Case Conversion - Performance` {
//        @Test(.timed(threshold: .milliseconds(50)))
//        func `uppercase conversion 100K character string`() {
//            let str = String(repeating: "Hello World! ", count: 10000)
//            _ = str.ascii(case: .upper)
//        }
//
//        @Test(.timed(threshold: .milliseconds(50)))
//        func `lowercase conversion 100K character string`() {
//            let str = String(repeating: "Hello World! ", count: 10000)
//            _ = str.ascii(case: .lower)
//        }
//
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `byte array case conversion 1M bytes`() {
//            let bytes = Array(repeating: UInt8.ascii.a, count: 1_000_000)
//            _ = bytes.ascii(case: .upper)
//        }
//
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `single byte case conversion 1M times`() {
//            let byte = UInt8.ascii.a
//            for _ in 0..<1_000_000 {
//                _ = byte.ascii(case: .upper)
//            }
//        }
//    }
//}
