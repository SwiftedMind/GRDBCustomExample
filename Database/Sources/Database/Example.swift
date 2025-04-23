// The Swift Programming Language
// https://docs.swift.org/swift-book

import GRDB

public func performExample() async throws {
  let database = AppDatabase.shared
   
  let book = try await database.dbWriter.write { db in
    try Book(author: "Author", title: "Moby-Dick", body: "Body").inserted(db)
  }
  
  let pattern = FTS5Pattern(matchingPhrase: "Moby-Dick")
  
  let books = try await database.reader.read { db in
    try Book.matching(pattern).fetchAll(db)
  }
  
  print(books)
}
