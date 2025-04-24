import Foundation
import GRDB

extension AppDatabase {
  /// The database for the application
  static let shared = makeShared()

  private static func makeShared() -> AppDatabase {
    do {
      core_vec_init()
      let fileManager = FileManager.default
      let appSupportURL = try fileManager.url(
        for: .applicationSupportDirectory, in: .userDomainMask,
        appropriateFor: nil, create: true
      )
      let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)

      
      // Create the database folder if needed
      try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

      // Open or create the database
      let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
      let dbPool = try DatabasePool(
        path: databaseURL.path,
        // Use default AppDatabase configuration
        configuration: AppDatabase.makeConfiguration()
      )

      print(databaseURL.absoluteString)
      // Create the AppDatabase
      let appDatabase = try AppDatabase(dbPool)

      return appDatabase
    } catch {
      fatalError("Critical error: \(error)")
    }
  }
}
