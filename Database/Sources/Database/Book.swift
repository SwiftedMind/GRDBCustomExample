import Foundation
import GRDB

struct Book: Codable, Sendable, FetchableRecord, MutablePersistableRecord {
  var author: String
  var title: String
  var body: String
}
