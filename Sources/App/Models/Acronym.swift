import Vapor
import FluentSQLite

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

//Make Acronym conform to Fluent's Model.
//extension Acronym: Model {
//
//
//    // 1. Tell Fluent what database to use for this model.
//    //     The template is already configured to use SQLite.
//    typealias Database = SQLiteDatabase
//
//    // 2. Tell Fluent what type the ID is.
//    typealias ID = Int
//
//    // 3. Tell Fluent the key path of the model's ID property.
//    public static var idKey: IDKey = \Acronym.id
//
//}

//The above extension can be improved with:

extension Acronym: SQLiteModel {}

extension Acronym: Migration {}

//Vapor provides Content, a wrapper around Codable, which allows you to convert models and other data between various formats.
extension Acronym: Content {}
