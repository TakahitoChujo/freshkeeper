import Foundation

enum FoodEmojiMapper {
    private static let emojiMap: [(keywords: [String], emoji: String)] = [
        (["パン", "食パン", "bread"], "🍞"),
        (["牛乳", "ミルク", "milk"], "🥛"),
        (["卵", "たまご", "egg"], "🥚"),
        (["肉", "牛肉", "beef", "steak"], "🥩"),
        (["鶏", "チキン", "chicken"], "🍗"),
        (["豚", "pork"], "🥓"),
        (["魚", "さかな", "fish", "サーモン", "salmon"], "🐟"),
        (["りんご", "リンゴ", "apple"], "🍎"),
        (["バナナ", "banana"], "🍌"),
        (["トマト", "tomato"], "🍅"),
        (["キャベツ", "レタス", "cabbage", "lettuce"], "🥬"),
        (["にんじん", "carrot"], "🥕"),
        (["チーズ", "cheese"], "🧀"),
        (["ヨーグルト", "yogurt"], "🫙"),
        (["豆腐", "tofu"], "🫘"),
        (["米", "ごはん", "rice"], "🍚"),
        (["納豆", "natto"], "🫘"),
        (["ビール", "beer"], "🍺"),
        (["ジュース", "juice"], "🧃"),
        (["ケーキ", "cake"], "🍰"),
        (["アイス", "ice cream"], "🍨"),
    ]

    static func emoji(for name: String) -> String {
        let lowered = name.lowercased()
        for item in emojiMap {
            if item.keywords.contains(where: { lowered.contains($0.lowercased()) }) {
                return item.emoji
            }
        }
        return "🍽️"
    }
}
