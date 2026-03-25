// UInt8+INCITS_4_1986.swift
// swift-incits-4-1986
//
// INCITS 4-1986: US-ASCII byte-level operations
//
// Character classification and manipulation methods for UInt8.
// For ASCII constants, use UInt8.ascii namespace (see UInt8+ASCII.swift)

public import Binary_Primitives
import Standard_Library_Extensions

// MARK: - Character to Byte Conversion

extension UInt8 {
    /// Creates ASCII byte from a character with validation
    ///
    /// Converts a Swift `Character` to its ASCII byte value, returning `nil` if the character
    /// is outside the ASCII range (U+0000 to U+007F). This initializer validates that the character
    /// fits within the 7-bit US-ASCII encoding before conversion.
    ///
    /// ## Validation
    ///
    /// Only characters in the range U+0000 to U+007F (0-127 decimal) are valid ASCII.
    /// Any character requiring more than 7 bits to encode will return `nil`:
    /// - Accented letters (é, ñ, ü, etc.) → `nil`
    /// - Emoji (🌍, 😀, etc.) → `nil`
    /// - Extended Unicode → `nil`
    ///
    /// ## Performance
    ///
    /// This initializer is marked `@inline(always)` for optimal performance, delegating to
    /// the Swift standard library's `Character.asciiValue` property.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Valid ASCII characters
    /// UInt8(ascii: "A")     // 65 (0x41)
    /// UInt8(ascii: "0")     // 48 (0x30)
    /// UInt8(ascii: " ")     // 32 (0x20)
    /// UInt8(ascii: "\n")    // 10 (0x0A)
    ///
    /// // Non-ASCII characters
    /// UInt8(ascii: "🌍")    // nil (emoji)
    /// UInt8(ascii: "é")     // nil (accented letter)
    /// UInt8(ascii: "中")    // nil (CJK character)
    /// ```
    ///
    /// - Parameter ascii: The character to convert to ASCII byte
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986``
    /// - ``ASCII``
    @inline(always)
    public init?(ascii character: Character) {
        guard let value = character.asciiValue else { return nil }
        self = value
    }
}

extension Binary.ASCII {
    // MARK: - ASCII Validation

    /// Tests if this byte is valid ASCII (0x00-0x7F)
    ///
    /// Per INCITS 4-1986, valid ASCII bytes are in the range 0-127 (0x00-0x7F).
    /// Bytes with the high bit set (>= 0x80) are not valid ASCII.
    ///
    /// Use this predicate before calling other `.ascii` methods when processing
    /// untrusted byte data to ensure correct semantics.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt8(0x41).ascii.isASCII  // true ('A')
    /// UInt8(0x7F).ascii.isASCII  // true (DEL - last ASCII character)
    /// UInt8(0x80).ascii.isASCII  // false (first non-ASCII byte)
    /// UInt8(0xFF).ascii.isASCII  // false
    ///
    /// // Validate before using other .ascii methods
    /// if byte.ascii.isASCII && byte.ascii.isWhitespace { ... }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/isASCII(_:)``
    @_transparent
    public var isASCII: Bool {
        INCITS_4_1986.isASCII(byte)
    }

    // MARK: - Character Classification

    /// Tests if byte is ASCII whitespace
    ///
    /// Returns `true` for the four ASCII whitespace characters defined in INCITS 4-1986:
    /// - **SPACE** (0x20): Word separator
    /// - **HORIZONTAL TAB** (0x09): Tabulation
    /// - **LINE FEED** (0x0A): End of line (Unix/macOS)
    /// - **CARRIAGE RETURN** (0x0D): End of line (classic Mac, Internet protocols)
    ///
    /// ## Performance
    ///
    /// This method is marked `@_transparent` for zero-overhead abstraction. It uses four inline
    /// equality comparisons rather than a Set lookup, which is faster for this small, fixed set.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt8.ascii.sp.ascii.isWhitespace      // true (SPACE)
    /// UInt8.ascii.htab.ascii.isWhitespace    // true (TAB)
    /// UInt8.ascii.lf.ascii.isWhitespace      // true (LF)
    /// UInt8.ascii.cr.ascii.isWhitespace      // true (CR)
    /// UInt8.ascii.A.ascii.isWhitespace       // false
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/whitespaces``
    /// - ``INCITS_4_1986/CharacterClassification/isWhitespace(_:)``
    @_transparent
    public var isWhitespace: Bool {
        INCITS_4_1986.CharacterClassification.isWhitespace(byte)
    }

    /// Tests if byte is ASCII control character
    ///
    /// Returns `true` for all 33 control characters defined in INCITS 4-1986:
    /// - **C0 controls**: 0x00-0x1F (NULL, SOH, STX, ..., US)
    /// - **DELETE**: 0x7F
    ///
    /// Control characters are non-printing characters used for device control, data transmission,
    /// and text formatting. They do not have visual representations.
    ///
    /// ## Control Character Ranges
    ///
    /// - **0x00 (NUL)** through **0x1F (US)**: 32 control characters
    /// - **0x7F (DEL)**: The DELETE character
    ///
    /// ## Performance
    ///
    /// This method uses two range comparisons for optimal performance, marked `@_transparent`
    /// for inline expansion.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt8.ascii.nul.ascii.isControl   // true (0x00)
    /// UInt8.ascii.lf.ascii.isControl    // true (0x0A)
    /// UInt8.ascii.del.ascii.isControl   // true (0x7F)
    /// UInt8.ascii.sp.ascii.isControl    // false (SPACE is graphic)
    /// UInt8.ascii.A.ascii.isControl     // false
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/ControlCharacters``
    /// - ``INCITS_4_1986/CharacterClassification/isControl(_:)``
    @_transparent
    public var isControl: Bool {
        INCITS_4_1986.CharacterClassification.isControl(byte)
    }

    /// Tests if byte is ASCII visible (non-whitespace printable) character
    ///
    /// Returns `true` for visible graphic characters (0x21-0x7E), which are printable characters
    /// **excluding SPACE**. These are characters with distinct visual glyphs.
    ///
    /// ## Character Range
    ///
    /// - **0x21 ('!')** through **0x7E ('~')**: 94 visible characters
    /// - Includes: digits, letters, punctuation, and symbols
    /// - Excludes: SPACE (0x20), all control characters, and DELETE (0x7F)
    ///
    /// ## Comparison with isPrintable
    ///
    /// - ``isVisible``: Excludes SPACE (94 characters)
    /// - ``isPrintable``: Includes SPACE (95 characters)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt8.ascii.A.ascii.isVisible          // true
    /// UInt8.ascii.0.ascii.isVisible          // true
    /// UInt8.ascii.exclamationPoint.ascii.isVisible  // true
    /// UInt8.ascii.sp.ascii.isVisible         // false (SPACE not visible)
    /// UInt8.ascii.lf.ascii.isVisible         // false (control character)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``isPrintable``
    /// - ``INCITS_4_1986/GraphicCharacters``
    /// - ``INCITS_4_1986/CharacterClassification/isVisible(_:)``
    @_transparent
    public var isVisible: Bool {
        INCITS_4_1986.CharacterClassification.isVisible(byte)
    }

    /// Tests if byte is ASCII printable (graphic) character
    ///
    /// Returns `true` for all printable graphic characters (0x20-0x7E), which includes both
    /// visible characters and SPACE. These are the 95 characters that can appear in displayed text.
    ///
    /// ## Character Range
    ///
    /// - **0x20 (SPACE)** through **0x7E ('~')**: 95 printable characters
    /// - Includes: SPACE, digits, letters, punctuation, and symbols
    /// - Excludes: Control characters (0x00-0x1F) and DELETE (0x7F)
    ///
    /// ## Comparison with isVisible
    ///
    /// - ``isPrintable``: Includes SPACE (95 characters)
    /// - ``isVisible``: Excludes SPACE (94 characters)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt8.ascii.A.ascii.isPrintable        // true
    /// UInt8.ascii.0.ascii.isPrintable        // true
    /// UInt8.ascii.sp.ascii.isPrintable       // true (SPACE is printable)
    /// UInt8.ascii.lf.ascii.isPrintable       // false (control character)
    /// UInt8.ascii.del.ascii.isPrintable      // false (DELETE)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``isVisible``
    /// - ``INCITS_4_1986/GraphicCharacters``
    /// - ``INCITS_4_1986/SPACE``
    /// - ``INCITS_4_1986/CharacterClassification/isPrintable(_:)``
    @_transparent
    public var isPrintable: Bool {
        INCITS_4_1986.CharacterClassification.isPrintable(byte)
    }

    // MARK: - Character Classification

    /// Tests if byte is ASCII digit ('0'...'9')
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/CharacterClassification/isDigit(_:)``
    @_transparent
    public var isDigit: Bool {
        INCITS_4_1986.CharacterClassification.isDigit(byte)
    }

    /// Tests if byte is ASCII letter ('A'...'Z' or 'a'...'z')
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/CharacterClassification/isLetter(_:)``
    @_transparent
    public var isLetter: Bool {
        INCITS_4_1986.CharacterClassification.isLetter(byte)
    }

    /// Tests if byte is ASCII alphanumeric (digit or letter)
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/CharacterClassification/isAlphanumeric(_:)``
    @_transparent
    public var isAlphanumeric: Bool {
        INCITS_4_1986.CharacterClassification.isAlphanumeric(byte)
    }

    /// Tests if byte is ASCII hexadecimal digit ('0'...'9', 'A'...'F', 'a'...'f')
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/CharacterClassification/isHexDigit(_:)``
    @_transparent
    public var isHexDigit: Bool {
        INCITS_4_1986.CharacterClassification.isHexDigit(byte)
    }

    /// Tests if byte is ASCII uppercase letter ('A'...'Z')
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/CharacterClassification/isUppercase(_:)``
    @_transparent
    public var isUppercase: Bool {
        INCITS_4_1986.CharacterClassification.isUppercase(byte)
    }

    /// Tests if byte is ASCII lowercase letter ('a'...'z')
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/CharacterClassification/isLowercase(_:)``
    @_transparent
    public var isLowercase: Bool {
        INCITS_4_1986.CharacterClassification.isLowercase(byte)
    }

    @_transparent
    public func lowercased() -> UInt8 {
        INCITS_4_1986.Case.Conversion.convert(byte, to: .lower)
    }

    @_transparent
    public func uppercased() -> UInt8 {
        INCITS_4_1986.Case.Conversion.convert(byte, to: .upper)
    }
}

extension Binary.ASCII {
    // MARK: - Numeric Value Parsing (Static Transformations)

    /// Parses an ASCII digit byte to its numeric value (0-9)
    ///
    /// Pure function transformation from ASCII digit to numeric value.
    /// Inverse operation of the `isDigit` predicate.
    /// Forms a Galois connection between predicates and values.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt8(ascii: digit: 0x30)  // 0 (character '0')
    /// UInt8(ascii: digit: 0x35)  // 5 (character '5')
    /// UInt8(ascii: digit: 0x39)  // 9 (character '9')
    /// UInt8(ascii: digit: 0x41)  // nil (character 'A')
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/NumericParsing/digit(_:)``
    @inlinable
    public static func ascii(digit byte: UInt8) -> UInt8? {
        INCITS_4_1986.NumericParsing.digit(byte)
    }
}

extension Binary.ASCII {
    /// Parses an ASCII hex digit byte to its numeric value (0-15)
    ///
    /// Pure function transformation from ASCII hex digit to numeric value.
    /// Inverse operation of the `isHexDigit` predicate.
    /// Forms a Galois connection between predicates and values.
    ///
    /// Supports both uppercase and lowercase hex digits:
    /// - '0'...'9' → 0...9
    /// - 'A'...'F' → 10...15
    /// - 'a'...'f' → 10...15
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt8(ascii: hexDigit: 0x30)  // 0 (character '0')
    /// UInt8(ascii: hexDigit: 0x39)  // 9 (character '9')
    /// UInt8(ascii: hexDigit: 0x41)  // 10 (character 'A')
    /// UInt8(ascii: hexDigit: 0x46)  // 15 (character 'F')
    /// UInt8(ascii: hexDigit: 0x61)  // 10 (character 'a')
    /// UInt8(ascii: hexDigit: 0x66)  // 15 (character 'f')
    /// UInt8(ascii: hexDigit: 0x47)  // nil (character 'G')
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/NumericParsing/hexDigit(_:)``
    @inlinable
    public static func ascii(hexDigit byte: UInt8) -> UInt8? {
        INCITS_4_1986.NumericParsing.hexDigit(byte)
    }
}

extension Binary.ASCII {
    /// Parses an ASCII digit byte via call syntax
    ///
    /// Enables the convenient syntax: `UInt8(ascii: digit: byte)`
    @inlinable
    public static func callAsFunction(digit byte: UInt8) -> UInt8? {
        INCITS_4_1986.NumericParsing.digit(byte)
    }

    /// Parses an ASCII hex digit byte via call syntax
    ///
    /// Enables the convenient syntax: `UInt8(ascii: hexDigit: byte)`
    @inlinable
    public static func callAsFunction(hexDigit byte: UInt8) -> UInt8? {
        INCITS_4_1986.NumericParsing.hexDigit(byte)
    }

    /// Returns the byte if it's valid ASCII, nil otherwise
    ///
    /// Validates that the byte is in the ASCII range (0x00-0x7F).
    ///
    /// ```swift
    /// let valid = UInt8(0x41)
    /// valid.ascii()  // Optional(0x41)
    ///
    /// let invalid = UInt8(0xFF)
    /// invalid.ascii()  // nil
    /// ```
    @inlinable
    public func callAsFunction() -> UInt8? {
        byte <= .ascii.del ? byte : nil
    }

    /// Converts ASCII letter to specified case via call syntax
    ///
    /// This enables the convenient syntax: `byte.ascii(case: .upper)`
    @inlinable
    public func callAsFunction(case: Character.Case) -> UInt8 {
        INCITS_4_1986.Case.Conversion.convert(byte, to: `case`)
    }

    /// Creates ASCII byte from a character without validation
    ///
    /// Converts a Swift `Character` to its byte value, assuming it's valid ASCII without validation.
    /// This method provides optimal performance when the caller can guarantee ASCII validity.
    ///
    /// ## Performance
    ///
    /// This method skips validation, making it more efficient than the failable initializer
    /// `UInt8(ascii:)` when you know the character is ASCII. It uses Swift's built-in UTF-8
    /// encoding to extract the first byte.
    ///
    /// ## Safety
    ///
    /// **Important**: This method does not validate the input. If the character is not ASCII,
    /// the result will be the first UTF-8 byte of the character's encoding, which may not be
    /// what you expect.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // When you know the character is ASCII
    /// let byte = UInt8.ascii.unchecked("A")  // 0x41
    /// let digit = UInt8.ascii.unchecked("5")  // 0x35
    /// let space = UInt8.ascii.unchecked(" ")  // 0x20
    /// ```
    ///
    /// - Parameter character: The character to convert to a byte (assumed ASCII, no checking performed)
    /// - Returns: The byte value of the character
    ///
    /// ## See Also
    ///
    /// - ``UInt8/init(ascii:)``
    @inline(always)
    public static func unchecked(_ character: Character) -> UInt8 {
        character.utf8.first!
    }
}

extension Binary.ASCII {
    // MARK: - Control Characters (direct access)

    /// NULL character (0x00)
    public static var nul: UInt8 { INCITS_4_1986.Character.Control.nul }

    /// START OF HEADING (0x01)
    public static var soh: UInt8 { INCITS_4_1986.Character.Control.soh }

    /// START OF TEXT (0x02)
    public static var stx: UInt8 { INCITS_4_1986.Character.Control.stx }

    /// END OF TEXT (0x03)
    public static var etx: UInt8 { INCITS_4_1986.Character.Control.etx }

    /// END OF TRANSMISSION (0x04)
    public static var eot: UInt8 { INCITS_4_1986.Character.Control.eot }

    /// ENQUIRY (0x05)
    public static var enq: UInt8 { INCITS_4_1986.Character.Control.enq }

    /// ACKNOWLEDGE (0x06)
    public static var ack: UInt8 { INCITS_4_1986.Character.Control.ack }

    /// BELL (0x07)
    public static var bel: UInt8 { INCITS_4_1986.Character.Control.bel }

    /// BACKSPACE (0x08)
    public static var bs: UInt8 { INCITS_4_1986.Character.Control.bs }

    /// HORIZONTAL TAB (0x09)
    public static var htab: UInt8 { INCITS_4_1986.Character.Control.htab }
    public static var tab: UInt8 { INCITS_4_1986.Character.Control.htab }

    /// LINE FEED (0x0A)
    public static var lf: UInt8 { INCITS_4_1986.Character.Control.lf }
    public static var newline: UInt8 { INCITS_4_1986.Character.Control.lf }

    /// VERTICAL TAB (0x0B)
    public static var vtab: UInt8 { INCITS_4_1986.Character.Control.vtab }

    /// FORM FEED (0x0C)
    public static var ff: UInt8 { INCITS_4_1986.Character.Control.ff }

    /// CARRIAGE RETURN (0x0D)
    public static var cr: UInt8 { INCITS_4_1986.Character.Control.cr }

    /// SHIFT OUT (0x0E)
    public static var so: UInt8 { INCITS_4_1986.Character.Control.so }

    /// SHIFT IN (0x0F)
    public static var si: UInt8 { INCITS_4_1986.Character.Control.si }

    /// DATA LINK ESCAPE (0x10)
    public static var dle: UInt8 { INCITS_4_1986.Character.Control.dle }

    /// DEVICE CONTROL ONE (0x11)
    public static var dc1: UInt8 { INCITS_4_1986.Character.Control.dc1 }

    /// DEVICE CONTROL TWO (0x12)
    public static var dc2: UInt8 { INCITS_4_1986.Character.Control.dc2 }

    /// DEVICE CONTROL THREE (0x13)
    public static var dc3: UInt8 { INCITS_4_1986.Character.Control.dc3 }

    /// DEVICE CONTROL FOUR (0x14)
    public static var dc4: UInt8 { INCITS_4_1986.Character.Control.dc4 }

    /// NEGATIVE ACKNOWLEDGE (0x15)
    public static var nak: UInt8 { INCITS_4_1986.Character.Control.nak }

    /// SYNCHRONOUS IDLE (0x16)
    public static var syn: UInt8 { INCITS_4_1986.Character.Control.syn }

    /// END OF TRANSMISSION BLOCK (0x17)
    public static var etb: UInt8 { INCITS_4_1986.Character.Control.etb }

    /// CANCEL (0x18)
    public static var can: UInt8 { INCITS_4_1986.Character.Control.can }

    /// END OF MEDIUM (0x19)
    public static var em: UInt8 { INCITS_4_1986.Character.Control.em }

    /// SUBSTITUTE (0x1A)
    public static var sub: UInt8 { INCITS_4_1986.Character.Control.sub }

    /// ESCAPE (0x1B)
    public static var esc: UInt8 { INCITS_4_1986.Character.Control.esc }

    /// FILE SEPARATOR (0x1C)
    public static var fs: UInt8 { INCITS_4_1986.Character.Control.fs }

    /// GROUP SEPARATOR (0x1D)
    public static var gs: UInt8 { INCITS_4_1986.Character.Control.gs }

    /// RECORD SEPARATOR (0x1E)
    public static var rs: UInt8 { INCITS_4_1986.Character.Control.rs }

    /// UNIT SEPARATOR (0x1F)
    public static var us: UInt8 { INCITS_4_1986.Character.Control.us }

    /// DELETE (0x7F)
    public static var del: UInt8 { INCITS_4_1986.Character.Control.del }

    // MARK: - SPACE (direct access)

    /// SPACE (0x20)
    public static var sp: UInt8 { INCITS_4_1986.SPACE.sp }
    public static var space: UInt8 { INCITS_4_1986.SPACE.sp }

    // MARK: - Graphic Characters - Punctuation (direct access)

    /// EXCLAMATION POINT (0x21) - !
    public static var exclamationPoint: UInt8 { INCITS_4_1986.Character.Graphic.exclamationPoint }

    /// QUOTATION MARK (0x22) - "
    public static var quotationMark: UInt8 { INCITS_4_1986.Character.Graphic.quotationMark }
    public static var dquote: UInt8 { INCITS_4_1986.Character.Graphic.quotationMark }
    public static var doubleQuote: UInt8 { INCITS_4_1986.Character.Graphic.quotationMark }

    /// NUMBER SIGN (0x23) - #
    public static var numberSign: UInt8 { INCITS_4_1986.Character.Graphic.numberSign }

    /// DOLLAR SIGN (0x24) - $
    public static var dollarSign: UInt8 { INCITS_4_1986.Character.Graphic.dollarSign }

    /// PERCENT SIGN (0x25) - %
    public static var percentSign: UInt8 { INCITS_4_1986.Character.Graphic.percentSign }

    /// AMPERSAND (0x26) - &
    public static var ampersand: UInt8 { INCITS_4_1986.Character.Graphic.ampersand }

    /// APOSTROPHE (0x27) - '
    public static var apostrophe: UInt8 { INCITS_4_1986.Character.Graphic.apostrophe }

    /// LEFT PARENTHESIS (0x28) - (
    public static var leftParenthesis: UInt8 { INCITS_4_1986.Character.Graphic.leftParenthesis }

    /// RIGHT PARENTHESIS (0x29) - )
    public static var rightParenthesis: UInt8 { INCITS_4_1986.Character.Graphic.rightParenthesis }

    /// ASTERISK (0x2A) - *
    public static var asterisk: UInt8 { INCITS_4_1986.Character.Graphic.asterisk }

    /// PLUS SIGN (0x2B) - +
    public static var plusSign: UInt8 { INCITS_4_1986.Character.Graphic.plusSign }
    public static var plus: UInt8 { INCITS_4_1986.Character.Graphic.plusSign }

    /// COMMA (0x2C) - ,
    public static var comma: UInt8 { INCITS_4_1986.Character.Graphic.comma }

    /// HYPHEN, MINUS SIGN (0x2D) - -
    public static var hyphen: UInt8 { INCITS_4_1986.Character.Graphic.hyphen }

    /// PERIOD, DECIMAL POINT (0x2E) - .
    public static var period: UInt8 { INCITS_4_1986.Character.Graphic.period }

    /// SLANT (SOLIDUS) (0x2F) - /
    public static var slant: UInt8 { INCITS_4_1986.Character.Graphic.slant }
    public static var solidus: UInt8 { INCITS_4_1986.Character.Graphic.solidus }
    public static var slash: UInt8 { INCITS_4_1986.Character.Graphic.slant }
    public static var forwardSlash: UInt8 { INCITS_4_1986.Character.Graphic.slant }

    // MARK: - Graphic Characters - Digits (direct access)

    /// DIGIT ZERO (0x30) - 0
    public static var `0`: UInt8 { INCITS_4_1986.Character.Graphic.`0` }

    /// DIGIT ONE (0x31) - 1
    public static var `1`: UInt8 { INCITS_4_1986.Character.Graphic.`1` }

    /// DIGIT TWO (0x32) - 2
    public static var `2`: UInt8 { INCITS_4_1986.Character.Graphic.`2` }

    /// DIGIT THREE (0x33) - 3
    public static var `3`: UInt8 { INCITS_4_1986.Character.Graphic.`3` }

    /// DIGIT FOUR (0x34) - 4
    public static var `4`: UInt8 { INCITS_4_1986.Character.Graphic.`4` }

    /// DIGIT FIVE (0x35) - 5
    public static var `5`: UInt8 { INCITS_4_1986.Character.Graphic.`5` }

    /// DIGIT SIX (0x36) - 6
    public static var `6`: UInt8 { INCITS_4_1986.Character.Graphic.`6` }

    /// DIGIT SEVEN (0x37) - 7
    public static var `7`: UInt8 { INCITS_4_1986.Character.Graphic.`7` }

    /// DIGIT EIGHT (0x38) - 8
    public static var `8`: UInt8 { INCITS_4_1986.Character.Graphic.`8` }

    /// DIGIT NINE (0x39) - 9
    public static var `9`: UInt8 { INCITS_4_1986.Character.Graphic.`9` }

    // MARK: - Graphic Characters - More Punctuation (direct access)

    /// COLON (0x3A) - :
    public static var colon: UInt8 { INCITS_4_1986.Character.Graphic.colon }

    /// SEMICOLON (0x3B) - ;
    public static var semicolon: UInt8 { INCITS_4_1986.Character.Graphic.semicolon }

    /// LESS-THAN SIGN (0x3C) - <
    public static var lessThanSign: UInt8 { INCITS_4_1986.Character.Graphic.lessThanSign }

    /// EQUALS SIGN (0x3D) - =
    public static var equalsSign: UInt8 { INCITS_4_1986.Character.Graphic.equalsSign }

    /// GREATER-THAN SIGN (0x3E) - >
    public static var greaterThanSign: UInt8 { INCITS_4_1986.Character.Graphic.greaterThanSign }

    /// QUESTION MARK (0x3F) - ?
    public static var questionMark: UInt8 { INCITS_4_1986.Character.Graphic.questionMark }

    /// COMMERCIAL AT (0x40) - @
    public static var commercialAt: UInt8 { INCITS_4_1986.Character.Graphic.commercialAt }

    // MARK: - Graphic Characters - Uppercase Letters (direct access)

    /// CAPITAL LETTER A (0x41)
    public static var A: UInt8 { INCITS_4_1986.Character.Graphic.A }

    /// CAPITAL LETTER B (0x42)
    public static var B: UInt8 { INCITS_4_1986.Character.Graphic.B }

    /// CAPITAL LETTER C (0x43)
    public static var C: UInt8 { INCITS_4_1986.Character.Graphic.C }

    /// CAPITAL LETTER D (0x44)
    public static var D: UInt8 { INCITS_4_1986.Character.Graphic.D }

    /// CAPITAL LETTER E (0x45)
    public static var E: UInt8 { INCITS_4_1986.Character.Graphic.E }

    /// CAPITAL LETTER F (0x46)
    public static var F: UInt8 { INCITS_4_1986.Character.Graphic.F }

    /// CAPITAL LETTER G (0x47)
    public static var G: UInt8 { INCITS_4_1986.Character.Graphic.G }

    /// CAPITAL LETTER H (0x48)
    public static var H: UInt8 { INCITS_4_1986.Character.Graphic.H }

    /// CAPITAL LETTER I (0x49)
    public static var I: UInt8 { INCITS_4_1986.Character.Graphic.I }

    /// CAPITAL LETTER J (0x4A)
    public static var J: UInt8 { INCITS_4_1986.Character.Graphic.J }

    /// CAPITAL LETTER K (0x4B)
    public static var K: UInt8 { INCITS_4_1986.Character.Graphic.K }

    /// CAPITAL LETTER L (0x4C)
    public static var L: UInt8 { INCITS_4_1986.Character.Graphic.L }

    /// CAPITAL LETTER M (0x4D)
    public static var M: UInt8 { INCITS_4_1986.Character.Graphic.M }

    /// CAPITAL LETTER N (0x4E)
    public static var N: UInt8 { INCITS_4_1986.Character.Graphic.N }

    /// CAPITAL LETTER O (0x4F)
    public static var O: UInt8 { INCITS_4_1986.Character.Graphic.O }

    /// CAPITAL LETTER P (0x50)
    public static var P: UInt8 { INCITS_4_1986.Character.Graphic.P }

    /// CAPITAL LETTER Q (0x51)
    public static var Q: UInt8 { INCITS_4_1986.Character.Graphic.Q }

    /// CAPITAL LETTER R (0x52)
    public static var R: UInt8 { INCITS_4_1986.Character.Graphic.R }

    /// CAPITAL LETTER S (0x53)
    public static var S: UInt8 { INCITS_4_1986.Character.Graphic.S }

    /// CAPITAL LETTER T (0x54)
    public static var T: UInt8 { INCITS_4_1986.Character.Graphic.T }

    /// CAPITAL LETTER U (0x55)
    public static var U: UInt8 { INCITS_4_1986.Character.Graphic.U }

    /// CAPITAL LETTER V (0x56)
    public static var V: UInt8 { INCITS_4_1986.Character.Graphic.V }

    /// CAPITAL LETTER W (0x57)
    public static var W: UInt8 { INCITS_4_1986.Character.Graphic.W }

    /// CAPITAL LETTER X (0x58)
    public static var X: UInt8 { INCITS_4_1986.Character.Graphic.X }

    /// CAPITAL LETTER Y (0x59)
    public static var Y: UInt8 { INCITS_4_1986.Character.Graphic.Y }

    /// CAPITAL LETTER Z (0x5A)
    public static var Z: UInt8 { INCITS_4_1986.Character.Graphic.Z }

    // MARK: - Graphic Characters - Brackets and Symbols (direct access)

    /// LEFT BRACKET (0x5B) - [
    public static var leftBracket: UInt8 { INCITS_4_1986.Character.Graphic.leftBracket }
    public static var leftSquareBracket: UInt8 { INCITS_4_1986.Character.Graphic.leftBracket }

    /// REVERSE SLANT (0x5C) - \
    public static var reverseSlant: UInt8 { INCITS_4_1986.Character.Graphic.reverseSlant }
    public static var reverseSolidus: UInt8 { INCITS_4_1986.Character.Graphic.reverseSolidus }
    public static var backslash: UInt8 { INCITS_4_1986.Character.Graphic.reverseSolidus }

    /// RIGHT BRACKET (0x5D) - ]
    public static var rightBracket: UInt8 { INCITS_4_1986.Character.Graphic.rightBracket }
    public static var rightSquareBracket: UInt8 { INCITS_4_1986.Character.Graphic.rightBracket }

    /// CIRCUMFLEX ACCENT (0x5E) - ^
    public static var circumflexAccent: UInt8 { INCITS_4_1986.Character.Graphic.circumflexAccent }

    /// UNDERLINE (LOW LINE) (0x5F) - _
    public static var underline: UInt8 { INCITS_4_1986.Character.Graphic.underline }

    /// LEFT SINGLE QUOTATION MARK, GRAVE ACCENT (0x60) - `
    public static var leftSingleQuotationMark: UInt8 { INCITS_4_1986.Character.Graphic.leftSingleQuotationMark }

    // MARK: - Graphic Characters - Lowercase Letters (direct access)

    /// SMALL LETTER A (0x61)
    public static var a: UInt8 { INCITS_4_1986.Character.Graphic.a }

    /// SMALL LETTER B (0x62)
    public static var b: UInt8 { INCITS_4_1986.Character.Graphic.b }

    /// SMALL LETTER C (0x63)
    public static var c: UInt8 { INCITS_4_1986.Character.Graphic.c }

    /// SMALL LETTER D (0x64)
    public static var d: UInt8 { INCITS_4_1986.Character.Graphic.d }

    /// SMALL LETTER E (0x65)
    public static var e: UInt8 { INCITS_4_1986.Character.Graphic.e }

    /// SMALL LETTER F (0x66)
    public static var f: UInt8 { INCITS_4_1986.Character.Graphic.f }

    /// SMALL LETTER G (0x67)
    public static var g: UInt8 { INCITS_4_1986.Character.Graphic.g }

    /// SMALL LETTER H (0x68)
    public static var h: UInt8 { INCITS_4_1986.Character.Graphic.h }

    /// SMALL LETTER I (0x69)
    public static var i: UInt8 { INCITS_4_1986.Character.Graphic.i }

    /// SMALL LETTER J (0x6A)
    public static var j: UInt8 { INCITS_4_1986.Character.Graphic.j }

    /// SMALL LETTER K (0x6B)
    public static var k: UInt8 { INCITS_4_1986.Character.Graphic.k }

    /// SMALL LETTER L (0x6C)
    public static var l: UInt8 { INCITS_4_1986.Character.Graphic.l }

    /// SMALL LETTER M (0x6D)
    public static var m: UInt8 { INCITS_4_1986.Character.Graphic.m }

    /// SMALL LETTER N (0x6E)
    public static var n: UInt8 { INCITS_4_1986.Character.Graphic.n }

    /// SMALL LETTER O (0x6F)
    public static var o: UInt8 { INCITS_4_1986.Character.Graphic.o }

    /// SMALL LETTER P (0x70)
    public static var p: UInt8 { INCITS_4_1986.Character.Graphic.p }

    /// SMALL LETTER Q (0x71)
    public static var q: UInt8 { INCITS_4_1986.Character.Graphic.q }

    /// SMALL LETTER R (0x72)
    public static var r: UInt8 { INCITS_4_1986.Character.Graphic.r }

    /// SMALL LETTER S (0x73)
    public static var s: UInt8 { INCITS_4_1986.Character.Graphic.s }

    /// SMALL LETTER T (0x74)
    public static var t: UInt8 { INCITS_4_1986.Character.Graphic.t }

    /// SMALL LETTER U (0x75)
    public static var u: UInt8 { INCITS_4_1986.Character.Graphic.u }

    /// SMALL LETTER V (0x76)
    public static var v: UInt8 { INCITS_4_1986.Character.Graphic.v }

    /// SMALL LETTER W (0x77)
    public static var w: UInt8 { INCITS_4_1986.Character.Graphic.w }

    /// SMALL LETTER X (0x78)
    public static var x: UInt8 { INCITS_4_1986.Character.Graphic.x }

    /// SMALL LETTER Y (0x79)
    public static var y: UInt8 { INCITS_4_1986.Character.Graphic.y }

    /// SMALL LETTER Z (0x7A)
    public static var z: UInt8 { INCITS_4_1986.Character.Graphic.z }

    // MARK: - Graphic Characters - Final Symbols (direct access)

    /// LEFT BRACE (0x7B) - {
    public static var leftBrace: UInt8 { INCITS_4_1986.Character.Graphic.leftBrace }

    /// VERTICAL LINE (0x7C) - |
    public static var verticalLine: UInt8 { INCITS_4_1986.Character.Graphic.verticalLine }

    /// RIGHT BRACE (0x7D) - }
    public static var rightBrace: UInt8 { INCITS_4_1986.Character.Graphic.rightBrace }

    /// TILDE (OVERLINE) (0x7E) - ~
    public static var tilde: UInt8 { INCITS_4_1986.Character.Graphic.tilde }
}

// Conveniences for common shorthands
extension Binary.ASCII {
    /// LESS-THAN SIGN (0x3C) - <
    public static var lt: UInt8 { INCITS_4_1986.Character.Graphic.lessThanSign }
    public static var lessThan: UInt8 { INCITS_4_1986.Character.Graphic.lessThanSign }

    /// GREATER-THAN SIGN (0x3E) - >
    public static var gt: UInt8 { INCITS_4_1986.Character.Graphic.greaterThanSign }
    public static var greaterThan: UInt8 { INCITS_4_1986.Character.Graphic.greaterThanSign }

    /// COMMERCIAL AT (0x40) - @
    public static var at: UInt8 { INCITS_4_1986.Character.Graphic.commercialAt }
    public static var atSign: UInt8 { INCITS_4_1986.Character.Graphic.commercialAt }
}
