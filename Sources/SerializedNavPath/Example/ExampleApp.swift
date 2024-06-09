import SwiftUI

struct LoginView: View {
    
    private let navPath: SerializedNavPath

    init(_ navPath: SerializedNavPath) {
        self.navPath = navPath
    }

    var body: some View {
        VStack {
            Button("Login") {
                let homeRoute = Route(path: "home")
                /// 2. `append`: appends `Route` to `NavigationPath`, and saves it to disk
                navPath.append(homeRoute)
            }.buttonStyle(.borderedProminent)
            Button("Update Path") {
                let pathBinding = navPath.getNavPathForNavigationStack()
                pathBinding.wrappedValue = NavigationPath() // pathBinding is readonly
            }
            Button("Erase Disk Path") {
                navPath.erase() // prints `erased: <filename>` on success
            }
        }
    }
}

struct HomeView: View {
    
    @State private var routeCount: Int = 0
    @State private var routes: [Route] = []
    private let navPath: SerializedNavPath

    init(_ navPath: SerializedNavPath) {
        self.navPath = navPath
    }
    
    var body: some View {
        VStack {
            DetailView(navPath: navPath, routeCount: $routeCount, routes: $routes)
            Button("Other HomeView") {
                let otherRoute = Route(path: "other")
                navPath.append(otherRoute)
            }
            Button("Logout") {
                /// 4. `removeLast`: removes last element from this navigation path
                navPath.removeLast()
            }.buttonStyle(.borderedProminent)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct OtherHomeView: View {
    
    @State private var routeCount: Int = 0
    @State private var routes: [Route] = []
    private let navPath: SerializedNavPath

    init(_ navPath: SerializedNavPath) {
        self.navPath = navPath
    }
    
    var body: some View {
        VStack {
            DetailView(navPath: navPath, routeCount: $routeCount, routes: $routes)
            Button("Back") {
                navPath.removeLast()
            }.buttonStyle(.borderedProminent)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SerializedNavPathExampleApp: View {
    
    private let navPath = SerializedNavPath(filenameWithExtension: SerializedNavPathExampleAppConstants.mainNavPathFilename)

    var title: String {
        navPath.routes.first?.path ?? SerializedNavPathExampleAppConstants.defaultTitle
    }
    
    var body: some View {
        /// 1. `getNavPathForNavigationStack`: returns path of type `Binding<NavigationPath>`
        NavigationStack(path: navPath.getNavPathForNavigationStack()) {
            LoginView(navPath).showTitle(title)
                .navigationDestination(for: Route.self) { route in
                    if route.getPath() == "home" {
                        HomeView(navPath).showTitle(title)
                    } else if route.getPath() == "other" {
                        OtherHomeView(navPath).showTitle(title)
                    } else {
                        LoginView(navPath).showTitle(title)
                    }
                }
        }
        .onAppear {
            SerializedNavPath.debug = true
        }
    }
}

struct SerializedNavPathExampleAppConstants {
    
    static let mainNavPathFilename = "MainNavPath.json"
    static let defaultTitle = "default"
}

struct Example_Preview: PreviewProvider {
    
    static var previews: some View {
        SerializedNavPathExampleApp()
    }
}

extension View {
    
    func showTitle(_ title: String) -> some View {
        self.navigationTitle(title).navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder func DetailView(navPath: SerializedNavPath, routeCount: Binding<Int>, routes: Binding<[Route]>) -> some View {
        HStack {
            Text("Count: \(routeCount.wrappedValue)")
            Text("Routes: \(routes.wrappedValue.map{$0.path}.joined(separator: ","))")
        }.border(Color.blue)
        HStack {
            Button("Count") {
                /// 3. `count`: number of elements in this navigation path
                routeCount.wrappedValue = navPath.count
            }
            Button("Routes") {
                routes.wrappedValue = navPath.routes
            }
        }.border(Color.blue)
    }
}
