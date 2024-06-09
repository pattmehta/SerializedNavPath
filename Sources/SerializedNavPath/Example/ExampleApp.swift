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
                /// 2. `append`: appends `Route` to `NavigationPath`, and saves it to disk
                navPath.append(homeRoute)
            }
            Button("Update Path") {
                print("update path binding")
                let pathBinding = navPath.getNavPathForNavigationStack()
                pathBinding.wrappedValue = NavigationPath() // pathBinding is readonly
            }
            Button("Erase Disk Path") {
                print("erase serialized data")
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
            Text("Home View")
            Spacer()
            Text("Count: \(routeCount)")
            Text("Routes: \(routes.map{$0.path}.joined(separator: ","))")
            Button("Get Count") {
                /// 3. `getCount`: number of elements in this navigation path
                routeCount = navPath.getCount()
            }
            Button("Logout") {
                /// 4. `removeLast`: removes last element from this navigation path
                navPath.removeLast()
            }
            Button("Other HomeView") {
                let otherRoute = Route(path: "other")
                navPath.append(otherRoute)
            }
            Button("Get Routes") {
                if let allRoutes = navPath.getRoutes() {
                    routes = allRoutes
                }
            }
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
            Text("Other HomeView")
            Spacer()
            Text("Count: \(routeCount)")
            Text("Routes: \(routes.map{$0.path}.joined(separator: ","))")
            Button("Get Count") {
                routeCount = navPath.getCount()
            }
            Button("Get Routes") {
                if let allRoutes = navPath.getRoutes() {
                    routes = allRoutes
                }
            }
            Button("Back") {
                navPath.removeLast()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

let firstExampleFilename = "firstExampleFilename.json"
let secondExampleFilename = "secondExampleFilename.json"

struct SerializedNavPathExampleApp: View {
    
    private let navPath = SerializedNavPath(filenameWithExtension: secondExampleFilename)

    var body: some View {
        /// 1. `getNavPathForNavigationStack`: returns path of type `Binding<NavigationPath>`
        NavigationStack(path: navPath.getNavPathForNavigationStack()) {
            LoginView(navPath)
                .navigationDestination(for: Route.self) { route in
                    if route.getPath() == "home" {
                        HomeView(navPath)
                    } else if route.getPath() == "other" {
                        OtherHomeView(navPath)
                    } else {
                        LoginView(navPath)
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
