import Testing

@testable import ASCII

@Suite
struct `FormatEffectors Tests` {
    @Suite
    struct `Line Ending Normalization - Correctness` {
        @Test(arguments: [
            ("hello\nworld", INCITS_4_1986.FormatEffectors.Line.Ending.lf, "hello\nworld"),
            ("hello\nworld", .cr, "hello\rworld"),
            ("hello\nworld", .crlf, "hello\r\nworld"),
            ("hello\r\nworld", .lf, "hello\nworld"),
            ("hello\rworld", .lf, "hello\nworld"),
        ])
        func `line ending normalization`(
            input: String,
            to: INCITS_4_1986.FormatEffectors.Line.Ending,
            expected: String
        ) {
            #expect(input.normalized(to: to) == expected)
        }

        @Test
        func `normalization preserves content`() {
            let text = "Line 1\nLine 2\r\nLine 3\rEnd"
            let normalized = text.normalized(to: .lf)
            let lines = normalized.split(separator: "\n").map(String.init)
            #expect(lines == ["Line 1", "Line 2", "Line 3", "End"])
        }
    }

    @Suite
    struct `Line Ending Normalization - Idempotence` {
        @Test(arguments: [INCITS_4_1986.FormatEffectors.Line.Ending.lf, .cr, .crlf])
        func `normalization is idempotent`(ending: INCITS_4_1986.FormatEffectors.Line.Ending) {
            let text = "hello\nworld\r\ntest\rend"
            let first = text.normalized(to: ending)
            let second = first.normalized(to: ending)
            #expect(first == second, "Normalizing twice should be idempotent")
        }

        @Test(arguments: [INCITS_4_1986.FormatEffectors.Line.Ending.lf, .cr, .crlf])
        func `text without line endings unchanged`(
            ending: INCITS_4_1986.FormatEffectors.Line.Ending
        ) {
            let text = "no line endings here"
            #expect(text.normalized(to: ending) == text)
        }
    }
}
