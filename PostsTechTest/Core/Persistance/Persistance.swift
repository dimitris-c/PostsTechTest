import Foundation

protocol PersistanceDecodable {
    func decode<T: Decodable>(_ type: T.Type, data: Data) -> T?
    func encode<T: Encodable>(object: T) -> Data?
}

protocol Persistance: PersistanceDecodable {
    func save(value: Data, key: String)
    func get(key: String) -> Data?
}

final class PersistanceService: Persistance {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func get(key: String) -> Data? {
        return getFromDisk(key: key)
    }
    
    func save(value: Data, key: String) {
        self.storeToDisk(value: value, key: key)
    }
    
    // MARK: Private
    
    private func storeToDisk(value: Data, key: String) {
        do {
            guard let documents = self.documentsFolderURL() else {
                print("couldn't get documents folder")
                return
            }

            let fileName = documents.appendingPathComponent("\(key).data")
            try value.write(to: fileName, options: .atomic)
        }
        catch {
            print("couldn't create file")
        }
    }
    
    private func getFromDisk(key: String) -> Data? {
        guard let documents = self.documentsFolderURL() else {
            print("couldn't get documents folder")
            return nil
        }
        
        let filePath = documents.appendingPathComponent("\(key).data").absoluteURL
        return try? Data(contentsOf: filePath)
    }
    
    private func documentsFolderURL() -> URL? {
        return self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
}

extension PersistanceService {
    func decode<T: Decodable>(_ type: T.Type, data: Data) -> T? {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func encode<T: Encodable>(object: T) -> Data? {
        do {
            return try JSONEncoder().encode(object)
        } catch let error {
            print(error)
            return nil
        }
    }
}
