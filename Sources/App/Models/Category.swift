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
    
    static func addCategory(_ name: String, to acronym: Acronym, on req: Request) throws -> Future<Void> {
        
        // 1. Perform a query to search for a category with the provided name.
        return try Category.query(on: req).filter(\.name == name).first().flatMap(to: Void.self) {
            foundCategory in
            if let existingCategory = foundCategory {
                // 2. If the category exists, create a pivot with the category and acronym.
                let pivot = try AcronymCategoryPivot(acronym.requireID(),
                                                    existingCategory.requireID())
                // 3. Save the new pivot and transform the result to Void.
                // () is shorthand for Void().
                return pivot.save(on: req).transform(to: ())
            } else {
                // 4. If the category doesn't exist, create a new Category object with the provided name.
                let category = Category(name: name)
                // 5. Save the new category and unwrap the returned future.
                return category.save(on: req).flatMap(to: Void.self) { savedCategory in
                    // 6. Create a pivot with the new category and provided acronym.
                    let pivot = try AcronymCategoryPivot(acronym.requireID(),
                    savedCategory.requireID())
                    // 7. Save the new pivot and tranform the result to Void.
                    return pivot.save(on: req).transform(to: ())
                    
                }
            }
        }
    }
}
