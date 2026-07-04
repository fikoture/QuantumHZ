import Foundation

enum AudioResourceLocator {
    private static let knownSubdirectories = ["Musics", "Musics/Frequencies", "Frequencies"]

    static func url(forResource name: String, withExtension ext: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url
        }

        for subdirectory in knownSubdirectories {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subdirectory) {
                return url
            }
        }

        return Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil)?
            .first { $0.deletingPathExtension().lastPathComponent == name }
    }
}
