//
//  String+Chosung.swift
//  Bowl
//
//  Korean initial-consonant (초성) helpers for chosung search — e.g. typing
//  "ㅁ" matches "메인쿤".
//

import Foundation

extension String {

    /// The 19 Hangul initial consonants, in Unicode order.
    private static let chosungTable: [Character] = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]

    /// Decomposes complete Hangul syllables into their initial consonants.
    /// e.g. "메인쿤" → "ㅁㅇㅋ", "코리안 숏헤어" → "ㅋㄹㅇㅅㅎㅇ".
    /// Non-syllable characters (spaces, punctuation) are dropped.
    func toChosung() -> String {
        var result = ""
        for scalar in unicodeScalars {
            // Hangul syllables block: 가(0xAC00) … 힣(0xD7A3).
            guard (0xAC00...0xD7A3).contains(scalar.value) else { continue }
            let index = Int((scalar.value - 0xAC00) / 588) // 588 = 21 vowels × 28 finals
            result.append(Self.chosungTable[index])
        }
        return result
    }

    /// Whether every character is a standalone Hangul consonant jamo (ㄱ–ㅎ),
    /// i.e. a chosung-only query such as "ㅁ" or "ㅋㄹ".
    var isChosungOnly: Bool {
        guard !isEmpty else { return false }
        // Compatibility-jamo consonants span ㄱ(0x3131) … ㅎ(0x314E);
        // vowels begin at ㅏ(0x314F).
        return unicodeScalars.allSatisfy { (0x3131...0x314E).contains($0.value) }
    }
}
