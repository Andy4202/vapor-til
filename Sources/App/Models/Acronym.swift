import Vapor
//import FluentSQLite
import FluentPostgreSQL
//import FluentMySQL

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    //This is a typealias defined by PostgreSQLUUIDModel, which resolves to UUID.
    var userID: User.ID
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
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

//extension Acronym: SQLiteModel {}
extension Acronym: PostgreSQLModel {}
//extension Acronym: MySQLModel {}

//extension Acronym: Migration {}

//Conform Acronym to Migration
extension Acronym: Migration {
    //Implement prepare(on:) as required by Migration.  This overrides the default implementation.
    //Create the table for Acronym in the database.
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            //Use addProperties(to:) to add all the fields to the database.
            //This means you don't need to add each column manually.
            try addProperties(to: builder)
        
            //Add a reference between the userID property on Acronym and the id property on User.
            //This sets up the foreign key constraint between the two tables.
            try builder.addReference(from: \.userID, to: \User.id)
        
        }
    }
}


//Vapor provides Content, a wrapper around Codable, which allows you to convert models and other data between various formats.
extension Acronym: Content {}

extension Acronym: Parameter {}

extension Acronym {
    //Add a computed property to Acronym to get the User object of the acronym's owner
    //This returns Fluent's generic Parent type.
    var user: Parent<Acronym, User> {
        //Uses Fluent's parent(_:) function to retrieve the parent.  This takes the key path of the user
        //reference on the acronym.
        return parent(\.userID)
    }
    
    
    //Add a computed property to Acronym to get an acronym's categories.
    //This returns Fluent's generic Sibling type.
    //It returns the sibling of an Acronym that are of type Category and held using the AcronymCategoryPivot.
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        //Use Fluent's siblings() function to retrieve all the categories. Fluent handles everything else.
        return siblings()
    }
    
}
