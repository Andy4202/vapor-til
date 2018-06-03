import FluentPostgreSQL
import Foundation


//Define a new object AcronymCategoryPivot that conforms to PostgreSQLUUIDPivot.
final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
    
    //id for the model.
    //Note, this is a UUID type so you must import the Foundation module in the file.
    var id: UUID?
    
    //Properties to link to the IDs of Acronym and Category.
    //This is what holds the relationship.
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    //Left and Right types required by Pivot.
    //This tells Fluent that the two models in the relationship are.
    typealias Left = Acronym
    typealias Right = Category
    
    //Tell Fluent the key path of the two ID properties for each side of the relationship.
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

//Conform to Migration so Fluent can set up the table.
extension AcronymCategoryPivot: Migration {
    
    // Implement prepare(on:) as defined by Migration.
    //  This overrides the default implementation.
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        //Create the table for AcronymCategoryPivot in the database.
        return Database.create(self, on: connection) { builder in
            //Use addProperties(to:) to add all the fields to the database.
            try addProperties(to: builder)
            //Add a reference between the acronymID property on AcronymCategoryPivot and the id property on Acronym.  This sets up the foreign key constraint.
            try builder.addReference(from: \.acronymID, to: \Acronym.id)
            //Add a reference between the categoryID property on AcronymCategoryPivot and the id property on Category.  This set up the foreign key constraint.
            try builder.addReference(from: \.categoryID, to: \Category.id)
        }
    }
}
