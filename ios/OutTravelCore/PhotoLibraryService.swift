import Foundation

public enum PhotoLibraryError: Error {
    case invalidFileName
}

public struct PhotoLibraryService {
    public let baseDirectory: URL

    public init(baseDirectory: URL) {
        self.baseDirectory = baseDirectory
    }

    public func savePhoto(data: Data, suggestedExtension: String = "jpg") throws -> String {
        let ext = suggestedExtension.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ext.isEmpty else { throw PhotoLibraryError.invalidFileName }

        try FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)

        let filename = "photo_\(UUID().uuidString).\(ext)"
        let fileURL = baseDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL, options: .atomic)
        return fileURL.absoluteString
    }

    public func deletePhoto(urlString: String) throws {
        guard let url = URL(string: urlString), url.isFileURL else { return }
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }
}
