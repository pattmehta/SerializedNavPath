import Foundation

struct SerializedNavPathLib {
    /// Usage requires immediate reading of data from path
    /// Therefore, property setup happens after a successful read
    /// Initial value for the property is nil
    
    private var _filenameWithExtension: String?
    
    init(filenameWithExtension: String? = nil) {
        self._filenameWithExtension = filenameWithExtension
    }
    
    fileprivate func getDocumentsDirectory() -> URL? {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return path
    }
    
    fileprivate func getFileUrl(_ filenameWithExtension: String? = nil) -> URL? {
        guard let documentsDirectory = getDocumentsDirectory() else {
            return nil
        }
        if let filenameWithExtension = filenameWithExtension {
            return documentsDirectory.appendingPathComponent(filenameWithExtension)
        }
        if let filenameWithExtension = _filenameWithExtension {
            return documentsDirectory.appendingPathComponent(filenameWithExtension)
        }
        return nil
    }
    
    mutating func readSerializedData(filenameWithExtension: String? = nil) -> Data? {
        if let filenameWithExtension = filenameWithExtension {
            _filenameWithExtension = filenameWithExtension
            guard let fileUrl = getFileUrl(filenameWithExtension), let data = try? Data(contentsOf: fileUrl) else {
                return nil
            }
            return data
        }
        if let filenameWithExtension = _filenameWithExtension {
            guard let fileUrl = getFileUrl(filenameWithExtension), let data = try? Data(contentsOf: fileUrl) else {
                return nil
            }
            return data
        }
        return nil
    }
    
    func writeSerializedData(_ data: Data) -> Bool {
        guard let fileUrl = getFileUrl() else {
            log("could not find")
            return false
        }
        try! data.write(to: fileUrl)
        log("data written")
        return true
    }
    
    func eraseSerializedData() {
        guard let fileUrl = getFileUrl() else {
            log("could not find")
            return
        }
        guard let _ = try? FileManager.default.removeItem(at: fileUrl) else {
            log("could not erase")
            return
        }
        log("erased")
    }
}

extension SerializedNavPathLib {
    
    fileprivate func log(_ message: String) {
        if let filenameWithExtension = _filenameWithExtension {
            print("\(message): \(filenameWithExtension)")
        }
    }
}
