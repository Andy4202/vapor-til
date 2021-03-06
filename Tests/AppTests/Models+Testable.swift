@testable import App
import FluentPostgreSQL

extension User {
    
    /*
    This function saves a user, created with the supplied details, in the database.
    It has default values so you don't have to provide any if you don't care about them.
    */
    static func create(name: String = "Luke",
                       username: String = "lukes",
                       on connection: PostgreSQLConnection) throws -> User {
        let user = User(name: name, username: username)
        return try user.save(on: connection).wait()
    }
}

extension Acronym {
    
    //Test to create an acronym and saves it to the database.
    //If you don't provide any values, it uses defaults.
    //If you don't provide a user for the acronym, it creates a user to use first.
    static func create(short: String = "TIL", long: String = "Today I Learned", user: User? = nil,
                       on connection: PostgreSQLConnection) throws -> Acronym {
       
        var acronymsUser = user
        
        if acronymsUser == nil {
            
            acronymsUser = try User.create(on: connection)
        }
        
        let acronym = Acronym(short: short, long: long, userID: acronymsUser!.id!)
        
        return try acronym.save(on: connection).wait()
    }
}

extension App.Category {
    
    //create(name: on: ) takes the name as the parameter and creates a category in the database.
    static func create(name: String = "Random", on connection: PostgreSQLConnection) throws -> App.Category {
        
        let category = Category(name: name)
        return try category.save(on: connection).wait()
    }
}

