import SwiftUI

struct FoodCardView: View {
    let item: FoodItem
    let onConsume: () -> Void
    let onDiscard: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showingDetail = false

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        ZStack {
            // Swipe background
            HStack {
                // Right swipe = discard
                HStack {
                    Image(systemName: "trash.fill")
                    Text(String(localized: "action.discard"))
                }
                .foregroundStyle(.white)
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red)

                // Left swipe = consume
                HStack {
                    Text(String(localized: "action.consume"))
                    Image(systemName: "checkmark.circle.fill")
                }
                .foregroundStyle(.white)
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(Color.green)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Card content
            cardContent
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation.width
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                if value.translation.width < -swipeThreshold {
                                    // Left swipe → consume
                                    offset = -500
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onConsume()
                                    }
                                } else if value.translation.width > swipeThreshold {
                                    // Right swipe → discard
                                    offset = 500
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onDiscard()
                                    }
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .sheet(isPresented: $showingDetail) {
            FoodDetailView(item: item)
        }
    }

    private var cardContent: some View {
        HStack {
            Text(item.displayEmoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Label(item.storageLocation.displayName, systemImage: item.storageLocation.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("〜 \(item.expiryDate.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(item.expiryStatus.remainingText(item.daysUntilExpiry))
                    .font(.subheadline.bold())
                    .foregroundStyle(item.expiryStatus.color)
            }
        }
        .padding()
        .background(item.expiryStatus.backgroundColor)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .onTapGesture {
            showingDetail = true
        }
    }
}
