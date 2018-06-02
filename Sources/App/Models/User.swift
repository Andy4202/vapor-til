import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    
    //Since the ID is a UUID type, you must import Foundation
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}


//Make the User model conform to Fluent's Model by adding the following:
extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}


extension User {

    //Getting the children...
    //Add a computed property to User to get a user's acronyms.
    // ** This returns Fluent's generic Children type. **
    var acronyms: Children<User, Acronym> {
        //Uses Fluent's children(_:) function to retrieve the children.
        //This takes the key path of the user reference on the acronym.
        return children(\.userID)
    }
}
