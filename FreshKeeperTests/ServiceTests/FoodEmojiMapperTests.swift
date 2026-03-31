import Testing
import Foundation
@testable import FreshKeeper

@Suite("FoodEmojiMapper Tests")
struct FoodEmojiMapperTests {

    @Test("Returns correct emoji for known foods")
    func knownFoods() {
        #expect(FoodEmojiMapper.emoji(for: "食パン") == "🍞")
        #expect(FoodEmojiMapper.emoji(for: "牛乳") == "🥛")
        #expect(FoodEmojiMapper.emoji(for: "卵") == "🥚")
        #expect(FoodEmojiMapper.emoji(for: "トマト") == "🍅")
        #expect(FoodEmojiMapper.emoji(for: "チーズ") == "🧀")
    }

    @Test("Returns default emoji for unknown foods")
    func unknownFoods() {
        #expect(FoodEmojiMapper.emoji(for: "不明なもの") == "🍽️")
    }

    @Test("Is case insensitive for English names")
    func caseInsensitive() {
        #expect(FoodEmojiMapper.emoji(for: "Milk") == "🥛")
        #expect(FoodEmojiMapper.emoji(for: "BREAD") == "🍞")
    }
}
