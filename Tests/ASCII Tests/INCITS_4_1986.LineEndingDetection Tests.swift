import Testing

@testable import ASCII

@Suite
struct `INCITS_4_1986.LineEnding.Detection Tests` {

    @Suite
    struct `detect() Method Tests` {
        @Test(arguments: [
            ("line1\nline2", INCITS_4_1986.FormatEffectors.Line.Ending.lf),
            ("line1\n", INCITS_4_1986.FormatEffectors.Line.Ending.lf),
            ("\n", INCITS_4_1986.FormatEffectors.Line.Ending.lf),
            ("test\nmore\nlines", INCITS_4_1986.FormatEffectors.Line.Ending.lf),
        ])
        func `detects LF line endings`(input: (String, INCITS_4_1986.FormatEffectors.Line.Ending)) {
            let (str, expected) = input
            #expect(INCITS_4_1986.LineEnding.Detection.detect(str) == expected)
        }

        @Test(arguments: [
            ("line1\rline2", INCITS_4_1986.FormatEffectors.Line.Ending.cr),
            ("line1\r", INCITS_4_1986.FormatEffectors.Line.Ending.cr),
            ("\r", INCITS_4_1986.FormatEffectors.Line.Ending.cr),
            ("test\rmore\rlines", INCITS_4_1986.FormatEffectors.Line.Ending.cr),
        ])
        func `detects CR line endings`(input: (String, INCITS_4_1986.FormatEffectors.Line.Ending)) {
            let (str, expected) = input
            #expect(INCITS_4_1986.LineEnding.Detection.detect(str) == expected)
        }

        @Test(arguments: [
            ("line1\r\nline2", INCITS_4_1986.FormatEffectors.Line.Ending.crlf),
            ("line1\r\n", INCITS_4_1986.FormatEffectors.Line.Ending.crlf),
            ("\r\n", INCITS_4_1986.FormatEffectors.Line.Ending.crlf),
            ("test\r\nmore\r\nlines", INCITS_4_1986.FormatEffectors.Line.Ending.crlf),
        ])
        func `detects CRLF line endings`(input: (String, INCITS_4_1986.FormatEffectors.Line.Ending))
        {
            let (str, expected) = input
            #expect(INCITS_4_1986.LineEnding.Detection.detect(str) == expected)
        }

        @Test(arguments: [
            "no line endings",
            "test",
            "",
            "hello world",
        ])
        func `returns nil when no line endings present`(str: String) {
            #expect(INCITS_4_1986.LineEnding.Detection.detect(str) == nil)
        }

        @Test
        func `prioritizes CRLF over individual CR or LF`() {

            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\r\nmore") == .crlf)
        }
    }

    @Suite
    struct `hasMixedLineEndings() Method Tests` {
        @Test(arguments: [
            "line1\nline2\nline3",
            "line1\rline2\rline3",
            "line1\r\nline2\r\nline3",
            "no line endings",
            "",
        ])
        func `returns false for consistent or no line endings`(str: String) {
            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings(str))
        }

        @Test(arguments: [
            "line1\nline2\r\nline3",
            "line1\rline2\nline3",
            "line1\rline2\r\nline3",
            "line1\nline2\rline3\r\n",
        ])
        func `returns true for mixed line endings`(str: String) {
            #expect(INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings(str))
        }

        @Test
        func `CRLF is distinct from standalone CR and LF`() {

            #expect(INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings("line1\r\nline2\nline3"))

            #expect(INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings("line1\r\nline2\rline3"))
        }

        @Test
        func `consecutive CRLF is not mixed`() {
            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings("line1\r\nline2\r\n"))
            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings("\r\n\r\n"))
        }

        @Test
        func `CR not followed by LF is standalone`() {

            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings("line1\rline2\r"))
        }
    }

    @Suite
    struct `Edge Cases` {
        @Test
        func `empty string has no line endings`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("") == nil)
            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings(""))
        }

        @Test
        func `single LF`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\n") == .lf)
        }

        @Test
        func `single CR`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\r") == .cr)
        }

        @Test
        func `single CRLF`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\r\n") == .crlf)
        }

        @Test
        func `line ending at start`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\ntest") == .lf)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\rtest") == .cr)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\r\ntest") == .crlf)
        }

        @Test
        func `line ending at end`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\n") == .lf)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\r") == .cr)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\r\n") == .crlf)
        }

        @Test
        func `consecutive line endings`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\n\n") == .lf)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\r\r") == .cr)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\r\n\r\n") == .crlf)
        }

        @Test
        func `CR followed by non-LF is standalone CR`() {
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\ra") == .cr)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\r1") == .cr)
        }
    }

    @Suite
    struct `Detection Priority Tests` {
        @Test
        func `CRLF takes precedence in detection`() {

            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\r\n") == .crlf)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("a\r\nb") == .crlf)
        }

        @Test
        func `standalone CR without LF following`() {

            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\rmore") == .cr)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\r") == .cr)
        }

        @Test
        func `standalone LF without CR preceding`() {

            #expect(INCITS_4_1986.LineEnding.Detection.detect("test\nmore") == .lf)
            #expect(INCITS_4_1986.LineEnding.Detection.detect("\n") == .lf)
        }
    }

    @Suite
    struct `Real World Examples` {
        @Test
        func `Unix-style multi-line text`() {
            let text = "#!/bin/bash\necho 'Hello'\necho 'World'\n"
            #expect(INCITS_4_1986.LineEnding.Detection.detect(text) == .lf)
            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings(text))
        }

        @Test
        func `Windows-style multi-line text`() {
            let text = "Line 1\r\nLine 2\r\nLine 3\r\n"
            #expect(INCITS_4_1986.LineEnding.Detection.detect(text) == .crlf)
            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings(text))
        }

        @Test
        func `Classic Mac-style multi-line text`() {
            let text = "Line 1\rLine 2\rLine 3\r"
            #expect(INCITS_4_1986.LineEnding.Detection.detect(text) == .cr)
            #expect(!INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings(text))
        }

        @Test
        func `mixed platform text file`() {
            let text = "Unix line\nWindows line\r\nMac line\r"
            #expect(INCITS_4_1986.LineEnding.Detection.hasMixedLineEndings(text))
        }
    }
}
