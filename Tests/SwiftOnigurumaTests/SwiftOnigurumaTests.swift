import XCTest
@testable import SwiftOniguruma

// swiftlint:disable file_length type_body_length
final class SwiftOnigurumaTests: XCTestCase {
    func testSearch() {
        let regex = try? OnigRegularExpression(pattern: "a(.*)b|[e-f]+")
        XCTAssertNotNil(regex)

        let matches = try? regex?.search(in: "zzzzaffffffffb")
        XCTAssertNotNil(matches)
        XCTAssert(matches!.isEmpty == false)
        XCTAssert(matches!.count == 2)
        XCTAssert(matches![0] == (4, 14))
        XCTAssert(matches![1] == (5, 13))
    }

    func testSearchEmpty() {
        let regex = try? OnigRegularExpression(pattern: "")
        XCTAssertNotNil(regex)

        let matches = try? regex?.search(in: "a", direction: .backward)
        XCTAssertNotNil(matches)
        XCTAssert(matches!.isEmpty == false)
        XCTAssert(matches!.count == 1)
        XCTAssert(matches![0] == (1, 1))
    }

    func testScan() {
        let regex = try? OnigRegularExpression(pattern: "a+\\s*")
        XCTAssertNotNil(regex)

        var matchesPositions: [Int] = []
        var matchesLengths: [Int] = []
        let processMatches: ScanCallback = { (_, _, match) in
            let numberOfMatchers = match.count
            for i in 0..<numberOfMatchers {
                let (start, end) = match[i]

                matchesPositions.append(Int(start))
                matchesLengths.append(Int(end - start))
            }

            return true
        }

        var nrMatches = try? regex!.scan(source: "a aa aaa baaa", callback: processMatches)
        XCTAssert(nrMatches == 4)
        XCTAssert(matchesPositions == [0, 2, 5, 10])
        XCTAssert(matchesLengths == [2, 3, 4, 3])

        let regex2 = try? OnigRegularExpression(pattern: "\\Ga+\\s*")
        XCTAssertNotNil(regex)

        var matches: [Int] = []
        nrMatches = try? regex2!.scan(source: "a aa aaa baaa", callback: { (_, _, region) in
            let numberOfMatchers = region.count
            matches.append(Int(numberOfMatchers))

            return true
        })

        XCTAssert(nrMatches == 3)
        XCTAssert(matches == [1, 1, 1])
    }

    // swiftlint:disable function_body_length
    func testBack() {
        func x2(_ pattern: String, _ string: String, _ matchStart: Int, _ matchEnd: Int) {
            let regex = try? OnigRegularExpression(pattern: pattern)
            XCTAssertNotNil(regex)

            let match = try? regex?.search(in: string, direction: .backward)
            XCTAssertNotNil(match)
            XCTAssert(match!.isEmpty == false)
            XCTAssert(match![0] == (matchStart, matchEnd))
        }

        func n(_ pattern: String, _ string: String) {
            let regex = try? OnigRegularExpression(pattern: pattern)
            XCTAssertNotNil(regex)

            let match = try? regex?.search(in: string, direction: .backward)
            XCTAssert(match!.isEmpty)
        }

        func x3(_ pattern: String, _ string: String, _ matchStart: Int, _ matchEnd: Int, _ matchIndex: Int) {
            let regex = try? OnigRegularExpression(pattern: pattern)
            XCTAssertNotNil(regex)

            let matches = try? regex?.search(in: string, direction: .backward)
            XCTAssertNotNil(matches)
            XCTAssert(matches!.isEmpty == false)
            XCTAssert(matches![matchIndex] == (matchStart, matchEnd))
        }

        // swiftlint:disable trailing_semicolon
        // Hint: Copied from test_back.c
        x2("", "", 0, 0);
        x2("^", "", 0, 0);
        x2("^a", "\na", 1, 2);
        x2("$", "", 0, 0);
        x2("$\\O", "bb\n", 2, 3);
        x2("\\G", "", 0, 0);
        x2("\\A", "", 0, 0);
        x2("\\Z", "", 0, 0);
        x2("\\z", "", 0, 0);
        x2("^$", "", 0, 0);
        x2("\\ca", "\u{1}", 0, 1);
        x2("\\C-b", "\u{2}", 0, 1);
        x2("\\c\\\\", "\u{1c}", 0, 1);
        x2("q[\\c\\\\]", "q\u{1c}", 0, 2);
        x2("", "a", 1, 1);
        x2("a", "a", 0, 1);
        x2("\\x61", "a", 0, 1);
        x2("aa", "aa", 0, 2);
        x2("aaa", "aaa", 0, 3);
        x2("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, 35);
        x2("ab", "ab", 0, 2);
        x2("b", "ab", 1, 2);
        x2("bc", "abc", 1, 3);
        x2("(?i:#RET#)", "#INS##RET#", 5, 10);
        x2("\\17", "\u{f}", 0, 1);
        x2("\\x1f", "\u{1f}", 0, 1);
        x2("a(?#....\\\\JJJJ)b", "ab", 0, 2);
        x2("(?x)  G (o O(?-x)oO) g L", "GoOoOgLe", 0, 7);
        x2(".", "a", 0, 1);
        x2("..", "ab", 0, 2);
        x2("\\w", "e", 0, 1);
        x2("\\s", " ", 0, 1);
        x2("\\S", "b", 0, 1);
        x2("\\d", "4", 0, 1);
        x2("\\b", "z ", 1, 1);
        x2("\\b", " z", 2, 2);
        x2("\\b", "  z ", 3, 3);
        x2("\\B", "zz ", 3, 3);
        x2("\\B", "z ", 2, 2);
        x2("\\B", " z", 0, 0);
        x2("[ab]", "b", 0, 1);
        x2("[a-z]", "t", 0, 1);
        x2("[^a]", "\n", 0, 1);
        x2("[]]", "]", 0, 1);
        x2("[\\^]+", "0^^1", 2, 3);
        x2("[b-]", "b", 0, 1);
        x2("[b-]", "-", 0, 1);
        x2("[\\w]", "z", 0, 1);
        x2("[\\W]", "b$", 1, 2);
        x2("[\\d]", "5", 0, 1);
        x2("[\\D]", "t", 0, 1);
        x2("[\\s]", " ", 0, 1);
        x2("[\\S]", "b", 0, 1);
        x2("[\\w\\d]", "2", 0, 1);
        x2("[[:upper:]]", "B", 0, 1);
        x2("[*[:xdigit:]+]", "+", 0, 1);
        x2("[*[:xdigit:]+]", "GHIKK-9+*", 8, 9);
        x2("[*[:xdigit:]+]", "-@^+", 3, 4);
        x2("[[:upper]]", ":", 0, 1);
        x2("[\\044-\\047]", "\u{26}", 0, 1);
        x2("[\\x5a-\\x5c]", "\u{5b}", 0, 1);
        x2("[\\x6A-\\x6D]", "\u{6c}", 0, 1);
        x2("[\\[]", "[", 0, 1);
        x2("[\\]]", "]", 0, 1);
        x2("[&]", "&", 0, 1);
        x2("[[ab]]", "b", 0, 1);
        x2("[[ab]c]", "c", 0, 1);
        x2("[[ab]&&bc]", "b", 0, 1);
        x2("[a-z&&b-y&&c-x]", "w", 0, 1);
        x2("[[^a&&a]&&a-z]", "b", 0, 1);
        x2("[[^a-z&&bcdef]&&[^c-g]]", "h", 0, 1);
        x2("[^[^abc]&&[^cde]]", "c", 0, 1);
        x2("[^[^abc]&&[^cde]]", "e", 0, 1);
        x2("[a-&&-a]", "-", 0, 1);
        x2("a\\Wbc", "a bc", 0, 4);
        x2("a.b.c", "aabbc", 0, 5);
        x2(".\\wb\\W..c", "abb bcc", 0, 7);
        x2("\\s\\wzzz", " zzzz", 0, 5);
        x2("aa.b", "aabb", 0, 4);
        x2(".a", "aa", 0, 2);
        x2("^a", "a", 0, 1);
        x2("^a$", "a", 0, 1);
        x2("^\\w$", "a", 0, 1);
        x2("^\\wab$", "zab", 0, 3);
        x2("^\\wabcdef$", "zabcdef", 0, 7);
        x2("^\\w...def$", "zabcdef", 0, 7);
        x2("\\w\\w\\s\\Waaa\\d", "aa  aaa4", 0, 8);
        x2("\\A\\Z", "", 0, 0);
        x2("\\Axyz", "xyz", 0, 3);
        x2("xyz\\Z", "xyz", 0, 3);
        x2("xyz\\z", "xyz", 0, 3);
        x2("a\\Z", "a", 0, 1);
        x2("a+", "aaaa", 3, 4);
        x2("a+", "aabbb", 1, 2);
        x2("a+", "baaaa", 4, 5);
        x2(".?", "", 0, 0);
        x2(".?", "f", 1, 1);
        x2(".?", "\n", 1, 1);
        x2(".*", "", 0, 0);
        x2(".*", "abcde", 5, 5);
        x2(".+", "z", 0, 1);
        x2(".+", "zdswer\n", 5, 6);
        x2("(.*)a\\1f", "babfbac", 0, 4);
        x2("(.*)a\\1f", "bacbabf", 3, 7);
        x2("((.*)a\\2f)", "bacbabf", 3, 7);
        x2("(.*)a\\1f", "baczzzzzz\nbazz\nzzzzbabf", 19, 23);
        x2("a|b", "a", 0, 1);
        x2("a|b", "b", 0, 1);
        x2("|a", "a", 1, 1);
        x2("(|a)", "a", 1, 1);
        x2("ab|bc", "ab", 0, 2);
        x2("ab|bc", "bc", 0, 2);
        x2("z(?:ab|bc)", "zbc", 0, 3);
        x2("a(?:ab|bc)c", "aabc", 0, 4);
        x2("ab|(?:ac|az)", "az", 0, 2);
        x2("a|b|c", "dc", 1, 2);
        x2("a|b|cd|efg|h|ijk|lmn|o|pq|rstuvwx|yz", "pqr", 0, 2);
        x2("a|^z", "ba", 1, 2);
        x2("a|^z", "za", 1, 2);
        x2("a|\\Gz", "bza", 2, 3);
        x2("a|\\Gz", "za", 1, 2);
        x2("a|\\Az", "bza", 2, 3);
        x2("a|\\Az", "za", 1, 2);
        x2("a|b\\Z", "ba", 1, 2);
        x2("a|b\\Z", "b", 0, 1);
        x2("a|b\\z", "ba", 1, 2);
        x2("a|b\\z", "b", 0, 1);
        x2("\\w|\\s", " ", 0, 1);
        x2("(.)(((?<_>a)))\\k<_>", "zaa", 0, 3);
        x2("((?<name1>\\d)|(?<name2>\\w))(\\k<name1>|\\k<name2>)", "ff", 0, 2);
        x2("(?:(?<x>)|(?<x>efg))\\k<x>", "", 0, 0);
        x2("(?:(?<x>abc)|(?<x>efg))\\k<x>", "abcefgefg", 3, 9);

        // swiftlint:disable line_length
        x2("(?:(?<n1>.)|(?<n1>..)|(?<n1>...)|(?<n1>....)|(?<n1>.....)|(?<n1>......)|(?<n1>.......)|(?<n1>........)|(?<n1>.........)|(?<n1>..........)|(?<n1>...........)|(?<n1>............)|(?<n1>.............)|(?<n1>..............))\\k<n1>$", "a-pyumpyum", 2, 10);
        // swiftlint:enable line_length

        n(".", "");  n("\\W", "e");
        n("\\D", "4");
        n("[ab]", "c");
        n("[^a]", "a");  n("[^]]", "]");
        n("[\\w]", " ");  n("[\\d]", "e");
        n("[\\D]", "3");
        n("[\\s]", "a");
        n("[\\S]", " ");
        n("[\\w\\d]", " ");
        n("[[:upper]]", "A");
        n("[\\x6A-\\x6D]", "\u{6E}");
        n("^[0-9A-F]+ 0+ UNDEF ", "75F 00000000 SECT14A notype ()    External    | _rb_apply");
        n("[[^a]]", "a");
        n("[^[a]]", "a");
        n("[[ab]&&bc]", "a");
        n("[[ab]&&bc]", "c");
        n("[^a-z&&b-y&&c-x]", "w");
        n("[[^a&&a]&&a-z]", "a");
        n("[[^a-z&&bcdef]&&[^c-g]]", "c");  n("[^[^abc]&&[^cde]]", "f");
        n("[a\\-&&\\-a]", "&");
        n("\\wabc", " abc");  n(".a", "ab");
        n("^\\w$", " ");
        n("\\Gaz", "az");
        n("\\Gz", "bza");
        n("az\\A", "az");
        n("a\\Az", "az");
        n("\\W", "_");
        n("(?=z).", "a");
        n("(?!z)a", "z");
        n("(?i:A)", "b");
        n("(?i:[f-m])", "e");
        n("(?i:[^a-z])", "A");
        n("(?i:[^a-z])", "a");
        n(".", "\n");
        n("(?i)(?-i)a", "A");
        n("(?i)(?-i:a)", "A");
        n("a+", "");
        n("a|b|cd|efg|h|ijk|lmn|o|pq|rstuvwx|yz", "mn");
        n("\\w|\\w", " ");
        n("(?>a|abd)c", "abdc");
        n("a+|b+", "");
        n("ax{2}*a", "0axxxa1");
        n("a.{0,2}a", "0aXXXa0");
        n("a.{0,2}?a", "0aXXXa0");
        n("a.{0,2}?a", "0aXXXXa0");
        n("(?:a+|\\Ab*)cc", "abcc");
        n("a(?i)b|c", "AC");
        n("a(?:(?i)b)|c", "aC");

        x3("(a)", "a", 0, 1, 1);
        x3("(ab)", "ab", 0, 2, 1);

        x3("((ab))", "ab", 0, 2, 1);
        x3("((ab))", "ab", 0, 2, 2);
        x3("((((((((((((((((((((ab))))))))))))))))))))", "ab", 0, 2, 20);
        x3("(ab)(cd)", "abcd", 0, 2, 1);
        x3("(ab)(cd)", "abcd", 2, 4, 2);
        x3("()(a)bc(def)ghijk", "abcdefghijk", 3, 6, 3);
        x3("(()(a)bc(def)ghijk)", "abcdefghijk", 3, 6, 4);

        x3("(a)|(a)", "ba", 1, 2, 1);
        x3("(^a)|(a)", "ba", 1, 2, 2);
        x3("(a?)", "aaa", 3, 3, 1);
        x3("(a*)", "aaa", 3, 3, 1);
        x3("(a*)", "", 0, 0, 1);
        x3("(a+)", "aaaaaaa", 6, 7, 1);
        x3("(a+|b*)", "bbbaa", 5, 5, 1);
        x3("(a+|b?)", "bbbaa", 5, 5, 1);
        x3("(abc)?", "abc", -1, -1, 1);
        x3("(abc)*", "abc", -1, -1, 1);
        x3("(abc)+", "abc", 0, 3, 1);
        x3("(xyz|abc)+", "abc", 0, 3, 1);
        x3("([xyz][abc]|abc)+", "abc", 0, 3, 1);
        x3("((?i:abc))", "AbC", 0, 3, 1);

        x3("((?m:a.c))", "a\nc", 0, 3, 1);
        x3("((?=az)a)", "azb", 0, 1, 1);
        x3("abc|(.abd)", "zabd", 0, 4, 1);

        x3("(?i:(abc))|(zzz)", "ABC", 0, 3, 1);
        x3("a*(.)", "aaaaz", 4, 5, 1);
        x3("a*?(.)", "aaaaz", 4, 5, 1);
        x3("a*?(c)", "aaaac", 4, 5, 1);
        x3("[bcd]a*(.)", "caaaaz", 5, 6, 1);
        x3("(\\Abb)cc", "bbcc", 0, 2, 1);
        n("(\\Abb)cc", "zbbcc");
        x3("(^bb)cc", "bbcc", 0, 2, 1);
        n("(^bb)cc", "zbbcc");
        x3("cc(bb$)", "ccbb", 2, 4, 1);
        n("cc(bb$)", "ccbbb");
        n("(\\1)", "");
        n("\\1(a)", "aa");
        n("(a(b)\\1)\\2+", "ababb");
        n("(?:(?:\\1|z)(a))+$", "zaa");
        n("(a)$|\\1", "az");

        n("(a)\\1", "ab");
        x3("(a*)\\1", "aaaaa", 5, 5, 1);
        x3("(((((((a*)b))))))c\\7", "aaabcaaa", 3, 3, 7);
        n("(\\w\\d\\s)\\1", "f5 f5");

        n("(^a)\\1", "baa");
        n("(a$)\\1", "aa");
        n("(ab\\Z)\\1", "ab");
        x3("(.(abc)\\2)", "zabcabc", 0, 7, 1);
        x3("(.(..\\d.)\\2)", "z12341234", 0, 9, 1);

        n("((?i:az))\\1", "Azaz");

        n("(?<=a)b", "bb");

        x3("(?<=(abc))d", "abcd", 0, 3, 1);
        n("(?<!a)b", "ab");

        n("(?<!a|bc)z", "bcz");
        x3("\\g<n>(?<n>.){0}", "X", 0, 1, 1);

        x3("(z)()()(?<_9>a)\\g<_9>", "zaa", 2, 3, 1);

        n("(?:(?<x>abc)|(?<x>efg))\\k<x>", "abcefg");

        // swiftlint:disable line_length
        x3("(?:(?<n1>.)|(?<n1>..)|(?<n1>...)|(?<n1>....)|(?<n1>.....)|(?<n1>......)|(?<n1>.......)|(?<n1>........)|(?<n1>.........)|(?<n1>..........)|(?<n1>...........)|(?<n1>............)|(?<n1>.............)|(?<n1>..............))\\k<n1>$", "xxxxabcdefghijklmnabcdefghijklmn", 4, 18, 14);
        x3("(?<name1>)(?<name2>)(?<name3>)(?<name4>)(?<name5>)(?<name6>)(?<name7>)(?<name8>)(?<name9>)(?<name10>)(?<name11>)(?<name12>)(?<name13>)(?<name14>)(?<name15>)(?<name16>aaa)(?<name17>)$", "aaa", 0, 3, 16);
        x3("(\\(((?:[^(]|\\g<1>)*)\\))", "(abc)(abc)", 6, 9, 2); // PR#43  n("\\A(a|b\\g<1>c)\\k<1+3>\\z", "bbaccb");  x2("(?:\\k'+1'B|(A)C)*", "ACAB", 4, 4); // relative backref by postitive number
        // swiftlint:enable line_length

        x3("(?<foo>a|\\(\\g<foo>\\))", "((((((((a))))))))", 8, 9, 1);
        x3("\\g<_A>\\g<_A>|\\zEND(.a.)(?<_A>.b.)", "xbxyby", 3, 6, 1);
        x3("(?:\\1a|())*", "a", 1, 1, 1);

        x2("[0-9-a]", "-", 0, 1);   // PR#44
        n("[0-9-a]", ":");          // PR#44
        x2("\\g<+2>(abc)(ABC){0}", "ABCabc", 0, 6); // relative call by positive number

        x3("(A\\g'0')|B", "AAAAB", -1, -1, 1);
        x3("(a*)(?(1)aa|a)b", "aaab", 1, 1, 1);
        n("(a)(?(1)a|b)c", "abc");

        n("(?()aaa|bbb)", "bbb");

        n("\\R\\n", "\r\n");  n("\\N", "\n");
        n("(?m:\\N)", "\n");
        n("(?-m:\\N)", "\n");
        x2("(abc|(def|ghi|jkl|mno|pqr){0,7}?){5}\\z", "adpqrpqrpqr", 11, 11); // cover OP_REPEAT_INC_NG_SG
        x2("(?!abc).*\\z", "abcde", 5, 5); // cover OP_PREC_READ_NOT_END
        x2("(.{2,})?", "abcde", 5, 5); // up coverage
        x2("((a|b|c|d|e|f|g|h|i|j|k|l|m|n)+)?", "abcde", 5, 5); // up coverage
        x2("((a|b|c|d|e|f|g|h|i|j|k|l|m|n){3,})?", "abcde", 5, 5); // up coverage
        x2("((?:a(?:b|c|d|e|f|g|h|i|j|k|l|m|n))+)?", "abacadae", 8, 8); // up coverage
        x2("((?:a(?:b|c|d|e|f|g|h|i|j|k|l|m|n))+?)?z", "abacadaez", 8, 9); // up coverage
        x2("\\A((a|b)??)?z", "bz", 0, 2); // up coverage
        x2("((?<x>abc){0}a\\g<x>d)+", "aabcd", 0, 5); // up coverage
        x2("((?(abc)true|false))+", "false", 0, 5); // up coverage
        x2("((?i:abc)d)+", "abcdABCd", 4, 8); // up coverage
        x2("((?<!abc)def)+", "bcdef", 2, 5); // up coverage
        x2("(\\ba)+", "aaa", 0, 1); // up coverage
        x2("()(?<x>ab)(?(<x>)a|b)", "aba", 0, 3); // up coverage
        x2("(?<=a.b)c", "azbc", 3, 4); // up coverage
        n("(?<=(?:abcde){30})z", "abc"); // up coverage
        x2("(?<=(?(a)a|bb))z", "aaz", 2, 3); // up coverage
        x2("[a]*\\W", "aa@", 2, 3); // up coverage
        x2("[a]*[b]", "aab", 2, 3); // up coverage
        n("a*\\W", "aaa"); // up coverage
        n("(?W)a*\\W", "aaa"); // up coverage
        x2("(?<=ab(?<=ab))", "ab", 2, 2); // up coverage
        x2("(?<x>a)(?<x>b)(\\k<x>)+", "abbaab", 0, 6); // up coverage
        x2("()(\\1)(\\2)", "abc", 3, 3); // up coverage
        x2("((?(a)b|c))(\\1)", "abab", 0, 4); // up coverage
        x2("(?<x>$|b\\g<x>)", "bbb", 3, 3); // up coverage
        x2("(?<x>(?(a)a|b)|c\\g<x>)", "cccb", 3, 4); // up coverage
        x2("(a)(?(1)a*|b*)+", "aaaa", 3, 4); // up coverage
        x2("[[^abc]&&cde]*", "de", 2, 2); // up coverage
        n("(a){10}{10}", "aa"); // up coverage
        x2("(?:a?)+", "aa", 2, 2); // up coverage
        x2("(?:a?)*?", "a", 1, 1); // up coverage
        x2("(?:a*)*?", "a", 1, 1); // up coverage
        x2("(?:a+?)*", "a", 1, 1); // up coverage
        x2("\\h", "5", 0, 1); // up coverage
        x2("\\H", "z", 0, 1); // up coverage
        x2("[\\h]", "5", 0, 1); // up coverage
        x2("[\\H]", "z", 0, 1); // up coverage
        x2("[\\o{101}]", "A", 0, 1); // up coverage
        x2("[\\u0041]", "A", 0, 1); // up coverage
        x2("a(?~(?~)).", "abcdefghijklmnopqrstuvwxyz", 0, 26); // !!!
        // absent with expr
        n("(?~|ab|\\O{2,10})", "ab");
        n("(?~|c|a*+)a", "aaaaa");  // absent range cutter
        n("(?~|a)a", "a");

        n("\\A(?~|abc).*(xyz|pqrabc)(?~|)abc", "aaaaxyzaaaabcpqrabcabc");
        n("い", "あ");
        n("\\W", "あ");
        n("[なに]", "ぬ");

        n("[^け]", "け");

        n("[\\d]", "ふ");

        n("[\\s]", "く");
        n("\\w鬼車", " 鬼車");  n(".い", "いえ");  n("\\Gぽぴ", "ぽぴ");
        n("\\Gえ", "うえお");

        n("まみ\\A", "まみ");
        n("ま\\Aみ", "まみ");

        n("(?=う).", "い");

        n("(?!と)あ", "と");  n("(?i:い)", "う");
        n("山+", "");  n("あ|い|うえ|おかき|く|けこさ|しすせ|そ|たち|つてとなに|ぬね", "すせ");
        n("(?>あ|あいえ)う", "あいえう");
        n("あ+|い+", "");  n("(?:あ+|\\Aい*)うう", "あいうう");
        n("(?i:あ)|a", "A");
        n("[^あいう]+", "あいう");  n("(?:鬼車){3,}", "鬼車鬼車");  x3("(火)", "火", 0, 3, 1);
        x3("(火水)", "火水", 0, 6, 1);

        x3("((風水))", "風水", 0, 6, 1);
        x3("((昨日))", "昨日", 0, 6, 2);
        x3("((((((((((((((((((((量子))))))))))))))))))))", "量子", 0, 6, 20);
        x3("(あい)(うえ)", "あいうえ", 0, 6, 1);
        x3("(あい)(うえ)", "あいうえ", 6, 12, 2);
        x3("()(あ)いう(えおか)きくけこ", "あいうえおかきくけこ", 9, 18, 3);
        x3("(()(あ)いう(えおか)きくけこ)", "あいうえおかきくけこ", 9, 18, 4);
        x3(".*(フォ)ン・マ(ン()シュタ)イン", "フォン・マンシュタイン", 15, 27, 2);

        x3("(あ)|(あ)", "いあ", 3, 6, 1);
        x3("(^あ)|(あ)", "いあ", 3, 6, 2);
        x3("(あ?)", "あああ", 9, 9, 1);
        x3("(ま*)", "ままま", 9, 9, 1);
        x3("(と*)", "", 0, 0, 1);
        x3("(る+)", "るるるるるるる", 18, 21, 1);
        x3("(ふ+|へ*)", "ふふふへへ", 15, 15, 1);
        x3("(あ+|い?)", "いいいああ", 15, 15, 1);
        x3("(あいう)?", "あいう", -1, -1, 1);
        x3("(あいう)*", "あいう", -1, -1, 1);
        x3("(あいう)+", "あいう", 0, 9, 1);
        x3("(さしす|あいう)+", "あいう", 0, 9, 1);
        x3("([なにぬ][かきく]|かきく)+", "かきく", 0, 9, 1);
        x3("((?i:あいう))", "あいう", 0, 9, 1);
        x3("((?m:あ.う))", "あ\nう", 0, 7, 1);
        x3("((?=あん)あ)", "あんい", 0, 3, 1);
        x3("あいう|(.あいえ)", "んあいえ", 0, 12, 1);
        x3("あ*(.)", "ああああん", 12, 15, 1);
        x3("あ*?(.)", "ああああん", 12, 15, 1);
        x3("あ*?(ん)", "ああああん", 12, 15, 1);
        x3("[いうえ]あ*(.)", "えああああん", 15, 18, 1);
        x3("(\\Aいい)うう", "いいうう", 0, 6, 1);
        n("(\\Aいい)うう", "んいいうう");
        x3("(^いい)うう", "いいうう", 0, 6, 1);
        n("(^いい)うう", "んいいうう");
        x3("ろろ(るる$)", "ろろるる", 6, 12, 1);
        n("ろろ(るる$)", "ろろるるる");

        n("(?<=abc)(?<!abc)def", "abcdef");
        n("(?<!ab.)(?<=.bc)def", "abcdef");

        n("(?<!abc)def", "abcdef");
        n("(?<!xxx|abc)def", "abcdef");
        n("(?<!xxxxx|abc)def", "abcdef");
        n("(?<!xxxxx|abc)def", "xxxxxxdef");
        n("(?<!x+|abc)def", "abcdef");
        n("(?<!x+|abc)def", "xxxxxxxxxdef");

        n("(?<!a.*z|a)def", "axxxxxxxzdef");
        n("(?<!a.*z|a)def", "bxxxxxxxadef");
        n(".(?<!3+|4+)\\d+", "33334444");
        n("(.{,3})..(?<!\\1)", "aaaaa");
        n("(?:(a.*b)|c.*d)(?<!(?(1))azzzb)", "azzzb");
        n("(?<!a.*c)def", "abbbcdef");

        n("(?<!a.*X\\B)def", "abbbbbXdef");

        n("(?<!a.*[uvw])def", "abbbbbwdef");
        n("(?<!ab*\\s+)def", "abbbbb   def");

        n("(?<!v|t|a+.*[efg])z", "abcdfz");

        n("(?<!v|t|^a+.*[efg])z", "abcdfz");
        // swiftlint:enable trailing_semicolon
    }

    func testOptions() {
        func x2(_ option: OnigOption, _ pattern: String, _ string: String, _ start: Int, _ end: Int) {
            let regex = try? OnigRegularExpression(pattern: pattern, options: option)
            XCTAssertNotNil(regex)

            let match = try? regex?.search(in: string)
            XCTAssertNotNil(match)
            XCTAssert(match!.isEmpty == false)
            XCTAssert(match![0] == (start, end))
        }

        func n(_ option: OnigOption, _ pattern: String, _ string: String) {
            let regex = try? OnigRegularExpression(pattern: pattern, options: option)
            XCTAssertNotNil(regex)

            let match = try? regex?.search(in: string)
            XCTAssertNotNil(match)
            XCTAssert(match!.isEmpty)
        }

        // swiftlint:disable trailing_semicolon
        // Hint: Copied from test_options.c
        x2(.ignoreCase, "a", "A", 0, 1);
        /* KELVIN SIGN */
        x2(.ignoreCase, "K", "k", 0, 1);
        x2(.ignoreCase, "k", "K", 0, 3);

        x2(.ignoreCase, "ss", "ß", 0, 2);
        x2(.ignoreCase, "ß", "SS", 0, 2);

        n(.notBeginOfLine, "^ab", "ab");
        n(.notBeginOfLine, "\\Aab", "ab");
        n(.notEndOfLine, "ab$", "ab");
        n(.notEndOfLine, "ab\\z", "ab");
        n(.notEndOfLine, "ab\\Z", "ab");
        n(.notEndOfLine, "ab\\Z", "ab\n");

        n(.notBeginOfString, "\\Aab", "ab");
        n(.notEndOfString, "ab\\z", "ab");
        n(.notEndOfString, "ab\\Z", "ab");
        n(.notEndOfString, "ab\\Z", "ab\n");

        x2(.asciiOnlyWord, "\\w", "@g", 1, 2);
        n(.asciiOnlyWord, "\\w", "あ");
        x2(.none, "\\d", "１", 0, 3);
        n(.asciiOnlyDigit, "\\d", "１");
        x2(.asciiOnlySpace, "\\s", " ", 0, 1);
        x2(.none, "\\s", "　", 0, 3);
        n(.asciiOnlySpace, "\\s", "　");

        x2(.asciiOnlyPOSIX, "\\w\\d\\s", "c3 ", 0, 3);
        n(.asciiOnlyPOSIX, "\\w|\\d|\\s", "あ４　");

        x2(.extendedPattern, " abc  \n def", "abcdef", 0, 6);
        x2(.findLongest, "\\w+", "abc defg hij", 4, 8);
        x2(.ignoreEmpty, "\\w*", "@@@ abc defg hij", 4, 7);
        // swiftlint:enable trailing_semicolon
    }

    func testUtf8() {
        func x2(_ pattern: String, _ string: String, _ matchStart: Int, _ matchEnd: Int) {
            let regex = try? OnigRegularExpression(pattern: pattern)
            XCTAssertNotNil(regex)

            let match = try? regex?.search(in: string)
            XCTAssertNotNil(match)
            XCTAssert(match!.isEmpty == false)
            XCTAssert(match![0] == (matchStart, matchEnd))
        }

        func n(_ pattern: String, _ string: String) {
            let regex = try? OnigRegularExpression(pattern: pattern)
            XCTAssertNotNil(regex)

            let match = try? regex?.search(in: string)
            XCTAssert(match!.isEmpty)
        }

        func x3(_ pattern: String, _ string: String, _ matchStart: Int, _ matchEnd: Int, _ matchIndex: Int) {
            let regex = try? OnigRegularExpression(pattern: pattern)
            XCTAssertNotNil(regex)

            let matches = try? regex?.search(in: string)
            XCTAssertNotNil(matches)
            XCTAssert(matches!.isEmpty == false)
            XCTAssert(matches![matchIndex] == (matchStart, matchEnd))
        }

        // swiftlint:disable trailing_semicolon
        // Hint: Copied from test_utf8.c
        x2("", "", 0, 0);
        x2("^", "", 0, 0);
        x2("^a", "\na", 1, 2);
        x2("$", "", 0, 0);
        x2("$\\O", "bb\n", 2, 3);
        x2("\\G", "", 0, 0);
        x2("\\A", "", 0, 0);
        x2("\\Z", "", 0, 0);
        x2("\\z", "", 0, 0);
        x2("^$", "", 0, 0);
        x2("\\ca", "\u{1}", 0, 1);
        x2("\\C-b", "\u{2}", 0, 1);
        x2("\\c\\\\", "\u{1c}", 0, 1);
        x2("q[\\c\\\\]", "q\u{1c}", 0, 2);
        x2("", "a", 0, 0);
        x2("a", "a", 0, 1);
        x2("\\x61", "a", 0, 1);
        x2("aa", "aa", 0, 2);
        x2("aaa", "aaa", 0, 3);
        x2("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, 35);
        x2("ab", "ab", 0, 2);
        x2("b", "ab", 1, 2);
        x2("bc", "abc", 1, 3);
        x2("(?i:#RET#)", "#INS##RET#", 5, 10);
        x2("\\17", "\u{f}", 0, 1);
        x2("\\x1f", "\u{1f}", 0, 1);
        x2("a(?#....\\\\JJJJ)b", "ab", 0, 2);
        x2("(?x)  G (o O(?-x)oO) g L", "GoOoOgLe", 0, 7);
        x2(".", "a", 0, 1);
        n(".", "");
        x2("..", "ab", 0, 2);
        x2("\\w", "e", 0, 1);
        n("\\W", "e");
        x2("\\s", " ", 0, 1);
        x2("\\S", "b", 0, 1);
        x2("\\d", "4", 0, 1);
        n("\\D", "4");
        x2("\\b", "z ", 0, 0);
        x2("\\b", " z", 1, 1);
        x2("\\b", "  z ", 2, 2);
        x2("\\B", "zz ", 1, 1);
        x2("\\B", "z ", 2, 2);
        x2("\\B", " z", 0, 0);
        x2("[ab]", "b", 0, 1);
        n("[ab]", "c");
        x2("[a-z]", "t", 0, 1);
        n("[^a]", "a");
        x2("[^a]", "\n", 0, 1);
        x2("[]]", "]", 0, 1);
        n("[^]]", "]");
        x2("[\\^]+", "0^^1", 1, 3);
        x2("[b-]", "b", 0, 1);
        x2("[b-]", "-", 0, 1);
        x2("[\\w]", "z", 0, 1);
        n("[\\w]", " ");
        x2("[\\W]", "b$", 1, 2);
        x2("[\\d]", "5", 0, 1);
        n("[\\d]", "e");
        x2("[\\D]", "t", 0, 1);
        n("[\\D]", "3");
        x2("[\\s]", " ", 0, 1);
        n("[\\s]", "a");
        x2("[\\S]", "b", 0, 1);
        n("[\\S]", " ");
        x2("[\\w\\d]", "2", 0, 1);
        n("[\\w\\d]", " ");
        x2("[[:upper:]]", "B", 0, 1);
        x2("[*[:xdigit:]+]", "+", 0, 1);
        x2("[*[:xdigit:]+]", "GHIKK-9+*", 6, 7);
        x2("[*[:xdigit:]+]", "-@^+", 3, 4);
        n("[[:upper]]", "A");
        x2("[[:upper]]", ":", 0, 1);
        x2("[\\044-\\047]", "\u{26}", 0, 1);
        x2("[\\x5a-\\x5c]", "\u{5b}", 0, 1);
        x2("[\\x6A-\\x6D]", "\u{6c}", 0, 1);
        n("[\\x6A-\\x6D]", "\u{6E}");
        n("^[0-9A-F]+ 0+ UNDEF ", "75F 00000000 SECT14A notype ()    External    | _rb_apply");
        x2("[\\[]", "[", 0, 1);
        x2("[\\]]", "]", 0, 1);
        x2("[&]", "&", 0, 1);
        x2("[[ab]]", "b", 0, 1);
        x2("[[ab]c]", "c", 0, 1);
        n("[[^a]]", "a");
        n("[^[a]]", "a");
        x2("[[ab]&&bc]", "b", 0, 1);
        n("[[ab]&&bc]", "a");
        n("[[ab]&&bc]", "c");
        x2("[a-z&&b-y&&c-x]", "w", 0, 1);
        n("[^a-z&&b-y&&c-x]", "w");
        x2("[[^a&&a]&&a-z]", "b", 0, 1);
        n("[[^a&&a]&&a-z]", "a");
        x2("[[^a-z&&bcdef]&&[^c-g]]", "h", 0, 1);
        n("[[^a-z&&bcdef]&&[^c-g]]", "c");
        x2("[^[^abc]&&[^cde]]", "c", 0, 1);
        x2("[^[^abc]&&[^cde]]", "e", 0, 1);
        n("[^[^abc]&&[^cde]]", "f");
        x2("[a-&&-a]", "-", 0, 1);
        n("[a\\-&&\\-a]", "&");
        n("\\wabc", " abc");
        x2("a\\Wbc", "a bc", 0, 4);
        x2("a.b.c", "aabbc", 0, 5);
        x2(".\\wb\\W..c", "abb bcc", 0, 7);
        x2("\\s\\wzzz", " zzzz", 0, 5);
        x2("aa.b", "aabb", 0, 4);
        n(".a", "ab");
        x2(".a", "aa", 0, 2);
        x2("^a", "a", 0, 1);
        x2("^a$", "a", 0, 1);
        x2("^\\w$", "a", 0, 1);
        n("^\\w$", " ");
        x2("^\\wab$", "zab", 0, 3);
        x2("^\\wabcdef$", "zabcdef", 0, 7);
        x2("^\\w...def$", "zabcdef", 0, 7);
        x2("\\w\\w\\s\\Waaa\\d", "aa  aaa4", 0, 8);
        x2("\\A\\Z", "", 0, 0);
        x2("\\Axyz", "xyz", 0, 3);
        x2("xyz\\Z", "xyz", 0, 3);
        x2("xyz\\z", "xyz", 0, 3);
        x2("a\\Z", "a", 0, 1);
        x2("\\Gaz", "az", 0, 2);
        n("\\Gz", "bza");
        n("az\\G", "az");
        n("az\\A", "az");
        n("a\\Az", "az");
        x2("\\^\\$", "^$", 0, 2);
        x2("^x?y", "xy", 0, 2);
        x2("^(x?y)", "xy", 0, 2);
        x2("\\w", "_", 0, 1);
        n("\\W", "_");
        x2("(?=z)z", "z", 0, 1);
        n("(?=z).", "a");
        x2("(?!z)a", "a", 0, 1);
        n("(?!z)a", "z");
        x2("(?i:a)", "a", 0, 1);
        x2("(?i:a)", "A", 0, 1);
        x2("(?i:A)", "a", 0, 1);
        x2("(?i:i)", "I", 0, 1);
        x2("(?i:I)", "i", 0, 1);
        x2("(?i:[A-Z])", "i", 0, 1);
        x2("(?i:[a-z])", "I", 0, 1);
        n("(?i:A)", "b");
        x2("(?i:ss)", "ss", 0, 2);
        x2("(?i:ss)", "Ss", 0, 2);
        x2("(?i:ss)", "SS", 0, 2);
        /* 0xc5,0xbf == 017F: # LATIN SMALL LETTER LONG S */
        x2("(?i:ss)", "ſS", 0, 3);
        x2("(?i:ss)", "sſ", 0, 3);
        /* 0xc3,0x9f == 00DF: # LATIN SMALL LETTER SHARP S */
        x2("(?i:ss)", "ß", 0, 2);
        /* 0xe1,0xba,0x9e == 1E9E # LATIN CAPITAL LETTER SHARP S */
        x2("(?i:ss)", "ẞ", 0, 3);
        x2("(?i:xssy)", "xssy", 0, 4);
        x2("(?i:xssy)", "xSsy", 0, 4);
        x2("(?i:xssy)", "xSSy", 0, 4);
        x2("(?i:xssy)", "xſSy", 0, 5);
        x2("(?i:xssy)", "xsſy", 0, 5);
        x2("(?i:xssy)", "xßy", 0, 4);
        x2("(?i:xssy)", "xẞy", 0, 5);
        x2("(?i:xßy)", "xssy", 0, 4);
        x2("(?i:xßy)", "xSSy", 0, 4);
        x2("(?i:ß)", "ss", 0, 2);
        x2("(?i:ß)", "SS", 0, 2);
        x2("(?i:[ß])", "ss", 0, 2);
        x2("(?i:[ß])", "SS", 0, 2);
        x2("(?i)(?<!ss)z", "qqz", 2, 3);
        x2("(?i:[A-Z])", "a", 0, 1);
        x2("(?i:[f-m])", "H", 0, 1);
        x2("(?i:[f-m])", "h", 0, 1);
        n("(?i:[f-m])", "e");
        x2("(?i:[A-c])", "D", 0, 1);
        n("(?i:[^a-z])", "A");
        n("(?i:[^a-z])", "a");
        x2("(?i:[!-k])", "Z", 0, 1);
        x2("(?i:[!-k])", "7", 0, 1);
        x2("(?i:[T-}])", "b", 0, 1);
        x2("(?i:[T-}])", "{", 0, 1);
        x2("(?i:\\?a)", "?A", 0, 2);
        x2("(?i:\\*A)", "*a", 0, 2);
        n(".", "\n");
        x2("(?m:.)", "\n", 0, 1);
        x2("(?m:a.)", "a\n", 0, 2);
        x2("(?m:.b)", "a\nb", 1, 3);
        x2(".*abc", "dddabdd\nddabc", 8, 13);
        x2(".+abc", "dddabdd\nddabcaa\naaaabc", 8, 13);
        x2("(?m:.*abc)", "dddabddabc", 0, 10);
        n("(?i)(?-i)a", "A");
        n("(?i)(?-i:a)", "A");
        x2("a?", "", 0, 0);
        x2("a?", "b", 0, 0);
        x2("a?", "a", 0, 1);
        x2("a*", "", 0, 0);
        x2("a*", "a", 0, 1);
        x2("a*", "aaa", 0, 3);
        x2("a*", "baaaa", 0, 0);
        n("a+", "");
        x2("a+", "a", 0, 1);
        x2("a+", "aaaa", 0, 4);
        x2("a+", "aabbb", 0, 2);
        x2("a+", "baaaa", 1, 5);
        x2(".?", "", 0, 0);
        x2(".?", "f", 0, 1);
        x2(".?", "\n", 0, 0);
        x2(".*", "", 0, 0);
        x2(".*", "abcde", 0, 5);
        x2(".+", "z", 0, 1);
        x2(".+", "zdswer\n", 0, 6);
        x2("(.*)a\\1f", "babfbac", 0, 4);
        x2("(.*)a\\1f", "bacbabf", 3, 7);
        x2("((.*)a\\2f)", "bacbabf", 3, 7);
        x2("(.*)a\\1f", "baczzzzzz\nbazz\nzzzzbabf", 19, 23);
        x2("a|b", "a", 0, 1);
        x2("a|b", "b", 0, 1);
        x2("|a", "a", 0, 0);
        x2("(|a)", "a", 0, 0);
        x2("ab|bc", "ab", 0, 2);
        x2("ab|bc", "bc", 0, 2);
        x2("z(?:ab|bc)", "zbc", 0, 3);
        x2("a(?:ab|bc)c", "aabc", 0, 4);
        x2("ab|(?:ac|az)", "az", 0, 2);
        x2("a|b|c", "dc", 1, 2);
        x2("a|b|cd|efg|h|ijk|lmn|o|pq|rstuvwx|yz", "pqr", 0, 2);
        n("a|b|cd|efg|h|ijk|lmn|o|pq|rstuvwx|yz", "mn");
        x2("a|^z", "ba", 1, 2);
        x2("a|^z", "za", 0, 1);
        x2("a|\\Gz", "bza", 2, 3);
        x2("a|\\Gz", "za", 0, 1);
        x2("a|\\Az", "bza", 2, 3);
        x2("a|\\Az", "za", 0, 1);
        x2("a|b\\Z", "ba", 1, 2);
        x2("a|b\\Z", "b", 0, 1);
        x2("a|b\\z", "ba", 1, 2);
        x2("a|b\\z", "b", 0, 1);
        x2("\\w|\\s", " ", 0, 1);
        n("\\w|\\w", " ");
        x2("\\w|%", "%", 0, 1);
        x2("\\w|[&$]", "&", 0, 1);
        x2("[b-d]|[^e-z]", "a", 0, 1);
        x2("(?:a|[c-f])|bz", "dz", 0, 1);
        x2("(?:a|[c-f])|bz", "bz", 0, 2);
        x2("abc|(?=zz)..f", "zzf", 0, 3);
        x2("abc|(?!zz)..f", "abf", 0, 3);
        x2("(?=za)..a|(?=zz)..a", "zza", 0, 3);
        n("(?>a|abd)c", "abdc");
        x2("(?>abd|a)c", "abdc", 0, 4);
        x2("a?|b", "a", 0, 1);
        x2("a?|b", "b", 0, 0);
        x2("a?|b", "", 0, 0);
        x2("a*|b", "aa", 0, 2);
        x2("a*|b*", "ba", 0, 0);
        x2("a*|b*", "ab", 0, 1);
        x2("a+|b*", "", 0, 0);
        x2("a+|b*", "bbb", 0, 3);
        x2("a+|b*", "abbb", 0, 1);
        n("a+|b+", "");
        x2("(a|b)?", "b", 0, 1);
        x2("(a|b)*", "ba", 0, 2);
        x2("(a|b)+", "bab", 0, 3);
        x2("(ab|ca)+", "caabbc", 0, 4);
        x2("(ab|ca)+", "aabca", 1, 5);
        x2("(ab|ca)+", "abzca", 0, 2);
        x2("(a|bab)+", "ababa", 0, 5);
        x2("(a|bab)+", "ba", 1, 2);
        x2("(a|bab)+", "baaaba", 1, 4);
        x2("(?:a|b)(?:a|b)", "ab", 0, 2);
        x2("(?:a*|b*)(?:a*|b*)", "aaabbb", 0, 3);
        x2("(?:a*|b*)(?:a+|b+)", "aaabbb", 0, 6);
        x2("(?:a+|b+){2}", "aaabbb", 0, 6);
        x2("h{0,}", "hhhh", 0, 4);
        x2("(?:a+|b+){1,2}", "aaabbb", 0, 6);
        n("ax{2}*a", "0axxxa1");
        n("a.{0,2}a", "0aXXXa0");
        n("a.{0,2}?a", "0aXXXa0");
        n("a.{0,2}?a", "0aXXXXa0");
        x2("^a{2,}?a$", "aaa", 0, 3);
        x2("^[a-z]{2,}?$", "aaa", 0, 3);
        x2("(?:a+|\\Ab*)cc", "cc", 0, 2);
        n("(?:a+|\\Ab*)cc", "abcc");
        x2("(?:^a+|b+)*c", "aabbbabc", 6, 8);
        x2("(?:^a+|b+)*c", "aabbbbc", 0, 7);
        x2("a|(?i)c", "C", 0, 1);
        x2("(?i)c|a", "C", 0, 1);
        x2("(?i)c|a", "A", 0, 1);
        x2("a(?i)b|c", "aB", 0, 2);
        x2("a(?i)b|c", "aC", 0, 2);
        n("a(?i)b|c", "AC");
        n("a(?:(?i)b)|c", "aC");
        x2("(?i:c)|a", "C", 0, 1);
        n("(?i:c)|a", "A");
        x2("[abc]?", "abc", 0, 1);
        x2("[abc]*", "abc", 0, 3);
        x2("[^abc]*", "abc", 0, 0);
        n("[^abc]+", "abc");
        x2("a??", "aaa", 0, 0);
        x2("ba??b", "bab", 0, 3);
        x2("a*?", "aaa", 0, 0);
        x2("ba*?", "baa", 0, 1);
        x2("ba*?b", "baab", 0, 4);
        x2("a+?", "aaa", 0, 1);
        x2("ba+?", "baa", 0, 2);
        x2("ba+?b", "baab", 0, 4);
        x2("(?:a?)??", "a", 0, 0);
        x2("(?:a??)?", "a", 0, 0);
        x2("(?:a?)+?", "aaa", 0, 1);
        x2("(?:a+)??", "aaa", 0, 0);
        x2("(?:a+)??b", "aaab", 0, 4);
        x2("(?:ab)?{2}", "", 0, 0);
        x2("(?:ab)?{2}", "ababa", 0, 4);
        x2("(?:ab)*{0}", "ababa", 0, 0);
        x2("(?:ab){3,}", "abababab", 0, 8);
        n("(?:ab){3,}", "abab");
        x2("(?:ab){2,4}", "ababab", 0, 6);
        x2("(?:ab){2,4}", "ababababab", 0, 8);
        x2("(?:ab){2,4}?", "ababababab", 0, 4);
        x2("(?:ab){,}", "ab{,}", 0, 5);
        x2("(?:abc)+?{2}", "abcabcabc", 0, 6);
        x2("(?:X*)(?i:xa)", "XXXa", 0, 4);
        x2("(d+)([^abc]z)", "dddz", 0, 4);
        x2("([^abc]*)([^abc]z)", "dddz", 0, 4);
        x2("(\\w+)(\\wz)", "dddz", 0, 4);
        x3("(a)", "a", 0, 1, 1);
        x3("(ab)", "ab", 0, 2, 1);
        x2("((ab))", "ab", 0, 2);
        x3("((ab))", "ab", 0, 2, 1);
        x3("((ab))", "ab", 0, 2, 2);
        x3("((((((((((((((((((((ab))))))))))))))))))))", "ab", 0, 2, 20);
        x3("(ab)(cd)", "abcd", 0, 2, 1);
        x3("(ab)(cd)", "abcd", 2, 4, 2);
        x3("()(a)bc(def)ghijk", "abcdefghijk", 3, 6, 3);
        x3("(()(a)bc(def)ghijk)", "abcdefghijk", 3, 6, 4);
        x2("(^a)", "a", 0, 1);
        x3("(a)|(a)", "ba", 1, 2, 1);
        x3("(^a)|(a)", "ba", 1, 2, 2);
        x3("(a?)", "aaa", 0, 1, 1);
        x3("(a*)", "aaa", 0, 3, 1);
        x3("(a*)", "", 0, 0, 1);
        x3("(a+)", "aaaaaaa", 0, 7, 1);
        x3("(a+|b*)", "bbbaa", 0, 3, 1);
        x3("(a+|b?)", "bbbaa", 0, 1, 1);
        x3("(abc)?", "abc", 0, 3, 1);
        x3("(abc)*", "abc", 0, 3, 1);
        x3("(abc)+", "abc", 0, 3, 1);
        x3("(xyz|abc)+", "abc", 0, 3, 1);
        x3("([xyz][abc]|abc)+", "abc", 0, 3, 1);
        x3("((?i:abc))", "AbC", 0, 3, 1);
        x2("(abc)(?i:\\1)", "abcABC", 0, 6);
        x3("((?m:a.c))", "a\nc", 0, 3, 1);
        x3("((?=az)a)", "azb", 0, 1, 1);
        x3("abc|(.abd)", "zabd", 0, 4, 1);
        x2("(?:abc)|(ABC)", "abc", 0, 3);
        x3("(?i:(abc))|(zzz)", "ABC", 0, 3, 1);
        x3("a*(.)", "aaaaz", 4, 5, 1);
        x3("a*?(.)", "aaaaz", 0, 1, 1);
        x3("a*?(c)", "aaaac", 4, 5, 1);
        x3("[bcd]a*(.)", "caaaaz", 5, 6, 1);
        x3("(\\Abb)cc", "bbcc", 0, 2, 1);
        n("(\\Abb)cc", "zbbcc");
        x3("(^bb)cc", "bbcc", 0, 2, 1);
        n("(^bb)cc", "zbbcc");
        x3("cc(bb$)", "ccbb", 2, 4, 1);
        n("cc(bb$)", "ccbbb");
        n("(\\1)", "");
        n("\\1(a)", "aa");
        n("(a(b)\\1)\\2+", "ababb");
        n("(?:(?:\\1|z)(a))+$", "zaa");
        x2("(?:(?:\\1|z)(a))+$", "zaaa", 0, 4);
        x2("(a)(?=\\1)", "aa", 0, 1);
        n("(a)$|\\1", "az");
        x2("(a)\\1", "aa", 0, 2);
        n("(a)\\1", "ab");
        x2("(a?)\\1", "aa", 0, 2);
        x2("(a??)\\1", "aa", 0, 0);
        x2("(a*)\\1", "aaaaa", 0, 4);
        x3("(a*)\\1", "aaaaa", 0, 2, 1);
        x2("a(b*)\\1", "abbbb", 0, 5);
        x2("a(b*)\\1", "ab", 0, 1);
        x2("(a*)(b*)\\1\\2", "aaabbaaabb", 0, 10);
        x2("(a*)(b*)\\2", "aaabbbb", 0, 7);
        x2("(((((((a*)b))))))c\\7", "aaabcaaa", 0, 8);
        x3("(((((((a*)b))))))c\\7", "aaabcaaa", 0, 3, 7);
        x2("(a)(b)(c)\\2\\1\\3", "abcbac", 0, 6);
        x2("([a-d])\\1", "cc", 0, 2);
        x2("(\\w\\d\\s)\\1", "f5 f5 ", 0, 6);
        n("(\\w\\d\\s)\\1", "f5 f5");
        x2("(who|[a-c]{3})\\1", "whowho", 0, 6);
        x2("...(who|[a-c]{3})\\1", "abcwhowho", 0, 9);
        x2("(who|[a-c]{3})\\1", "cbccbc", 0, 6);
        x2("(^a)\\1", "aa", 0, 2);
        n("(^a)\\1", "baa");
        n("(a$)\\1", "aa");
        n("(ab\\Z)\\1", "ab");
        x2("(a*\\Z)\\1", "a", 1, 1);
        x2(".(a*\\Z)\\1", "ba", 1, 2);
        x3("(.(abc)\\2)", "zabcabc", 0, 7, 1);
        x3("(.(..\\d.)\\2)", "z12341234", 0, 9, 1);
        x2("((?i:az))\\1", "AzAz", 0, 4);
        n("((?i:az))\\1", "Azaz");
        x2("(?<=a)b", "ab", 1, 2);
        n("(?<=a)b", "bb");
        x2("(?<=a|b)b", "bb", 1, 2);
        x2("(?<=a|bc)b", "bcb", 2, 3);
        x2("(?<=a|bc)b", "ab", 1, 2);
        x2("(?<=a|bc||defghij|klmnopq|r)z", "rz", 1, 2);
        x3("(?<=(abc))d", "abcd", 0, 3, 1);
        x2("(?<=(?i:abc))d", "ABCd", 3, 4);
        x2("(?<=^|b)c", " cbc", 3, 4);
        x2("(?<=a|^|b)c", " cbc", 3, 4);
        x2("(?<=a|(^)|b)c", " cbc", 3, 4);
        x2("(?<=a|(^)|b)c", "cbc", 0, 1);
        n("(Q)|(?<=a|(?(1))|b)c", "czc");
        x2("(Q)(?<=a|(?(1))|b)c", "cQc", 1, 3);
        x2("(?<=a|(?~END)|b)c", "ENDc", 3, 4);
        n("(?<!^|b)c", "cbc");
        n("(?<!a|^|b)c", "cbc");
        n("(?<!a|(?:^)|b)c", "cbc");
        x2("(?<!a|(?:^)|b)c", " cbc", 1, 2);
        x2("(a)\\g<1>", "aa", 0, 2);
        x2("(?<!a)b", "cb", 1, 2);
        n("(?<!a)b", "ab");
        x2("(?<!a|bc)b", "bbb", 0, 1);
        n("(?<!a|bc)z", "bcz");
        x2("(?<name1>a)", "a", 0, 1);
        x2("(?<name_2>ab)\\g<name_2>", "abab", 0, 4);
        x2("(?<name_3>.zv.)\\k<name_3>", "azvbazvb", 0, 8);
        x2("(?<=\\g<ab>)|-\\zEND (?<ab>XyZ)", "XyZ", 3, 3);
        x2("(?<n>|a\\g<n>)+", "", 0, 0);
        x2("(?<n>|\\(\\g<n>\\))+$", "()(())", 0, 6);
        x3("\\g<n>(?<n>.){0}", "X", 0, 1, 1);
        x2("\\g<n>(abc|df(?<n>.YZ){2,8}){0}", "XYZ", 0, 3);
        x2("\\A(?<n>(a\\g<n>)|)\\z", "aaaa", 0, 4);
        x2("(?<n>|\\g<m>\\g<n>)\\z|\\zEND (?<m>a|(b)\\g<m>)", "bbbbabba", 0, 8);
        x2("(?<name1240>\\w+\\sx)a+\\k<name1240>", "  fg xaaaaaaaafg x", 2, 18);
        x3("(z)()()(?<_9>a)\\g<_9>", "zaa", 2, 3, 1);
        x2("(.)(((?<_>a)))\\k<_>", "zaa", 0, 3);
        x2("((?<name1>\\d)|(?<name2>\\w))(\\k<name1>|\\k<name2>)", "ff", 0, 2);
        x2("(?:(?<x>)|(?<x>efg))\\k<x>", "", 0, 0);
        x2("(?:(?<x>abc)|(?<x>efg))\\k<x>", "abcefgefg", 3, 9);
        n("(?:(?<x>abc)|(?<x>efg))\\k<x>", "abcefg");

        // swiftlint:disable line_length
        x2("(?:(?<n1>.)|(?<n1>..)|(?<n1>...)|(?<n1>....)|(?<n1>.....)|(?<n1>......)|(?<n1>.......)|(?<n1>........)|(?<n1>.........)|(?<n1>..........)|(?<n1>...........)|(?<n1>............)|(?<n1>.............)|(?<n1>..............))\\k<n1>$", "a-pyumpyum", 2, 10);
        x3("(?:(?<n1>.)|(?<n1>..)|(?<n1>...)|(?<n1>....)|(?<n1>.....)|(?<n1>......)|(?<n1>.......)|(?<n1>........)|(?<n1>.........)|(?<n1>..........)|(?<n1>...........)|(?<n1>............)|(?<n1>.............)|(?<n1>..............))\\k<n1>$", "xxxxabcdefghijklmnabcdefghijklmn", 4, 18, 14);
        x3("(?<name1>)(?<name2>)(?<name3>)(?<name4>)(?<name5>)(?<name6>)(?<name7>)(?<name8>)(?<name9>)(?<name10>)(?<name11>)(?<name12>)(?<name13>)(?<name14>)(?<name15>)(?<name16>aaa)(?<name17>)$", "aaa", 0, 3, 16);
        // swiftlint:enable line_length

        x2("(?<foo>a|\\(\\g<foo>\\))", "a", 0, 1);
        x2("(?<foo>a|\\(\\g<foo>\\))", "((((((a))))))", 0, 13);
        x3("(?<foo>a|\\(\\g<foo>\\))", "((((((((a))))))))", 0, 17, 1);
        x2("\\g<bar>|\\zEND(?<bar>.*abc$)", "abcxxxabc", 0, 9);
        x2("\\g<1>|\\zEND(.a.)", "bac", 0, 3);
        x3("\\g<_A>\\g<_A>|\\zEND(.a.)(?<_A>.b.)", "xbxyby", 3, 6, 1);
        x2("\\A(?:\\g<pon>|\\g<pan>|\\zEND  (?<pan>a|c\\g<pon>c)(?<pon>b|d\\g<pan>d))$", "cdcbcdc", 0, 7);
        x2("\\A(?<n>|a\\g<m>)\\z|\\zEND (?<m>\\g<n>)", "aaaa", 0, 4);
        x2("(?<n>(a|b\\g<n>c){3,5})", "baaaaca", 1, 5);
        x2("(?<n>(a|b\\g<n>c){3,5})", "baaaacaaaaa", 0, 10);
        x2("(?<pare>\\(([^\\(\\)]++|\\g<pare>)*+\\))", "((a))", 0, 5);
        x2("()*\\1", "", 0, 0);
        x2("(?:()|())*\\1\\2", "", 0, 0);
        x2("(?:a*|b*)*c", "abadc", 4, 5);
        x3("(?:\\1a|())*", "a", 0, 0, 1);
        x2("x((.)*)*x", "0x1x2x3", 1, 6);
        x2("x((.)*)*x(?i:\\1)\\Z", "0x1x2x1X2", 1, 9);
        x2("(?:()|()|()|()|()|())*\\2\\5", "", 0, 0);
        x2("(?:()|()|()|(x)|()|())*\\2b\\5", "b", 0, 1);
        x2("[0-9-a]", "-", 0, 1);   // PR#44
        n("[0-9-a]", ":");          // PR#44
        x3("(\\(((?:[^(]|\\g<1>)*)\\))", "(abc)(abc)", 1, 4, 2); // PR#43
        x2("\\o{101}", "A", 0, 1);
        x2("\\A(a|b\\g<1>c)\\k<1+3>\\z", "bbacca", 0, 6);
        n("\\A(a|b\\g<1>c)\\k<1+3>\\z", "bbaccb");
        x2("(?i)\\A(a|b\\g<1>c)\\k<1+2>\\z", "bBACcbac", 0, 8);
        x2("(?i)(?<X>aa)|(?<X>bb)\\k<X>", "BBbb", 0, 4);
        x2("(?:\\k'+1'B|(A)C)*", "ACAB", 0, 4); // relative backref by postitive number
        x2("\\g<+2>(abc)(ABC){0}", "ABCabc", 0, 6); // relative call by positive number
        x2("A\\g'0'|B()", "AAAAB", 0, 5);
        x3("(A\\g'0')|B", "AAAAB", 0, 5, 1);
        x2("(a*)(?(1))aa", "aaaaa", 0, 5);
        x2("(a*)(?(-1))aa", "aaaaa", 0, 5);
        x2("(?<name>aaa)(?('name'))aa", "aaaaa", 0, 5);
        x2("(a)(?(1)aa|bb)a", "aaaaa", 0, 4);
        x2("(?:aa|())(?(<1>)aa|bb)a", "aabba", 0, 5);
        x2("(?:aa|())(?('1')aa|bb|cc)a", "aacca", 0, 5);
        x3("(a*)(?(1)aa|a)b", "aaab", 0, 1, 1);
        n("(a)(?(1)a|b)c", "abc");
        x2("(a)(?(1)|)c", "ac", 0, 2);
        n("(?()aaa|bbb)", "bbb");
        x2("(a)(?(1+0)b|c)d", "abd", 0, 3);
        x2("(?:(?'name'a)|(?'name'b))(?('name')c|d)e", "ace", 0, 3);
        x2("(?:(?'name'a)|(?'name'b))(?('name')c|d)e", "bce", 0, 3);
        x2("\\R", "\r\n", 0, 2);
        x2("\\R", "\r", 0, 1);
        x2("\\R", "\n", 0, 1);
        x2("\\R", "\u{0b}", 0, 1);
        n("\\R\\n", "\r\n");
        x2("\\R", "\u{0085}", 0, 2);
        x2("\\N", "a", 0, 1);
        n("\\N", "\n");
        n("(?m:\\N)", "\n");
        n("(?-m:\\N)", "\n");
        x2("\\O", "a", 0, 1);
        x2("\\O", "\n", 0, 1);
        x2("(?m:\\O)", "\n", 0, 1);
        x2("(?-m:\\O)", "\n", 0, 1);
        x2("\\K", "a", 0, 0);
        x2("a\\K", "a", 1, 1);
        x2("a\\Kb", "ab", 1, 2);
        x2("(a\\Kb|ac\\Kd)", "acd", 2, 3);
        x2("(a\\Kb|\\Kac\\K)*", "acababacab", 9, 10);
        x2("(?:()|())*\\1", "abc", 0, 0);
        x2("(?:()|())*\\2", "abc", 0, 0);
        x2("(?:()|()|())*\\3\\1", "abc", 0, 0);
        x2("(|(?:a(?:\\g'1')*))b|", "abc", 0, 2);
        x2("^(\"|)(.*)\\1$", "XX", 0, 2);
        x2("(abc|def|ghi|jkl|mno|pqr|stu){0,10}?\\z", "admno", 2, 5);
        x2("(abc|(def|ghi|jkl|mno|pqr){0,7}?){5}\\z", "adpqrpqrpqr", 2, 11); // cover OP_REPEAT_INC_NG_SG
        x2("(?!abc).*\\z", "abcde", 1, 5); // cover OP_PREC_READ_NOT_END
        x2("(.{2,})?", "abcde", 0, 5); // up coverage
        x2("((a|b|c|d|e|f|g|h|i|j|k|l|m|n)+)?", "abcde", 0, 5); // up coverage
        x2("((a|b|c|d|e|f|g|h|i|j|k|l|m|n){3,})?", "abcde", 0, 5); // up coverage
        x2("((?:a(?:b|c|d|e|f|g|h|i|j|k|l|m|n))+)?", "abacadae", 0, 8); // up coverage
        x2("((?:a(?:b|c|d|e|f|g|h|i|j|k|l|m|n))+?)?z", "abacadaez", 0, 9); // up coverage
        x2("\\A((a|b)??)?z", "bz", 0, 2); // up coverage
        x2("((?<x>abc){0}a\\g<x>d)+", "aabcd", 0, 5); // up coverage
        x2("((?(abc)true|false))+", "false", 0, 5); // up coverage
        x2("((?i:abc)d)+", "abcdABCd", 0, 8); // up coverage
        x2("((?<!abc)def)+", "bcdef", 2, 5); // up coverage
        x2("(\\ba)+", "aaa", 0, 1); // up coverage
        x2("()(?<x>ab)(?(<x>)a|b)", "aba", 0, 3); // up coverage
        x2("(?<=a.b)c", "azbc", 3, 4); // up coverage
        n("(?<=(?:abcde){30})z", "abc"); // up coverage
        x2("(?<=(?(a)a|bb))z", "aaz", 2, 3); // up coverage
        x2("[a]*\\W", "aa@", 0, 3); // up coverage
        x2("[a]*[b]", "aab", 0, 3); // up coverage
        n("a*\\W", "aaa"); // up coverage
        n("(?W)a*\\W", "aaa"); // up coverage
        x2("(?<=ab(?<=ab))", "ab", 2, 2); // up coverage
        x2("(?<x>a)(?<x>b)(\\k<x>)+", "abbaab", 0, 6); // up coverage
        x2("()(\\1)(\\2)", "abc", 0, 0); // up coverage
        x2("((?(a)b|c))(\\1)", "abab", 0, 4); // up coverage
        x2("(?<x>$|b\\g<x>)", "bbb", 0, 3); // up coverage
        x2("(?<x>(?(a)a|b)|c\\g<x>)", "cccb", 0, 4); // up coverage
        x2("(a)(?(1)a*|b*)+", "aaaa", 0, 4); // up coverage
        x2("[[^abc]&&cde]*", "de", 0, 2); // up coverage
        n("(a){10}{10}", "aa"); // up coverage
        x2("(?:a?)+", "aa", 0, 2); // up coverage
        x2("(?:a?)*?", "a", 0, 0); // up coverage
        x2("(?:a*)*?", "a", 0, 0); // up coverage
        x2("(?:a+?)*", "a", 0, 1); // up coverage
        x2("\\h", "5", 0, 1); // up coverage
        x2("\\H", "z", 0, 1); // up coverage
        x2("[\\h]", "5", 0, 1); // up coverage
        x2("[\\H]", "z", 0, 1); // up coverage
        x2("[\\o{101}]", "A", 0, 1); // up coverage
        x2("[\\u0041]", "A", 0, 1); // up coverage

        x2("(?~)", "", 0, 0);
        x2("(?~)", "A", 0, 0);
        x2("(?~ab)", "abc", 0, 0);
        x2("(?~abc)", "abc", 0, 0);
        x2("(?~abc|ab)", "abc", 0, 0);
        x2("(?~ab|abc)", "abc", 0, 0);
        x2("(?~a.c)", "abc", 0, 0);
        x2("(?~a.c|ab)", "abc", 0, 0);
        x2("(?~ab|a.c)", "abc", 0, 0);
        x2("aaaaa(?~)", "aaaaaaaaaa", 0, 5);
        x2("(?~(?:|aaa))", "aaa", 0, 0);
        x2("(?~aaa|)", "aaa", 0, 0);
        x2("a(?~(?~)).", "abcdefghijklmnopqrstuvwxyz", 0, 26); // nested absent functions cause strange result
        x2("/\\*(?~\\*/)\\*/", "/* */ */", 0, 5);
        x2("(?~\\w+)zzzzz", "zzzzz", 0, 5);
        x2("(?~\\w*)zzzzz", "zzzzz", 0, 5);
        x2("(?~A.C|B)", "ABC", 0, 0);
        x2("(?~XYZ|ABC)a", "ABCa", 1, 4);
        x2("(?~XYZ|ABC)a", "aABCa", 0, 1);
        x2("<[^>]*>(?~[<>])</[^>]*>", "<a>vvv</a>   <b>  </b>", 0, 10);
        x2("(?~ab)", "ccc\ndab", 0, 5);
        x2("(?m:(?~ab))", "ccc\ndab", 0, 5);
        x2("(?-m:(?~ab))", "ccc\ndab", 0, 5);
        x2("(?~abc)xyz", "xyz012345678901234567890123456789abc", 0, 3);

        // absent with expr
        x2("(?~|78|\\d*)", "123456789", 0, 6);
        x2("(?~|def|(?:abc|de|f){0,100})", "abcdedeabcfdefabc", 0, 11);
        x2("(?~|ab|.*)", "ccc\nddd", 0, 3);
        x2("(?~|ab|\\O*)", "ccc\ndab", 0, 5);
        x2("(?~|ab|\\O{2,10})", "ccc\ndab", 0, 5);
        x2("(?~|ab|\\O{1,10})", "ab", 1, 2);
        n("(?~|ab|\\O{2,10})", "ab");
        x2("(?~|abc|\\O{1,10})", "abc", 1, 3);
        x2("(?~|ab|\\O{5,10})|abc", "abc", 0, 3);
        x2("(?~|ab|\\O{1,10})", "cccccccccccab", 0, 10);
        x2("(?~|aaa|)", "aaa", 0, 0);
        x2("(?~||a*)", "aaaaaa", 0, 0);
        x2("(?~||a*?)", "aaaaaa", 0, 0);
        x2("(a)(?~|b|\\1)", "aaaaaa", 0, 2);
        x2("(a)(?~|bb|(?:a\\1)*)", "aaaaaa", 0, 5);
        x2("(b|c)(?~|abac|(?:a\\1)*)", "abababacabab", 1, 4);
        n("(?~|c|a*+)a", "aaaaa");
        x2("(?~|aaaaa|a*+)", "aaaaa", 0, 0);
        x2("(?~|aaaaaa|a*+)b", "aaaaaab", 1, 7);
        x2("(?~|abcd|(?>))", "zzzabcd", 0, 0);
        x2("(?~|abc|a*?)", "aaaabc", 0, 0);

        // absent range cutter
        x2("(?~|abc)a*", "aaaaaabc", 0, 5);
        x2("(?~|abc)a*z|aaaaaabc", "aaaaaabc", 0, 8);
        x2("(?~|aaaaaa)a*", "aaaaaa", 0, 0);
        x2("(?~|abc)aaaa|aaaabc", "aaaabc", 0, 6);
        x2("(?>(?~|abc))aaaa|aaaabc", "aaaabc", 0, 6);
        x2("(?~|)a", "a", 0, 1);
        n("(?~|a)a", "a");
        x2("(?~|a)(?~|)a", "a", 0, 1);
        x2("(?~|a).*(?~|)a", "bbbbbbbbbbbbbbbbbbbba", 0, 21);
        x2("(?~|abc).*(xyz|pqr)(?~|)abc", "aaaaxyzaaapqrabc", 0, 16);
        x2("(?~|abc).*(xyz|pqr)(?~|)abc", "aaaaxyzaaaabcpqrabc", 11, 19);
        n("\\A(?~|abc).*(xyz|pqrabc)(?~|)abc", "aaaaxyzaaaabcpqrabcabc");

        x2("", "あ", 0, 0);
        x2("あ", "あ", 0, 3);
        n("い", "あ");
        x2("うう", "うう", 0, 6);
        x2("あいう", "あいう", 0, 9);
        x2("こここここここここここここここここここここここここここここここここここ", "こここここここここここここここここここここここここここここここここここ", 0, 105);
        x2("あ", "いあ", 3, 6);
        x2("いう", "あいう", 3, 9);
        x2("\\xca\\xb8", "ʸ", 0, 2);
        x2(".", "あ", 0, 3);
        x2("..", "かき", 0, 6);
        x2("\\w", "お", 0, 3);
        n("\\W", "あ");
        x2("[\\W]", "う$", 3, 4);
        x2("\\S", "そ", 0, 3);
        x2("\\S", "漢", 0, 3);
        x2("\\b", "気 ", 0, 0);
        x2("\\b", " ほ", 1, 1);
        x2("\\B", "せそ ", 3, 3);
        x2("\\B", "う ", 4, 4);
        x2("\\B", " い", 0, 0);
        x2("[たち]", "ち", 0, 3);
        n("[なに]", "ぬ");
        x2("[う-お]", "え", 0, 3);
        n("[^け]", "け");
        x2("[\\w]", "ね", 0, 3);
        n("[\\d]", "ふ");
        x2("[\\D]", "は", 0, 3);
        n("[\\s]", "く");
        x2("[\\S]", "へ", 0, 3);
        x2("[\\w\\d]", "よ", 0, 3);
        x2("[\\w\\d]", "   よ", 3, 6);
        n("\\w鬼車", " 鬼車");
        x2("鬼\\W車", "鬼 車", 0, 7);
        x2("あ.い.う", "ああいいう", 0, 15);
        x2(".\\wう\\W..ぞ", "えうう うぞぞ", 0, 19);
        x2("\\s\\wこここ", " ここここ", 0, 13);
        x2("ああ.け", "ああけけ", 0, 12);
        n(".い", "いえ");
        x2(".お", "おお", 0, 6);
        x2("^あ", "あ", 0, 3);
        x2("^む$", "む", 0, 3);
        x2("^\\w$", "に", 0, 3);
        x2("^\\wかきくけこ$", "zかきくけこ", 0, 16);
        x2("^\\w...うえお$", "zあいううえお", 0, 19);
        x2("\\w\\w\\s\\Wおおお\\d", "aお  おおお4", 0, 16);
        x2("\\Aたちつ", "たちつ", 0, 9);
        x2("むめも\\Z", "むめも", 0, 9);
        x2("かきく\\z", "かきく", 0, 9);
        x2("かきく\\Z", "かきく\n", 0, 9);
        x2("\\Gぽぴ", "ぽぴ", 0, 6);
        n("\\Gえ", "うえお");
        n("とて\\G", "とて");
        n("まみ\\A", "まみ");
        n("ま\\Aみ", "まみ");
        x2("(?=せ)せ", "せ", 0, 3);
        n("(?=う).", "い");
        x2("(?!う)か", "か", 0, 3);
        n("(?!と)あ", "と");
        x2("(?i:あ)", "あ", 0, 3);
        x2("(?i:ぶべ)", "ぶべ", 0, 6);
        n("(?i:い)", "う");
        x2("(?m:よ.)", "よ\n", 0, 4);
        x2("(?m:.め)", "ま\nめ", 3, 7);
        x2("あ?", "", 0, 0);
        x2("変?", "化", 0, 0);
        x2("変?", "変", 0, 3);
        x2("量*", "", 0, 0);
        x2("量*", "量", 0, 3);
        x2("子*", "子子子", 0, 9);
        x2("馬*", "鹿馬馬馬馬", 0, 0);
        n("山+", "");
        x2("河+", "河", 0, 3);
        x2("時+", "時時時時", 0, 12);
        x2("え+", "ええううう", 0, 6);
        x2("う+", "おうううう", 3, 15);
        x2(".?", "た", 0, 3);
        x2(".*", "ぱぴぷぺ", 0, 12);
        x2(".+", "ろ", 0, 3);
        x2(".+", "いうえか\n", 0, 12);
        x2("あ|い", "あ", 0, 3);
        x2("あ|い", "い", 0, 3);
        x2("あい|いう", "あい", 0, 6);
        x2("あい|いう", "いう", 0, 6);
        x2("を(?:かき|きく)", "をかき", 0, 9);
        x2("を(?:かき|きく)け", "をきくけ", 0, 12);
        x2("あい|(?:あう|あを)", "あを", 0, 6);
        x2("あ|い|う", "えう", 3, 6);
        x2("あ|い|うえ|おかき|く|けこさ|しすせ|そ|たち|つてとなに|ぬね", "しすせ", 0, 9);
        n("あ|い|うえ|おかき|く|けこさ|しすせ|そ|たち|つてとなに|ぬね", "すせ");
        x2("あ|^わ", "ぶあ", 3, 6);
        x2("あ|^を", "をあ", 0, 3);
        x2("鬼|\\G車", "け車鬼", 6, 9);
        x2("鬼|\\G車", "車鬼", 0, 3);
        x2("鬼|\\A車", "b車鬼", 4, 7);
        x2("鬼|\\A車", "車", 0, 3);
        x2("鬼|車\\Z", "車鬼", 3, 6);
        x2("鬼|車\\Z", "車", 0, 3);
        x2("鬼|車\\Z", "車\n", 0, 3);
        x2("鬼|車\\z", "車鬼", 3, 6);
        x2("鬼|車\\z", "車", 0, 3);
        x2("\\w|\\s", "お", 0, 3);
        x2("\\w|%", "%お", 0, 1);
        x2("\\w|[&$]", "う&", 0, 3);
        x2("[い-け]", "う", 0, 3);
        x2("[い-け]|[^か-こ]", "あ", 0, 3);
        x2("[い-け]|[^か-こ]", "か", 0, 3);
        x2("[^あ]", "\n", 0, 1);
        x2("(?:あ|[う-き])|いを", "うを", 0, 3);
        x2("(?:あ|[う-き])|いを", "いを", 0, 6);
        x2("あいう|(?=けけ)..ほ", "けけほ", 0, 9);
        x2("あいう|(?!けけ)..ほ", "あいほ", 0, 9);
        x2("(?=をあ)..あ|(?=をを)..あ", "ををあ", 0, 9);
        x2("(?<=あ|いう)い", "いうい", 6, 9);
        n("(?>あ|あいえ)う", "あいえう");
        x2("(?>あいえ|あ)う", "あいえう", 0, 12);
        x2("あ?|い", "あ", 0, 3);
        x2("あ?|い", "い", 0, 0);
        x2("あ?|い", "", 0, 0);
        x2("あ*|い", "ああ", 0, 6);
        x2("あ*|い*", "いあ", 0, 0);
        x2("あ*|い*", "あい", 0, 3);
        x2("[aあ]*|い*", "aあいいい", 0, 4);
        x2("あ+|い*", "", 0, 0);
        x2("あ+|い*", "いいい", 0, 9);
        x2("あ+|い*", "あいいい", 0, 3);
        x2("あ+|い*", "aあいいい", 0, 0);
        n("あ+|い+", "");
        x2("(あ|い)?", "い", 0, 3);
        x2("(あ|い)*", "いあ", 0, 6);
        x2("(あ|い)+", "いあい", 0, 9);
        x2("(あい|うあ)+", "うああいうえ", 0, 12);
        x2("(あい|うえ)+", "うああいうえ", 6, 18);
        x2("(あい|うあ)+", "ああいうあ", 3, 15);
        x2("(あい|うあ)+", "あいをうあ", 0, 6);
        x2("(あい|うあ)+", "$$zzzzあいをうあ", 6, 12);
        x2("(あ|いあい)+", "あいあいあ", 0, 15);
        x2("(あ|いあい)+", "いあ", 3, 6);
        x2("(あ|いあい)+", "いあああいあ", 3, 12);
        x2("(?:あ|い)(?:あ|い)", "あい", 0, 6);
        x2("(?:あ*|い*)(?:あ*|い*)", "あああいいい", 0, 9);
        x2("(?:あ*|い*)(?:あ+|い+)", "あああいいい", 0, 18);
        x2("(?:あ+|い+){2}", "あああいいい", 0, 18);
        x2("(?:あ+|い+){1,2}", "あああいいい", 0, 18);
        x2("(?:あ+|\\Aい*)うう", "うう", 0, 6);
        n("(?:あ+|\\Aい*)うう", "あいうう");
        x2("(?:^あ+|い+)*う", "ああいいいあいう", 18, 24);
        x2("(?:^あ+|い+)*う", "ああいいいいう", 0, 21);
        x2("う{0,}", "うううう", 0, 12);
        x2("あ|(?i)c", "C", 0, 1);
        x2("(?i)c|あ", "C", 0, 1);
        x2("(?i:あ)|a", "a", 0, 1);
        n("(?i:あ)|a", "A");
        x2("[あいう]?", "あいう", 0, 3);
        x2("[あいう]*", "あいう", 0, 9);
        x2("[^あいう]*", "あいう", 0, 0);
        n("[^あいう]+", "あいう");
        x2("あ??", "あああ", 0, 0);
        x2("いあ??い", "いあい", 0, 9);
        x2("あ*?", "あああ", 0, 0);
        x2("いあ*?", "いああ", 0, 3);
        x2("いあ*?い", "いああい", 0, 12);
        x2("あ+?", "あああ", 0, 3);
        x2("いあ+?", "いああ", 0, 6);
        x2("いあ+?い", "いああい", 0, 12);
        x2("(?:天?)??", "天", 0, 0);
        x2("(?:天??)?", "天", 0, 0);
        x2("(?:夢?)+?", "夢夢夢", 0, 3);
        x2("(?:風+)??", "風風風", 0, 0);
        x2("(?:雪+)??霜", "雪雪雪霜", 0, 12);
        x2("(?:あい)?{2}", "", 0, 0);
        x2("(?:鬼車)?{2}", "鬼車鬼車鬼", 0, 12);
        x2("(?:鬼車)*{0}", "鬼車鬼車鬼", 0, 0);
        x2("(?:鬼車){3,}", "鬼車鬼車鬼車鬼車", 0, 24);
        n("(?:鬼車){3,}", "鬼車鬼車");
        x2("(?:鬼車){2,4}", "鬼車鬼車鬼車", 0, 18);
        x2("(?:鬼車){2,4}", "鬼車鬼車鬼車鬼車鬼車", 0, 24);
        x2("(?:鬼車){2,4}?", "鬼車鬼車鬼車鬼車鬼車", 0, 12);
        x2("(?:鬼車){,}", "鬼車{,}", 0, 9);
        x2("(?:かきく)+?{2}", "かきくかきくかきく", 0, 18);
        x3("(火)", "火", 0, 3, 1);
        x3("(火水)", "火水", 0, 6, 1);
        x2("((時間))", "時間", 0, 6);
        x3("((風水))", "風水", 0, 6, 1);
        x3("((昨日))", "昨日", 0, 6, 2);
        x3("((((((((((((((((((((量子))))))))))))))))))))", "量子", 0, 6, 20);
        x3("(あい)(うえ)", "あいうえ", 0, 6, 1);
        x3("(あい)(うえ)", "あいうえ", 6, 12, 2);
        x3("()(あ)いう(えおか)きくけこ", "あいうえおかきくけこ", 9, 18, 3);
        x3("(()(あ)いう(えおか)きくけこ)", "あいうえおかきくけこ", 9, 18, 4);
        x3(".*(フォ)ン・マ(ン()シュタ)イン", "フォン・マンシュタイン", 15, 27, 2);
        x2("(^あ)", "あ", 0, 3);
        x3("(あ)|(あ)", "いあ", 3, 6, 1);
        x3("(^あ)|(あ)", "いあ", 3, 6, 2);
        x3("(あ?)", "あああ", 0, 3, 1);
        x3("(ま*)", "ままま", 0, 9, 1);
        x3("(と*)", "", 0, 0, 1);
        x3("(る+)", "るるるるるるる", 0, 21, 1);
        x3("(ふ+|へ*)", "ふふふへへ", 0, 9, 1);
        x3("(あ+|い?)", "いいいああ", 0, 3, 1);
        x3("(あいう)?", "あいう", 0, 9, 1);
        x3("(あいう)*", "あいう", 0, 9, 1);
        x3("(あいう)+", "あいう", 0, 9, 1);
        x3("(さしす|あいう)+", "あいう", 0, 9, 1);
        x3("([なにぬ][かきく]|かきく)+", "かきく", 0, 9, 1);
        x3("((?i:あいう))", "あいう", 0, 9, 1);
        x3("((?m:あ.う))", "あ\nう", 0, 7, 1);
        x3("((?=あん)あ)", "あんい", 0, 3, 1);
        x3("あいう|(.あいえ)", "んあいえ", 0, 12, 1);
        x3("あ*(.)", "ああああん", 12, 15, 1);
        x3("あ*?(.)", "ああああん", 0, 3, 1);
        x3("あ*?(ん)", "ああああん", 12, 15, 1);
        x3("[いうえ]あ*(.)", "えああああん", 15, 18, 1);
        x3("(\\Aいい)うう", "いいうう", 0, 6, 1);
        n("(\\Aいい)うう", "んいいうう");
        x3("(^いい)うう", "いいうう", 0, 6, 1);
        n("(^いい)うう", "んいいうう");
        x3("ろろ(るる$)", "ろろるる", 6, 12, 1);
        n("ろろ(るる$)", "ろろるるる");
        x2("(無)\\1", "無無", 0, 6);
        n("(無)\\1", "無武");
        x2("(空?)\\1", "空空", 0, 6);
        x2("(空??)\\1", "空空", 0, 0);
        x2("(空*)\\1", "空空空空空", 0, 12);
        x3("(空*)\\1", "空空空空空", 0, 6, 1);
        x2("あ(い*)\\1", "あいいいい", 0, 15);
        x2("あ(い*)\\1", "あい", 0, 3);
        x2("(あ*)(い*)\\1\\2", "あああいいあああいい", 0, 30);
        x2("(あ*)(い*)\\2", "あああいいいい", 0, 21);
        x3("(あ*)(い*)\\2", "あああいいいい", 9, 15, 2);
        x2("(((((((ぽ*)ぺ))))))ぴ\\7", "ぽぽぽぺぴぽぽぽ", 0, 24);
        x3("(((((((ぽ*)ぺ))))))ぴ\\7", "ぽぽぽぺぴぽぽぽ", 0, 9, 7);
        x2("(は)(ひ)(ふ)\\2\\1\\3", "はひふひはふ", 0, 18);
        x2("([き-け])\\1", "くく", 0, 6);
        x2("(\\w\\d\\s)\\1", "あ5 あ5 ", 0, 10);
        n("(\\w\\d\\s)\\1", "あ5 あ5");
        x2("(誰？|[あ-う]{3})\\1", "誰？誰？", 0, 12);
        x2("...(誰？|[あ-う]{3})\\1", "あaあ誰？誰？", 0, 19);
        x2("(誰？|[あ-う]{3})\\1", "ういうういう", 0, 18);
        x2("(^こ)\\1", "ここ", 0, 6);
        n("(^む)\\1", "めむむ");
        n("(あ$)\\1", "ああ");
        n("(あい\\Z)\\1", "あい");
        x2("(あ*\\Z)\\1", "あ", 3, 3);
        x2(".(あ*\\Z)\\1", "いあ", 3, 6);
        x3("(.(やいゆ)\\2)", "zやいゆやいゆ", 0, 19, 1);
        x3("(.(..\\d.)\\2)", "あ12341234", 0, 11, 1);
        x2("((?i:あvず))\\1", "あvずあvず", 0, 14);
        x2("(?<愚か>変|\\(\\g<愚か>\\))", "((((((変))))))", 0, 15);
        x2("\\A(?:\\g<阿_1>|\\g<云_2>|\\z終了  (?<阿_1>観|自\\g<云_2>自)(?<云_2>在|菩薩\\g<阿_1>菩薩))$", "菩薩自菩薩自在自菩薩自菩薩", 0, 39);
        x2("[[ひふ]]", "ふ", 0, 3);
        x2("[[いおう]か]", "か", 0, 3);
        n("[[^あ]]", "あ");
        n("[^[あ]]", "あ");
        x2("[^[^あ]]", "あ", 0, 3);
        x2("[[かきく]&&きく]", "く", 0, 3);
        n("[[かきく]&&きく]", "か");
        n("[[かきく]&&きく]", "け");
        x2("[あ-ん&&い-を&&う-ゑ]", "ゑ", 0, 3);
        n("[^あ-ん&&い-を&&う-ゑ]", "ゑ");
        x2("[[^あ&&あ]&&あ-ん]", "い", 0, 3);
        n("[[^あ&&あ]&&あ-ん]", "あ");
        x2("[[^あ-ん&&いうえお]&&[^う-か]]", "き", 0, 3);
        n("[[^あ-ん&&いうえお]&&[^う-か]]", "い");
        x2("[^[^あいう]&&[^うえお]]", "う", 0, 3);
        x2("[^[^あいう]&&[^うえお]]", "え", 0, 3);
        n("[^[^あいう]&&[^うえお]]", "か");
        x2("[あ-&&-あ]", "-", 0, 1);
        x2("[^[^a-zあいう]&&[^bcdefgうえお]q-w]", "え", 0, 3);
        x2("[^[^a-zあいう]&&[^bcdefgうえお]g-w]", "f", 0, 1);
        x2("[^[^a-zあいう]&&[^bcdefgうえお]g-w]", "g", 0, 1);
        n("[^[^a-zあいう]&&[^bcdefgうえお]g-w]", "2");
        x2("a<b>バージョンのダウンロード<\\/b>", "a<b>バージョンのダウンロード</b>", 0, 44);
        x2(".<b>バージョンのダウンロード<\\/b>", "a<b>バージョンのダウンロード</b>", 0, 44);
        x2("\\n?\\z", "こんにちは", 15, 15);
        x2("(?m).*", "青赤黄", 0, 9);
        x2("(?m).*a", "青赤黄a", 0, 10);

        x2("\\p{Hiragana}", "ぴ", 0, 3);
        n("\\P{Hiragana}", "ぴ");

        x2("\\p{Word}", "こ", 0, 3);
        n("\\p{^Word}", "こ");
        x2("[\\p{Word}]", "こ", 0, 3);
        n("[\\p{^Word}]", "こ");
        n("[^\\p{Word}]", "こ");
        x2("[^\\p{^Word}]", "こ", 0, 3);
        x2("[^\\p{^Word}&&\\p{ASCII}]", "こ", 0, 3);
        x2("[^\\p{^Word}&&\\p{ASCII}]", "a", 0, 1);
        n("[^\\p{^Word}&&\\p{ASCII}]", "#");
        x2("[^[\\p{^Word}]&&[\\p{ASCII}]]", "こ", 0, 3);
        x2("[^[\\p{ASCII}]&&[^\\p{Word}]]", "こ", 0, 3);
        n("[[\\p{ASCII}]&&[^\\p{Word}]]", "こ");
        x2("[^[\\p{^Word}]&&[^\\p{ASCII}]]", "こ", 0, 3);
        x2("[^\\x{104a}]", "こ", 0, 3);
        x2("[^\\p{^Word}&&[^\\x{104a}]]", "こ", 0, 3);
        x2("[^[\\p{^Word}]&&[^\\x{104a}]]", "こ", 0, 3);
        n("[^\\p{Word}||[^\\x{104a}]]", "こ");

        x2("\\p{^Cntrl}", "こ", 0, 3);
        n("\\p{Cntrl}", "こ");
        x2("[\\p{^Cntrl}]", "こ", 0, 3);
        n("[\\p{Cntrl}]", "こ");
        n("[^\\p{^Cntrl}]", "こ");
        x2("[^\\p{Cntrl}]", "こ", 0, 3);
        x2("[^\\p{Cntrl}&&\\p{ASCII}]", "こ", 0, 3);
        x2("[^\\p{Cntrl}&&\\p{ASCII}]", "a", 0, 1);
        n("[^\\p{^Cntrl}&&\\p{ASCII}]", "#");
        x2("[^[\\p{^Cntrl}]&&[\\p{ASCII}]]", "こ", 0, 3);
        x2("[^[\\p{ASCII}]&&[^\\p{Cntrl}]]", "こ", 0, 3);
        n("[[\\p{ASCII}]&&[^\\p{Cntrl}]]", "こ");
        n("[^[\\p{^Cntrl}]&&[^\\p{ASCII}]]", "こ");
        n("[^\\p{^Cntrl}&&[^\\x{104a}]]", "こ");
        n("[^[\\p{^Cntrl}]&&[^\\x{104a}]]", "こ");
        n("[^\\p{Cntrl}||[^\\x{104a}]]", "こ");

        x2("(?-W:\\p{Word})", "こ", 0, 3);
        n("(?W:\\p{Word})", "こ");
        x2("(?W:\\p{Word})", "k", 0, 1);
        x2("(?-W:[[:word:]])", "こ", 0, 3);
        n("(?W:[[:word:]])", "こ");
        x2("(?-D:\\p{Digit})", "３", 0, 3);
        n("(?D:\\p{Digit})", "３");
        x2("(?-S:\\p{Space})", "\u{85}", 0, 2);
        n("(?S:\\p{Space})", "\u{85}");
        x2("(?-P:\\p{Word})", "こ", 0, 3);
        n("(?P:\\p{Word})", "こ");
        x2("(?-W:\\w)", "こ", 0, 3);
        n("(?W:\\w)", "こ");
        x2("(?-W:\\w)", "k", 0, 1);
        x2("(?W:\\w)", "k", 0, 1);
        n("(?-W:\\W)", "こ");
        x2("(?W:\\W)", "こ", 0, 3);
        n("(?-W:\\W)", "k");
        n("(?W:\\W)", "k");

        x2("(?-W:\\b)", "こ", 0, 0);
        n("(?W:\\b)", "こ");
        x2("(?-W:\\b)", "h", 0, 0);
        x2("(?W:\\b)", "h", 0, 0);
        n("(?-W:\\B)", "こ");
        x2("(?W:\\B)", "こ", 0, 0);
        n("(?-W:\\B)", "h");
        n("(?W:\\B)", "h");
        x2("(?-P:\\b)", "こ", 0, 0);
        n("(?P:\\b)", "こ");
        x2("(?-P:\\b)", "h", 0, 0);
        x2("(?P:\\b)", "h", 0, 0);
        n("(?-P:\\B)", "こ");
        x2("(?P:\\B)", "こ", 0, 0);
        n("(?-P:\\B)", "h");
        n("(?P:\\B)", "h");

        x2("\\p{InBasicLatin}", "\u{41}", 0, 1);
        // x2("\\p{Grapheme_Cluster_Break_Regional_Indicator}", "\xF0\x9F\x87\xA9", 0, 4);
        // n("\\p{Grapheme_Cluster_Break_Regional_Indicator}",  "\xF0\x9F\x87\xA5");

        // extended grapheme cluster

        // CR + LF
        n(".\\y\\O", "\u{0d}\u{0a}");

        n("^.\\y.$", "g̈");
        x2(".\\Y.", "g̈", 0, 3);
        x2("\\y.\\Y.\\y", "g̈", 0, 3);
        x2("\\y.\\y", "각", 0, 3);
        x2("^.\\Y.\\Y.$", "각", 0, 9);
        n("^.\\y.\\Y.$", "각");
        x2(".\\Y.", "நி", 0, 6);
        n(".\\y.", "நி");
        x2(".\\Y.", "กำ", 0, 6);
        n(".\\y.", "กำ");
        x2(".\\Y.", "षि", 0, 6);
        n(".\\y.", "षि");
        x2("..\\Y.", "〰‍⭕", 0, 9);
        x2("...\\Y.", "〰̂‍⭕", 0, 11);
        n("...\\Y.", "〰Ͱ‍⭕");

        n("^\\X\\X.$", "g̈");
        x2("^\\X$", "g̈", 0, 3);
        x2("^\\X$", "각", 0, 9);
        n("^\\X\\X\\X$", "각");
        x2("^\\X$", "நி", 0, 6);
        n("\\X\\X", "நி");
        x2("^\\X$", "กำ", 0, 6);
        n("\\X\\X", "กำ");
        x2("^\\X$", "षि", 0, 6);
        n("\\X\\X", "षि");
        n("^\\X.$", "நி");
        x2("h\\Xllo", "hàllo", 0, 7);
        x2("(?y{g})\\yabc\\y", "abc", 0, 3);
        x2("(?y{g})\\y\\X\\y", "abc", 0, 1);
        x2("(?y{w})\\yabc\\y", "abc", 0, 3);

        x2("(?y{w})\\X", "‍❇", 0, 6);
        x2("(?y{w})\\X", "  ", 0, 2);
        x2("(?y{w})\\X", "a‍", 0, 4);
        x2("(?y{w})\\y\\X\\y", "abc", 0, 3);
        x2("(?y{w})\\y\\X\\y", "v·w", 0, 4);
        x2("(?y{w})\\X", "14 45", 0, 2);
        x2("(?y{w})\\X", "a14", 0, 3);
        x2("(?y{w})\\X", "832e", 0, 4);
        x2("(?y{w})\\X", "8，۰", 0, 6);
        x2("(?y{w})\\y\\X\\y", "ケン", 0, 6);
        x2("(?y{w})\\y\\X\\y", "ケン タ", 0, 12);
        x2("(?y{w})\\y\\X\\y", "!#", 0, 1);
        x2("(?y{w})\\y\\X\\y", "山ア", 0, 3);
        x2("(?y{w})\\X", "3.14", 0, 4);
        x2("(?y{w})\\X", "3 14", 0, 1);

        x2("c.*\\b", "abc", 2, 3);
        x2("\\b.*abc.*\\b", "abc", 0, 3);
        // swiftlint:disable line_length
        x2("((?()0+)+++(((0\\g<0>)0)|())++++((?(1)(0\\g<0>))++++++0*())++++((?(1)(0\\g<1>)+)++++++++++*())++++((?(1)((0)\\g<0>)+)++())+0++*+++(((0\\g<0>))*())++++((?(1)(0\\g<0>)+)++++++++++*|)++++*+++((?(1)((0)\\g<0>)+)+++++++++())++*|)++++((?()0))|", "abcde", 0, 0); // #139

        n("(*FAIL)", "abcdefg");
        n("abcd(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)(*FAIL)", "abcdefg");
        // swiftlint:enable line_length

        x2("(?:[ab]|(*MAX{2}).)*", "abcbaaccaaa", 0, 7);
        x2("(?:(*COUNT[AB]{X})[ab]|(*COUNT[CD]{X})[cd])*(*CMP{AB,<,CD})",
           "abababcdab", 5, 8);
        x2("(?(?{....})123|456)", "123", 0, 3);
        x2("(?(*FAIL)123|456)", "456", 0, 3);

        x2("\\g'0'++{,0}", "abcdefgh", 0, 0);
        x2("\\g'0'++{,0}?", "abcdefgh", 0, 0);
        x2("\\g'0'++{,0}b", "abcdefgh", 1, 2);
        x2("\\g'0'++{,0}?def", "abcdefgh", 3, 6);
        x2("a{1,3}?", "aaa", 0, 1);
        x2("a{3}", "aaa", 0, 3);
        x2("a{3}?", "aaa", 0, 3);
        x2("a{3}?", "aa", 0, 0);
        x2("a{3,3}?", "aaa", 0, 3);
        n("a{3,3}?", "aa");
        x2("a{1,3}+", "aaaaaa", 0, 6);
        x2("a{3}+", "aaaaaa", 0, 6);
        x2("a{3,3}+", "aaaaaa", 0, 6);
        n("a{2,3}?", "a");
        n("a{3,2}a", "aaa");
        x2("a{3,2}b", "aaab", 0, 4);
        x2("a{3,2}b", "aaaab", 1, 5);
        x2("a{3,2}b", "aab", 0, 3);
        x2("a{3,2}?", "", 0, 0);     /* == (?:a{3,2})?*/
        x2("a{2,3}+a", "aaa", 0, 3); /* == (?:a{2,3})+*/
        x2("[\\x{0}-\\x{7fffffff}]", "a", 0, 1);

        x2("[a[cdef]]", "a", 0, 1);
        n("[a[xyz]-c]", "b");
        x2("[a[xyz]-c]", "a", 0, 1);
        x2("[a[xyz]-c]", "-", 0, 1);
        x2("[a[xyz]-c]", "c", 0, 1);
        x2("(a.c|def)(.{4})(?<=\\1)", "abcdabc", 0, 7);
        x2("(a.c|de)(.{4})(?<=\\1)", "abcdabc", 0, 7);
        x2("(a.c|def)(.{5})(?<=d\\1e)", "abcdabce", 0, 8);
        x2("(a.c|.)d(?<=\\k<1>d)", "zzzzzabcdabc", 5, 9);
        x2("(?<=az*)abc", "azzzzzzzzzzabcdabcabc", 11, 14);
        x2("(?<=ab|abc|abcd)ef", "abcdef", 4, 6);
        x2("(?<=ta+|tb+|tc+|td+)zz", "tcccccccccczz", 11, 13);
        x2("(?<=t.{7}|t.{5}|t.{2}|t.)zz", "tczz", 2, 4);
        x2("(?<=t.{7}|t.{5}|t.{2})zz", "tczzzz", 3, 5);
        x2("(?<=t.{7}|t.{5}|t.{3})zz", "tczzazzbzz", 8, 10);
        n("(?<=t.{7}|t.{5}|t.{3})zz", "tczzazzbczz");
        x2("(?<=(ab|abc|abcd))ef", "abcdef", 4, 6);
        x2("(?<=(ta+|tb+|tc+|td+))zz", "tcccccccccczz", 11, 13);
        x2("(?<=(t.{7}|t.{5}|t.{2}|t.))zz", "tczz", 2, 4);
        x2("(?<=(t.{7}|t.{5}|t.{2}))zz", "tczzzz", 3, 5);
        x2("(?<=(t.{7}|t.{5}|t.{3}))zz", "tczzazzbzz", 8, 10);
        n("(?<=(t.{7}|t.{5}|t.{3}))zz", "tczzazzbczz");
        x2("(.{1,4})(.{1,4})(?<=\\2\\1)", "abaaba", 0, 6);
        x2("(.{1,4})(.{1,4})(?<=\\2\\1)", "ababab", 0, 6);
        n("(.{1,4})(.{1,4})(?<=\\2\\1)", "abcdabce");
        x2("(.{1,4})(.{1,4})(?<=\\2\\1)", "abcdabceabce", 4, 12);
        x2("(?<=a)", "a", 1, 1);
        x2("(?<=a.*\\w)z", "abbbz", 4, 5);
        n("(?<=a.*\\w)z", "abb z");
        x2("(?<=a.*\\W)z", "abb z", 4, 5);
        x2("(?<=a.*\\b)z", "abb z", 4, 5);
        x2("(?<=(?>abc))", "abc", 3, 3);
        x2("(?<=a\\Xz)", "abz", 3, 3);
        n("(?<=^a*)bc", "zabc");
        n("(?<=a*\\b)b", "abc");
        x2("(?<=a+.*[efg])z", "abcdfz", 5, 6);
        x2("(?<=a+.*[efg])z", "abcdfgz", 6, 7);
        n("(?<=a+.*[efg])z", "bcdfz");
        x2("(?<=a*.*[efg])z", "bcdfz", 4, 5);
        n("(?<=a+.*[efg])z", "abcdz");
        x2("(?<=v|t|a+.*[efg])z", "abcdfz", 5, 6);
        x2("(?<=v|t|^a+.*[efg])z", "abcdfz", 5, 6);
        x2("(?<=^(?:v|t|a+.*[efg]))z", "abcdfz", 5, 6);
        x2("(?<=v|^t|a+.*[efg])z", "uabcdfz", 6, 7);
        n("^..(?<=(a{,2}))\\1z", "aaaaz"); // !!! look-behind is shortest priority
        x2("^..(?<=(a{,2}))\\1z", "aaz", 0, 3); // shortest priority
        x2("(?<=(?<= )| )", "abcde fg", 6, 6); // #173

        // swiftlint:disable line_length
        x2("(?<=D|)(?<=@!nnnnnnnnnIIIIn;{1}D?()|<x@x*xxxD|)(?<=@xxx|xxxxx\\g<1>;{1}x)", "(?<=D|)(?<=@!nnnnnnnnnIIIIn;{1}D?()|<x@x*xxxD|)(?<=@xxx|xxxxx\\g<1>;{1}x)", 55, 55); // #173
        // swiftlint:enable line_length

        x2("(?<=;()|)\\g<1>", "", 0, 0); // reduced #173
        x2("(?<=;()|)\\k<1>", ";", 1, 1);
        x2("(())\\g<3>{0}(?<=|())", "abc", 0, 0); // #175
        x2("(?<=()|)\\1{0}", "abc", 0, 0);
        x2("(?<=(?<=abc))def", "abcdef", 3, 6);
        x2("(?<=ab(?<=.+b)c)def", "abcdef", 3, 6);
        n("(?<=ab(?<=a+)c)def", "abcdef");
        n("(?<=abc)(?<!abc)def", "abcdef");
        n("(?<!ab.)(?<=.bc)def", "abcdef");
        x2("(?<!ab.)(?<=.bc)def", "abcdefcbcdef", 9, 12);
        n("(?<!abc)def", "abcdef");
        n("(?<!xxx|abc)def", "abcdef");
        n("(?<!xxxxx|abc)def", "abcdef");
        n("(?<!xxxxx|abc)def", "xxxxxxdef");
        n("(?<!x+|abc)def", "abcdef");
        n("(?<!x+|abc)def", "xxxxxxxxxdef");
        x2("(?<!x+|abc)def", "xxxxxxxxzdef", 9, 12);
        n("(?<!a.*z|a)def", "axxxxxxxzdef");
        n("(?<!a.*z|a)def", "bxxxxxxxadef");
        x2("(?<!a.*z|a)def", "axxxxxxxzdefxxdef", 14, 17);
        x2("(?<!a.*z|a)def", "bxxxxxxxadefxxdef", 14, 17);
        x2("(?<!a.*z|a)def", "bxxxxxxxzdef", 9, 12);
        x2("(?<!x+|y+)\\d+", "xxx572", 4, 6);
        x2("(?<!3+|4+)\\d+", "33334444", 0, 8);
        n(".(?<!3+|4+)\\d+", "33334444");
        n("(.{,3})..(?<!\\1)", "aaaaa");
        x2("(.{,3})..(?<!\\1)", "abcde", 0, 5);
        x2("(.{,3})...(?<!\\1)", "abcde", 0, 5);
        x2("(a.c)(.{3,}?)(?<!\\1)", "abcabcd", 0, 7);
        x2("(a*)(.{3,}?)(?<!\\1)", "abcabcd", 0, 5);
        x2("(?:(a.*b)|c.*d)(?<!(?(1))azzzb)", "azzzzb", 0, 6);
        n("(?:(a.*b)|c.*d)(?<!(?(1))azzzb)", "azzzb");
        x2("<(?<!NT{+}abcd)", "<(?<!NT{+}abcd)", 0, 1);
        x2("(?<!a.*c)def", "abbbbdef", 5, 8);
        n("(?<!a.*c)def", "abbbcdef");
        x2("(?<!a.*X\\b)def", "abbbbbXdef", 7, 10);
        n("(?<!a.*X\\B)def", "abbbbbXdef");
        x2("(?<!a.*[uvw])def", "abbbbbXdef", 7, 10);
        n("(?<!a.*[uvw])def", "abbbbbwdef");
        x2("(?<!ab*\\S+)def", "abbbbb   def", 9, 12);
        x2("(?<!a.*\\S)def", "abbbbb def", 7, 10);
        n("(?<!ab*\\s+)def", "abbbbb   def");
        x2("(?<!ab*\\s+\\B)def", "abbbbb   def", 9, 12);
        n("(?<!v|t|a+.*[efg])z", "abcdfz");
        x2("(?<!v|t|a+.*[efg])z", "abcdfzavzuz", 10, 11);
        n("(?<!v|t|^a+.*[efg])z", "abcdfz");
        n("(?<!^(?:v|t|a+.*[efg]))z", "abcdfz");
        x2("(?<!v|^t|^a+.*[efg])z", "uabcdfz", 6, 7);
        n("(\\k<2>)|(?<=(\\k<1>))", "");
        x2("(a|\\k<2>)|(?<=(\\k<1>))", "a", 0, 1);
        x2("(a|\\k<2>)|(?<=b(\\k<1>))", "ba", 1, 2);

        x2("((?(a)\\g<1>|b))", "aab", 0, 3);
        x2("((?(a)\\g<1>))", "aab", 0, 2);
        x2("(b(?(a)|\\g<1>))", "bba", 0, 3);
        x2("(?(a)(?:b|c))", "ac", 0, 2);
        n("^(?(a)b|c)", "ac");
        x2("(?i)a|b", "B", 0, 1);
        n("((?i)a|b.)|c", "C");
        n("c(?i)a.|b.", "Caz");
        x2("c(?i)a|b", "cB", 0, 2); /* == c(?i:a|b) */
        x2("c(?i)a.|b.", "cBb", 0, 3);

        x2("(?i)st", "st", 0, 2);
        x2("(?i)st", "St", 0, 2);
        x2("(?i)st", "sT", 0, 2);
        x2("(?i)st", "ſt", 0, 3); // U+017F
        x2("(?i)st", "ﬅ", 0, 3); // U+FB05
        x2("(?i)st", "ﬆ", 0, 3); // U+FB06
        x2("(?i)ast", "Ast", 0, 3);
        x2("(?i)ast", "ASt", 0, 3);
        x2("(?i)ast", "AsT", 0, 3);
        x2("(?i)ast", "Aſt", 0, 4); // U+017F
        x2("(?i)ast", "Aﬅ", 0, 4); // U+FB05
        x2("(?i)ast", "Aﬆ", 0, 4); // U+FB06
        x2("(?i)stZ", "stz", 0, 3);
        x2("(?i)stZ", "Stz", 0, 3);
        x2("(?i)stZ", "sTz", 0, 3);
        x2("(?i)stZ", "ſtz", 0, 4); // U+017F
        x2("(?i)stZ", "ﬅz", 0, 4); // U+FB05
        x2("(?i)stZ", "ﬆz", 0, 4); // U+FB06
        x2("(?i)BstZ", "bstz", 0, 4);
        x2("(?i)BstZ", "bStz", 0, 4);
        x2("(?i)BstZ", "bsTz", 0, 4);
        x2("(?i)BstZ", "bſtz", 0, 5); // U+017F
        x2("(?i)BstZ", "bﬅz", 0, 5); // U+FB05
        x2("(?i)BstZ", "bﬆz", 0, 5); // U+FB06
        x2("(?i).*st\\z", "tttssssſt", 0, 10); // U+017F
        x2("(?i).*st\\z", "tttssssﬅ", 0, 10); // U+FB05
        x2("(?i).*st\\z", "tttssssﬆ", 0, 10); // U+FB06
        x2("(?i).*あstい\\z", "tttssssあſtい", 0, 16); // U+017F
        x2("(?i).*あstい\\z", "tttssssあﬅい", 0, 16); // U+FB05
        x2("(?i).*あstい\\z", "tttssssあﬆい", 0, 16); // U+FB06
        x2("(?i).*ſt\\z", "tttssssst", 0, 9); // U+017F
        x2("(?i).*ﬅ\\z", "tttssssあst", 0, 12); // U+FB05
        x2("(?i).*ﬆい\\z", "tttssssstい", 0, 12); // U+FB06
        x2("(?i).*ﬅ\\z", "tttssssあﬅ", 0, 13);

        x2("(?i).*ss", "abcdefghijklmnopqrstuvwxyzß", 0, 28); // U+00DF
        x2("(?i).*ss.*", "abcdefghijklmnopqrstuvwxyzßxyz", 0, 31); // U+00DF
        x2("(?i).*ß", "abcdefghijklmnopqrstuvwxyzss", 0, 28); // U+00DF
        x2("(?i).*ss.*", "abcdefghijklmnopqrstuvwxyzSSxyz", 0, 31);

        x2("(?i)ssv", "ßv", 0, 3); // U+00DF
        x2("(?i)(?<=ss)v", "SSv", 2, 3);
        x2("(?i)(?<=ß)v", "ßv", 2, 3);
        // x2("(?i)(?<=ß)v", "ssv", 2, 3);
        // x2("(?i)(?<=ss)v", "ßv", 2, 3);

        /* #156 U+01F0 (UTF-8: C7 B0) */
        x2("(?i).+Isssǰ", ".+Isssǰ", 0, 8);
        x2(".+Isssǰ", ".+Isssǰ", 0, 8);
        x2("(?i)ǰ", "ǰ", 0, 2);
        x2("(?i)5ǰ", "5ǰ", 0, 3);
        x2("(?i)ǰv", "ǰV", 0, 3);
        x2("(?i)[ǰ]", "ǰ", 0, 2);
        x2("(?i:ss)=1234567890", "ſſ=1234567890", 0, 15);
        // swiftlint:enable trailing_semicolon
    }

    func testVersion() {
        XCTAssertEqual(OnigRegularExpression.version, "6.9.6")
    }

    static var allTests = [
        ("testSearch", testSearch),
        ("testSearchEmpty", testSearchEmpty),
        ("testBack", testBack),
        ("testOptions", testOptions),
        ("testUtf8", testUtf8),
        ("testScan", testScan),
        ("testVersion", testVersion),
    ]
}
