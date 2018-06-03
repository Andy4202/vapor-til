import Vapor



struct CategoriesController: RouteCollection {
    // Implement boot(router:) as required by RouteCollection.
    //   This is where you register route handlers/
    func boot(router: Router) throws {
        // Create a new route group for the path /api/categories.
        let categoriesRoute = router.grouped("api", "categories")
        // Register the route handlers to their routes.
        categoriesRoute.post(Category.self, use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
        //This routes an HTTP GET request to /api/categories/<CATEGORY_ID>/acronyms to
        //      getAcronymsHandler(_:)
        categoriesRoute.get(Category.parameter, "acronyms", use: getAcronymsHandler)
        
    }
    
    // Create a category
    func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
         // Save the decoded category from the request.
        return category.save(on: req)
    }
    // Returns all categories.
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
         // Perform  a Fluent query to retrieve all the categories from the database.
        return Category.query(on: req).all()
    }
    // Returns a single category
    func getHandler(_ req: Request) throws -> Future<Category> {
         // Return the category extracted from the request's parameters.
        return try req.parameters.next(Category.self)
    }
    
   //New route handler, getAcronymsHandler, that returns Future<[Acronym]>
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        //Extract the category from the request's parameters and unwrap the returned future.
        return try req.parameters.next(Category.self).flatMap(to: [Acronym].self) { category in
            //Use the new computed property to get the acronyms.
            //Then use a Fluent query to return all the acronyms.
            try category.acronyms.query(on: req).all()
        }
    }
}
