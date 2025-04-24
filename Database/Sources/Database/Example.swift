// The Swift Programming Language
// https://docs.swift.org/swift-book

import GRDB

public func performExample() async throws {
  let database = AppDatabase.shared

//  let book = try await database.dbWriter.write { db in
//    try Book(author: "Author", title: "Moby-Dick", body: "Body").inserted(db)
//  }
//
//  let pattern = FTS5Pattern(matchingPhrase: "Moby-Dick")
//
//  let books = try await database.reader.read { db in
//    try Book.matching(pattern).fetchAll(db)
//  }

  try await database.dbWriter.write { db in
//    try db.execute(
//      sql: """
//        insert into vec_examples(rowid, sample_embedding)
//        values
//        (1, '[-0.200, 0.250, 0.341, -0.211, 0.645, 0.935, -0.316, -0.924]'),
//        (2, '[0.443, -0.501, 0.355, -0.771, 0.707, -0.708, -0.185, 0.362]'),
//        (3, '[0.716, -0.927, 0.134, 0.052, -0.669, 0.793, -0.634, -0.162]'),
//        (4, '[-0.710, 0.330, 0.656, 0.041, -0.990, 0.726, 0.385, -0.958]');
//        """
//    )
    
    let result = try Row.fetchAll(db, sql: """
      select rowid, distance from vec_examples
        where sample_embedding match '[0.890, 0.544, 0.825, 0.961, 0.358, 0.0196, 0.521, 0.175]'
        order by distance
        limit 2;
      """)
    
    print(result)
  }

//  print(books)
}
