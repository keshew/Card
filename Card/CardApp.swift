import SwiftUI

@main
struct CardApp: App {
    var body: some Scene {
        WindowGroup {
            CardMenuView()
                .onAppear {
                    UserDefaultsManager().firstLaunch()
                }
        }
    }
}
