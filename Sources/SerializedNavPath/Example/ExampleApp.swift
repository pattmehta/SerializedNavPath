import SwiftUI

struct LoginView: View {
    
    private let navPath: SerializedNavPath

    init(_ navPath: SerializedNavPath) {
        self.navPath = navPath
    }

    var body: some View {
        Text("Login View")
        Spacer()
        VStack {
            Button("Login") {
                let homeRoute = Route(path: "home")
                navPath.append(homeRoute)
            }
            Button("Update Path") {
                print("update path binding")
                let pathBinding = navPath.getNavPathForNavigationStack()
                pathBinding.wrappedValue = NavigationPath() // pathBinding is readonly
            }
        }
    }
}

struct HomeView: View {
    
    private let navPath: SerializedNavPath

    init(_ navPath: SerializedNavPath) {
        self.navPath = navPath
    }
    
    var body: some View {
        VStack {
            Text("Home View")
            Spacer()
            Button("Logout") {
                navPath.removeLast()
            }
        }
    }
}

struct SerializedNavPathExampleApp: View {
    
    private let navPath = SerializedNavPath()

    var body: some View {
        NavigationStack(navigationPath: navPath.getNavPathForNavigationStack()) {
            LoginView()
                .navigationDestination(for: Route.self) { route in
                    if route.getPath() == "home" {
                        HomeView()
                    } else {
                        LoginView()
                    }
                }
        }
    }
}

struct SerializedNavPathExampleAppConstants {
    
}

struct Example_Preview: PreviewProvider {
    
    static var previews: some View {
        SerializedNavPathExampleApp()
    }
}
