import Foundation
import GRDB
import OSLog

struct AppDatabase {
  /// Creates an `AppDatabase`, and makes sure the database schema
  /// is ready.
  ///
  /// - important: Create the `DatabaseWriter` with a configuration
  ///   returned by ``makeConfiguration(_:)``.
  init(_ dbWriter: any DatabaseWriter) throws {
    self.dbWriter = dbWriter
    try migrator.migrate(dbWriter)
  }

  let dbWriter: any DatabaseWriter
}

// MARK: - Database Configuration

extension AppDatabase {
  private static let sqlLogger = Logger(subsystem: "Example", category: "SQL")

  public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
    var config = base

    if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
      config.prepareDatabase { db in
        db.trace {
          sqlLogger.debug("\(String(describing: $0), privacy: .public)")
        }
      }
    }

    #if DEBUG
      config.publicStatementArguments = true
    #endif

    return config
  }
}

// MARK: - Database Migrations

extension AppDatabase {
  /// The DatabaseMigrator that defines the database schema.
  ///
  /// See https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations
  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    #if DEBUG
      migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigration("v0") { db in
      try db.create(virtualTable: "book", using: FTS5()) { t in
        t.column("author")
        t.column("title")
        t.column("body")
      }
    }

    return migrator
  }
}

extension AppDatabase {
  /// Provides a read-only access to the database
  var reader: DatabaseReader {
    dbWriter
  }
}
