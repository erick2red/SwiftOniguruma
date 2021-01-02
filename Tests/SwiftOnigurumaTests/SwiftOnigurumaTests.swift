import XCTest
@testable import SwiftOniguruma

// swiftlint:disable file_length type_body_length
final class SwiftOnigurumaTests: XCTestCase {
    func testSearch() {
        let regex = try? OnigRegularExpression(pattern: "a(.*)b|[e-f]+")
        XCTAssertNotNil(regex)

        let matches = try? regex?.search(in: "zzzzaffffffffb")
        XCTAssertNotNil(matches)
        XCTAssert(matches?.isEmpty == false)
        XCTAssert(matches?.count == 2)
        XCTAssert((matches?[0])! == (4, 14))
        XCTAssert((matches?[1])! == (5, 13))
    }

    func testSearchEmpty() {
        let regex = try? OnigRegularExpression(pattern: "")
        XCTAssertNotNil(regex)

        let matches = try? regex?.search(in: "a", direction: .backward)
        XCTAssertNotNil(matches)
        XCTAssert(matches?.isEmpty == false)
        XCTAssert(matches?.count == 1)
        XCTAssert((matches?[0])! == (1, 1))
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
        // Hint: Copied from test_back.c
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

    func testVersion() {
        XCTAssertEqual(OnigRegularExpression.version, "6.9.6")
    }

    static var allTests = [
        ("testSearch", testSearch),
        ("testSearchEmpty", testSearchEmpty),
        ("testBack", testBack),
        ("testOptions", testOptions),
        ("testScan", testScan),
        ("testVersion", testVersion),
    ]
}
