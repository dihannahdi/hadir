import SwiftUI

// MARK: - Content View
// Root navigation — switches between screens based on AppCoordinator state

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        ZStack {
            HadirTheme.cream
                .ignoresSafeArea()
            
            switch coordinator.currentScreen {
            case .onboarding:
                OnboardingView(coordinator: coordinator)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                
            case .home:
                HomeView(coordinator: coordinator)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
            case .consultation:
                ConsultationView(coordinator: coordinator)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                
            case .soapReview:
                SOAPReviewView(coordinator: coordinator)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                
            case .summary:
                SummaryView(coordinator: coordinator)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: coordinator.currentScreen)
        .preferredColorScheme(.light)
    }
}
