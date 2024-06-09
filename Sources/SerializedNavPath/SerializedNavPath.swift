import SwiftUI
import Observation

@Observable
public class SerializedNavPath {
    /// Util to store `NavigationPath` to disk for persistence between app launches. Initial route itself is not saved.
    /// Persistence comes into play when a path is appended using `path.append`. For e.g. if a `NavigationStack`
    /// allows, say, `Login` and `Home` destinations, and it defaults to `Login`, then appending `Home` to path will
    /// create a persisted representation with just `Home`. This representation is understood by util using `getRoutes`
    /// and of course, natively by `NavigationPath`, as this util wraps around native representation.
    
    struct NavigationPathRawStringCodable: Codable {
        let data: [String]
    }
    
    public static var debug: Bool = true {
        didSet {
            SerializedNavPathLib.debug = debug
        }
    }
    
    private var path: NavigationPath
    private let _filenameWithExtension: String
    private let navPathLib: SerializedNavPathLib
    
    private var pathBinding: Binding<NavigationPath> {
        Binding(
            get: { self.path },
            set: { _ in print(SerializedNavPathConstants.logReadOnly) }
        )
    }
    
    public init(filenameWithExtension: String, createNew: Bool = false) {
        /// reads navigation-path data from disk and uses this data to setup itself
        /// or, creates a new instance if there is no data
        var newNavPathLib = SerializedNavPathLib()
        
        var readError = false
        if createNew {
            self.path = NavigationPath()
            /// call is made to properly define `_filenameWithExtension`, and we don't need return value
            newNavPathLib.readSerializedData(filenameWithExtension: filenameWithExtension)
        } else {
            /// `readSerializedData` will update/create the `struct newNavPathLib` with `filenameWithExtension`
            if let data = newNavPathLib.readSerializedData(filenameWithExtension: filenameWithExtension) {
                do {
                    let representation = try JSONDecoder().decode(
                        NavigationPath.CodableRepresentation.self,
                        from: data)
                    self.path = NavigationPath(representation)
                } catch {
                    readError = true
                    self.path = NavigationPath()
                }
            } else {
                readError = true
                self.path = NavigationPath()
            }
        }
        self._filenameWithExtension = filenameWithExtension
        self.navPathLib = newNavPathLib
        if createNew || readError {
            self.erase()
        }
    }
    
    // MARK: Routing Utils
    public func getNavPathForNavigationStack() -> Binding<NavigationPath> {
        return pathBinding
    }
    
    public func append(_ route: Route) {
        path.append(route)
        save()
    }
    
    public func removeLast() {
        if getCount() > 0 {
            path.removeLast()
            save()
        }
    }
    
    private func getCount() -> Int {
        return path.count
    }
    
    private func getRoutes() -> [Route]? {
        /// - Converts `NavigationPath.codable` which contains data appended using
        /// - `NavigationPath.append(Route(path: "routeName"))` to `NavigationPathRawStringCodable`
        /// - And then, filters the data by a given `keyPath` aka `propertyString`
        /// - Finally, after decoding the filtered data using (custom) type `Route`, returns its collection
        let propertyString = NSExpression(forKeyPath: \Route.path).keyPath // or simply `path` in this case
        guard let encodedData = try? JSONEncoder().encode(path.codable) else {
            return nil
        }
        /// - Extra steps are performed to map the following string in `NavigationPath.codable`
        /// - E.g. `["DataVid.Route","{\"path\":\"path2\"}","DataVid.Route","{\"path\":\"path1\"}"]`
        /// - To a custom type `NavigationPathRawStringCodable`
        /// - E.g. `NavigationPathRawStringCodable(data: ["DataVid.Route", "{\"path\":\"VIDEOS\"}", "DataVid.Route", "{\"path\":\"DISCOVER\"}"])`
        /// - In the above example, the first item in `data` is the one that has been appended most recently onto the `NavigationPath`
        guard let jsonStringData = "{\"data\":\(String(decoding: encodedData, as: UTF8.self))}".data(using: .utf8),
              let navPathStringCodable = try? JSONDecoder().decode(NavigationPathRawStringCodable.self, from: jsonStringData) else {
            return nil
        }
        
        let routes = navPathStringCodable.data
            .filter { $0.contains(propertyString) }
            .compactMap { $0.data(using: .utf8) }
            .compactMap { try? JSONDecoder().decode(Route.self, from: $0) }
        return routes
    }
    
    // MARK: Routing Utils (Properties)
    public var count: Int {
        getCount()
    }
    
    public var routes: [Route] {
        getRoutes() ?? []
    }
    
    // MARK: Disk Utils
    public func save() {
        guard let representation = path.codable else { return }
        do {
            let data = try JSONEncoder().encode(representation)
            if !navPathLib.writeSerializedData(data) {
                navPathLib.log(SerializedNavPathConstants.errorSavePath)
            }
        } catch {
            navPathLib.log(SerializedNavPathConstants.errorEncoding)
        }
    }
    
    public func erase() {
        navPathLib.eraseSerializedData()
    }
}

public class Route: Hashable, Codable {
    
    @objc let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    public func getPath() -> String {
        return path
    }

    public static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.path == rhs.path
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}
