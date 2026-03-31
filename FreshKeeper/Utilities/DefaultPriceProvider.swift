import Foundation

enum DefaultPriceProvider {
    private static let categoryPrices: [(keywords: [String], price: Int)] = [
        (["牛乳", "ヨーグルト", "チーズ", "バター", "milk", "yogurt", "cheese", "butter"], 200),
        (["パン", "食パン", "bread"], 150),
        (["肉", "鶏", "豚", "牛", "ハム", "ベーコン", "meat", "chicken", "pork", "beef", "ham", "bacon"], 400),
        (["野菜", "キャベツ", "レタス", "トマト", "きゅうり", "vegetable", "cabbage", "tomato"], 150),
        (["醤油", "味噌", "塩", "砂糖", "酢", "sauce", "soy", "miso", "salt", "sugar"], 300),
    ]

    static func defaultPrice(for name: String) -> Int {
        let lowered = name.lowercased()
        for category in categoryPrices {
            if category.keywords.contains(where: { lowered.contains($0.lowercased()) }) {
                return category.price
            }
        }
        return 200
    }
}
