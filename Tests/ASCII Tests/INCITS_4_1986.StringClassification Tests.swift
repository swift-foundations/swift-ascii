// INCITS_4_1986.Text.Classification Tests.swift
// swift-incits-4-1986
//
// Tests for authoritative string classification operations

import Testing
@testable import ASCII

@Suite
struct `INCITS_4_1986.Text.Classification Tests` {
    // MARK: - ASCII Validation Tests

    @Suite
    struct `isAllASCII Tests` {
        @Test(arguments: [
            "Hello",
            "test123",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "abcdefghijklmnopqrstuvwxyz",
            "0123456789",
            "!@#$%^&*()",
            "",  // Empty string
            " \t\n\r",  // Whitespace
        ])
        func `returns true for ASCII-only strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllASCII(str))
        }

        @Test(arguments: [
            "Hello🌍",
            "café",
            "日本語",
            "Ñoño",
            "test\u{80}",  // First non-ASCII byte
            "test\u{FF}",  // High byte
        ])
        func `returns false for strings with non-ASCII`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllASCII(str))
        }
    }

    @Suite
    struct `containsNonASCII Tests` {
        @Test(arguments: [
            "Hello🌍",
            "café",
            "日本語",
            "Ñoño",
            "test\u{80}",
            "test\u{FF}",
        ])
        func `returns true for strings with non-ASCII`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.containsNonASCII(str))
        }

        @Test(arguments: [
            "Hello",
            "test123",
            "!@#$%^&*()",
            "",
            " \t\n\r",
        ])
        func `returns false for ASCII-only strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.containsNonASCII(str))
        }
    }

    // MARK: - Character Class Tests

    @Suite
    struct `isAllWhitespace Tests` {
        @Test(arguments: [
            " ",
            "  ",
            "\t",
            "\n",
            "\r",
            " \t\n\r",
            "    \t\t\n\n",
        ])
        func `returns true for all-whitespace strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllWhitespace(str))
        }

        @Test(arguments: [
            "a",
            " a ",
            "  test  ",
            "\thello\t",
        ])
        func `returns false for non-whitespace strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllWhitespace(str))
        }
    }

    @Suite
    struct `isAllDigits Tests` {
        @Test(arguments: [
            "0",
            "123",
            "0123456789",
            "999",
        ])
        func `returns true for all-digit strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllDigits(str))
        }

        @Test(arguments: [
            "12a34",
            "test",
            "123 456",
            "1.23",
        ])
        func `returns false for non-digit strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllDigits(str))
        }
    }

    @Suite
    struct `isAllLetters Tests` {
        @Test(arguments: [
            "a",
            "ABC",
            "hello",
            "WORLD",
            "AbCdEfG",
        ])
        func `returns true for all-letter strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllLetters(str))
        }

        @Test(arguments: [
            "hello123",
            "test ",
            "Hello-World",
            "café",  // Non-ASCII
        ])
        func `returns false for non-letter strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllLetters(str))
        }
    }

    @Suite
    struct `isAllAlphanumeric Tests` {
        @Test(arguments: [
            "abc123",
            "TEST123",
            "0123456789",
            "abcdefghijklmnopqrstuvwxyz",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        ])
        func `returns true for all-alphanumeric strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllAlphanumeric(str))
        }

        @Test(arguments: [
            "test-123",
            "hello world",
            "test!",
            "123.456",
        ])
        func `returns false for non-alphanumeric strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllAlphanumeric(str))
        }
    }

    @Suite
    struct `isAllControl Tests` {
        @Test(arguments: [
            "\t",
            "\n",
            "\r",
            "\u{00}",
            "\u{1F}",
            "\u{7F}",
            "\t\n\r",
        ])
        func `returns true for all-control strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllControl(str))
        }

        @Test(arguments: [
            "a",
            " ",  // SPACE is not control
            "\tA",
            "test\n",
        ])
        func `returns false for non-control strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllControl(str))
        }
    }

    @Suite
    struct `isAllVisible Tests` {
        @Test(arguments: [
            "!",
            "abc",
            "ABC123",
            "!@#$%^&*()",
            "~",
        ])
        func `returns true for all-visible strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllVisible(str))
        }

        @Test(arguments: [
            " ",  // SPACE is not visible
            "hello ",
            " world",
            "test\n",
        ])
        func `returns false for non-visible strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllVisible(str))
        }
    }

    @Suite
    struct `isAllPrintable Tests` {
        @Test(arguments: [
            " ",
            "Hello World",
            "ABC 123",
            "!@#$%^&*()",
            "test test",
        ])
        func `returns true for all-printable strings`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllPrintable(str))
        }

        @Test(arguments: [
            "Hello\n",
            "\t",
            "test\r\n",
            "\u{00}",
        ])
        func `returns false for non-printable strings`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllPrintable(str))
        }
    }

    @Suite
    struct `containsHexDigit Tests` {
        @Test(arguments: [
            "0x1A",
            "ABC",
            "123",
            "0123456789",
            "ABCDEF",
            "abcdef",
        ])
        func `returns true for strings with hex digits`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.containsHexDigit(str))
        }

        @Test(arguments: [
            "",
            "GHIJKL",
            "xyz",
            "pqrs",
            "mnopqr",
        ])
        func `returns false for strings without hex digits`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.containsHexDigit(str))
        }
    }

    // MARK: - Case Tests

    @Suite
    struct `isAllLowercase Tests` {
        @Test(arguments: [
            "hello",
            "world",
            "abcdefghijklmnopqrstuvwxyz",
            "hello123",  // Digits ignored
            "test-case",  // Non-letters ignored
            "123",  // No letters, so all letters are lowercase
        ])
        func `returns true when all letters are lowercase`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllLowercase(str))
        }

        @Test(arguments: [
            "Hello",
            "WORLD",
            "Test",
            "helloWORLD",
        ])
        func `returns false when any letter is uppercase`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllLowercase(str))
        }
    }

    @Suite
    struct `isAllUppercase Tests` {
        @Test(arguments: [
            "HELLO",
            "WORLD",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "HELLO123",  // Digits ignored
            "TEST-CASE",  // Non-letters ignored
            "123",  // No letters, so all letters are uppercase
        ])
        func `returns true when all letters are uppercase`(str: String) {
            #expect(INCITS_4_1986.Text.Classification.isAllUppercase(str))
        }

        @Test(arguments: [
            "Hello",
            "world",
            "Test",
            "HELLOworld",
        ])
        func `returns false when any letter is lowercase`(str: String) {
            #expect(!INCITS_4_1986.Text.Classification.isAllUppercase(str))
        }
    }

    // MARK: - Edge Cases

    @Suite
    struct `Empty String Behavior` {
        @Test
        func `empty string is all ASCII`() {
            #expect(INCITS_4_1986.Text.Classification.isAllASCII(""))
        }

        @Test
        func `empty string is all whitespace`() {
            // Vacuous truth: all (zero) characters satisfy the predicate
            #expect(INCITS_4_1986.Text.Classification.isAllWhitespace(""))
        }

        @Test
        func `empty string is all digits`() {
            // Vacuous truth: all (zero) characters satisfy the predicate
            #expect(INCITS_4_1986.Text.Classification.isAllDigits(""))
        }

        @Test
        func `empty string is all letters`() {
            // Vacuous truth: all (zero) characters satisfy the predicate
            #expect(INCITS_4_1986.Text.Classification.isAllLetters(""))
        }

        @Test
        func `empty string is all alphanumeric`() {
            // Vacuous truth: all (zero) characters satisfy the predicate
            #expect(INCITS_4_1986.Text.Classification.isAllAlphanumeric(""))
        }

        @Test
        func `empty string is all control`() {
            // Vacuous truth: all (zero) characters satisfy the predicate
            #expect(INCITS_4_1986.Text.Classification.isAllControl(""))
        }

        @Test
        func `empty string is all visible`() {
            // Vacuous truth: all (zero) characters satisfy the predicate
            #expect(INCITS_4_1986.Text.Classification.isAllVisible(""))
        }

        @Test
        func `empty string is all printable`() {
            // Vacuous truth: all (zero) characters satisfy the predicate
            #expect(INCITS_4_1986.Text.Classification.isAllPrintable(""))
        }

        @Test
        func `empty string contains no hex digits`() {
            #expect(!INCITS_4_1986.Text.Classification.containsHexDigit(""))
        }

        @Test
        func `empty string is all lowercase`() {
            // No letters, so trivially all letters are lowercase
            #expect(INCITS_4_1986.Text.Classification.isAllLowercase(""))
        }

        @Test
        func `empty string is all uppercase`() {
            // No letters, so trivially all letters are uppercase
            #expect(INCITS_4_1986.Text.Classification.isAllUppercase(""))
        }
    }

    // MARK: - Non-ASCII Behavior

    @Suite
    struct `Non-ASCII Character Handling` {
        @Test
        func `non-ASCII characters fail letter test`() {
            #expect(!INCITS_4_1986.Text.Classification.isAllLetters("café"))
        }

        @Test
        func `non-ASCII characters fail alphanumeric test`() {
            #expect(!INCITS_4_1986.Text.Classification.isAllAlphanumeric("test123🌍"))
        }

        @Test
        func `non-ASCII characters fail whitespace test`() {
            // Non-breaking space U+00A0
            #expect(!INCITS_4_1986.Text.Classification.isAllWhitespace("\u{00A0}"))
        }
    }
}
