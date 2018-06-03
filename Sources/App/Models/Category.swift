import Vapor
import FluentPostgreSQL

final class Category: Codable {
    
    //id to store the ID of the model when it's set.
    var id: Int?
    //name to hold the categories name.
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: PostgreSQLModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}

extension Category {
    //Computed property.
    //This returns Fluent's generic Sibling type.
    //It returns the siblings of a Category tha are of type Acronym and held using the AcronymCategoryPivot.
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
      //Use Fluent's siblings() function to retrieve all the acronyms.
      //Fluent handles everything else.
      return siblings()
    }
}
