import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let emoji: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(id: 0, emoji: "🥬", title: "onboarding.page1.title", description: "onboarding.page1.description"),
        OnboardingPage(id: 1, emoji: "📷", title: "onboarding.page2.title", description: "onboarding.page2.description"),
        OnboardingPage(id: 2, emoji: "🔔", title: "onboarding.page3.title", description: "onboarding.page3.description"),
        OnboardingPage(id: 3, emoji: "📊", title: "onboarding.page4.title", description: "onboarding.page4.description"),
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pages) { page in
                    VStack(spacing: 24) {
                        Spacer()

                        Text(page.emoji)
                            .font(.system(size: 100))

                        Text(page.title)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer()
                    }
                    .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            if currentPage == pages.count - 1 {
                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("onboarding.start")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            } else {
                Button {
                    withAnimation {
                        currentPage += 1
                    }
                } label: {
                    Text("onboarding.next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
