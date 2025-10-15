//___FILEHEADER___

import SwiftUI
import SwiftData

@main
struct LookAndFeel: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    @StateObject private var navigationState = NavigationState()

    var body: some Scene {
        Window("Look & Feel", id: "main-window") {
            ContentView().environmentObject(navigationState)
        }
        .defaultSize(width: 1000, height: 600)
    }
}
