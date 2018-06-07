//A type to hold all the website routes and a route that returns an index template:
import Vapor
import Leaf
import Fluent

// 1. Declare a new WebsiteController type that conforms to RouteCollection.
struct WebsiteController: RouteCollection {
    
    // 2. Implement boot(router:) as required by RouteCollection.
    func boot(router: Router) throws {
        // 3. Register indexHandler(_:) to process GET requests to the router's root path,
        //      i.e, a request to /.
        router.get(use: indexHandler)
        
        //Register the route
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
        //Register the route for /users/<USER ID>, like the API.
        router.get("users", User.parameter, use: userHandler)
        
        //Register the route for /users/, like the API.
        router.get("users",use: allUsersHandler)
        
        //Register a route at /categories that accepts GET requests and calls allCategoriesHandler
        router.get("categories", use: allCategoriesHandler)
        
        //Register a route at /categories/<CATEGORY ID> that accepts GET request and calls categoryHandler(_:)
        router.get("categories", Category.parameter, use: categoryHandler)
     
        //Register a route at /acronyms/create that accepts GET requests and called createAcronymHandler.
        router.get("acronyms", "create", use: createAcronymHandler)
        
        //Register a route at /acronym/create that accepts POST requests and calls createAcronymPostHandler(_:acronym).  This also decodes the request's body to an Acronym.
        //Replaced below.
        //router.post(Acronym.self, at: "acronyms", "create", use: createAcronymPostHandler)
        router.post(CreateAcronymData.self, at: "acronyms", "create", use: createAcronymPostHandler)
        
        //register a route at /acronyms/<ACRONYM ID>/edit to accept GET request that calls
        //      editAcronymHandler(_:)
        router.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
        
        //Register a route to handle POST requests to the same URL that calls editAcronymPostHandler(_:)
        router.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
        
        //Register a route at /acronyms/<ACRONYM ID>/delete to accept POST requests and call
        //      deleteAcronymHandler(_:).
        router.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)
        
        
        
    }
    
    // 4. Implement indexHandler(_:) that returns Future<View>
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        // Use a Fluent query to get all the acronyms from the database.
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            
            // Add the acronym to IndexContext if there are any, otherwise set the variable to nil.
            // This is easier for Leaf to manage than an empty array.
            let acronymsData = acronyms.isEmpty ? nil : acronyms
            let context = IndexContext(title: "Homepage", acronyms: acronymsData)
            
            return try req.view().render("index", context)
        }
    }
    
    // 1. Declare a new route handler, acronymHandler(_:), that returns Future<View>
    func acronymHandler(_ req: Request) throws -> Future<View> {
        // 2. Extract the acronym from the request's parameters and unwrap the result.
        return try req.parameters.next(Acronym.self).flatMap(to: View.self){ acronym in
            // 3. Get the user for acronym and unwrap the result.
            return try acronym.user.get(on: req).flatMap(to: View.self) { user in
                // 4. Create an AcronymContext that contains the appropriate details and render the page using the acronym.leaf template.
                //let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                
                
                //The following passes a Future to Leaf which it handles when required.
                
                let categories = try acronym.categories.query(on: req).all()
                
                let context = AcronymContext(title: acronym.short, acronym: acronym, user: user, categories: categories)
                
                
                return try req.view().render("acronym", context)
            }
        }
    }
    
    //Define the route handler for the user page that returns Future<View>
    func userHandler(_ req: Request) throws -> Future<View> {
        //Get the user from the request's parameters and unwrap the future.
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            //Get the user's acronyms using the computed property and unwrap the future.
            return try user.acronyms.query(on: req).all().flatMap(to: View.self) {
                acronyms in
                //Create a UserContext, then render the user.leaf template, returning the result.
                //In this case, you're not setting the acronyms array to nil if it's empty.
                //This is not required as you're checking the count in template.
                let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                return try req.view().render("user", context)
            }
        }
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        //
        return User.query(on: req).all().flatMap(to: View.self) { users in
            let context = AllUsersContext(title: "All Users", users: users)
            
            return try req.view().render("allUsers", context)
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        // 1. Create an AllCategoriesContext.
        //  Notice that the context includes the query result directly, since Leaf can handle future.
        let categories = Category.query(on: req).all()
        let context = AllCategoriesContext(categories: categories)
        
        // Render the allCategories.leaf template with the provided context.
        return try req.view().render("allCategories", context)
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        //Get the category from the request's parameters and unwrap the returned future.
        return try req.parameters.next(Category.self).flatMap(to: View.self) { category in
            //Create a query to get all the acronyms for the category.
            //This is a Future<[Acronym]>
            let acronyms = try category.acronyms.query(on: req).all()
            //Create a context for the page.
            let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
            //Return a rendered view using the category.leaf template.
            return try req.view().render("category", context)
            
        }
    }
    
    func createAcronymHandler(_ req: Request) throws -> Future<View> {
        // Create a context by passing in a query to get all of the users.
        let context = CreateAcronymContext(users: User.query(on: req).all())
        
        // Render the page using the createAcronym.leaf template.
        return try req.view().render("createAcronym", context)
    }
    
    // Declare a route handler that takes Acronym as a parameter.
    // This will be the form data decoded to an Acronym object. POST
//    func createAcronymPostHandler(_ req: Request, acronym: Acronym) throws -> Future<Response> {
//        // Save the provided acronym and unwrap the returned future.
//        return acronym.save(on: req).map(to: Response.self) { acronym in
//            // Ensure that the ID has been set, otherwise throw a 500 Internal Server Error.
//            guard let id = acronym.id else {
//                throw Abort(.internalServerError)
//            }
//            // Redirect to the page for the newly created acronym.
//            return req.redirect(to: "/acronyms/\(id)")
//
//        }
//    }
    
    
    func editAcronymHandler(_ req: Request) throws -> Future<View> {
        //Get the acronym to edit from the request's parameter and unwrap the future.
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            //Create a context to edit the acronym, passing in all the users.
            //let context = EditAcronymContext(acronym: acronym, users: User.query(on: req).all())
            //^^^ Replaced with...
            let users = User.query(on: req).all()
            let categories = try acronym.categories.query(on: req).all()
            let context = EditAcronymContext(acronym: acronym, users: users, categories: categories)
            
            //Render the page using the createAcronym.leaf template, the same template used for the create page.
            return try req.view().render("createAcronym", context)
            
        }
    }
    
//    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
//        // Use the convenience form of flatMap to get the acronym from the request's parameter
//        //      decode the incoming data and unwrap both results.
//        return try flatMap(to: Response.self,
//                           req.parameters.next(Acronym.self),
//                           req.content.decode(Acronym.self)) {
//
//                            acronym, data in
//                            // Update the acronym with the new data.
//                            acronym.short = data.short
//                            acronym.long = data.long
//                            acronym.userID = data.userID
//                            // Save the result and unwrap the returned future.
//                            return acronym.save(on: req).map(to: Response.self) {
//                                savedAcronym in
//                                //Ensure the ID has been set, otherwise throw 500 internal server error.
//                                guard let id = savedAcronym.id else {
//                                    throw Abort(.internalServerError)
//                                }
//                                //Return a redirect to the updated acronym's page.
//                                return req.redirect(to: "/acronyms/\(id)")
//                            }
//        }
//    }
    
    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        
        // 1. Change the content type the request decodes to CreateAcronymData.
        return try flatMap(to: Response.self, req.parameters.next(Acronym.self), req.content.decode(CreateAcronymData.self)) {
                acronym, data in
                acronym.short = data.short
                acronym.long = data.long
                acronym.userID = data.userID
            
            // 2.Use flatMap(to:) on save(on:) since the closure now returns a future.
            return acronym.save(on: req).flatMap(to: Response.self) {
                savedAcronym in
                guard let id = savedAcronym.id else {
                    throw Abort(.internalServerError)
                }
                
                // 3. Get all categories from the database.
                return try acronym.categories.query(on: req).all().flatMap(to: Response.self) {
                    existingCategories in
                    // 4. Create an array of category names form the categories in the database.
                    let existingStringArray = existingCategories.map { $0.name }
                    
                    // 5. Create a Set for the categories in the database ad anotehr for the categories supplied with the request.
                    let existingSet = Set<String>(existingStringArray)
                    let newSet = Set<String>(data.categories ?? [])
                    
                    // 6. Calculate the categories to add to the acronym and the categories to remove.
                    let categoriesToAdd = newSet.subtracting(existingSet)
                    let categoriesToRemove = existingSet.subtracting(newSet)
                    
                    // 7. Create an array of category operation results.
                    var categoryResults: [Future<Void>] = []
                    
                    // 8. Loop through all the categories to add and call Category.addCategory(_:to:on) to set up the relationship.  Add each result to the results array.
                    for newCategory in categoriesToAdd {
                        categoryResults.append(
                            try Category.addCategory(newCategory, to: acronym, on: req))
                    }
                    // 9. Loop through all the categories to remove from the acronym.
                    for categoryNameToRemove in categoriesToRemove {
                        // 10. Get the Category object form the name of the category to remove.
                        let categoryToRemove = existingCategories.first {
                            $0.name == categoryNameToRemove
                        }
                        // 11. If the Category object exists, find and delete the pivot.
                        if let category = categoryToRemove {
                            categoryResults.append(
                                try AcronymCategoryPivot
                                    .query(on: req)
                                    .filter(\.acronymID == acronym.requireID())
                                    .filter(\.categoryID == category.requireID())
                                    .delete())
                        }
                    }
                    // 12. Flatten all the future category results.
                    //      Tranform the result to redirect to the updated acronym's page.
                    return categoryResults.flatten(on: req).transform(to: req.redirect(to: "/acronyms/\(id)"))
                }
            }
        }
    }
    
    
    
    
    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> {
        /*
         This route extracts the acronym from the request's parameter and calls delete(on:) on the acronym.
         The route then transforms the result to redirect the page to the home screen.
        */
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: req.redirect(to: "/"))
        
    }
    
    // Change the Content type of route handler to accept CreateAcronymData.
    func createAcronymPostHandler(_ req: Request,
                                  data: CreateAcronymData) throws -> Future<Response> {
        
        // Create an Acronym object to save as it's no longer passed into the route.
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        
        // Call flatMap(to:) instead of map(to:) as you now return a Future<Respone> in the closure.
        return acronym.save(on: req).flatMap(to: Response.self) {
            acronym in
            guard let id = acronym.id else {
                throw Abort(.internalServerError)
            }
          
            // Define an array of futures to store the save operations.
            var categorySaves: [Future<Void>] = []
            // Loop through all the categories provided to the request and add the results of
            //      Category.addCategory(_:to:on:) to the array.
            for category in data.categories ?? [] {
                try categorySaves.append(
                    Category.addCategory(category, to: acronym, on: req))
                
            }
        //Flatten the array to complete all the Fluent operations and transform the result to a Response.
        //Redirect the page to the new acronym's page.
        let redirect = req.redirect(to: "/acronyms/\(id)")
        return categorySaves.flatten(on: req).transform(to: redirect)
        
        }
    }
}

//A type to contain the title.
struct IndexContext: Encodable {
    let title: String
    //Optional array of acronyms.
    let acronyms: [Acronym]?
}

//Type to hold the context of the page.
struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
    
    let categories: Future<[Category]>
    
}

//Context for the user page.
struct UserContext: Encodable {
    //Title of the page, which is the user's name
    let title: String
    //User object to which the page refers
    let user: User
    //The acronym created by this user.
    let acronyms: [Acronym]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}

struct AllCategoriesContext: Encodable {
    // 1.Page title for the template.
    let title = "All Categories"
    
    // 2.Future array of categories to display in the page.
    let categories: Future<[Category]>
}

struct CategoryContext: Encodable {
    //Title for the page.
    let title: String
    
    //Category for the page.
    //This isn't Future<Category> since you need the category's name to set the title.
    //This means you'll have to unwrap the future in your route handler.
    let category: Category
    
    //The category's acronyms, provided as a future.
    let acronyms: Future<[Acronym]>
}

struct CreateAcronymContext: Encodable {
    let title = "Create An Acronym"
    let users: Future<[User]>
}

//Context for editing an acronym
struct EditAcronymContext: Encodable {
    //Title for the page
    let title = "Edit Acronym"
    //The acronym to edit
    let acronym: Acronym
    //A future array of users to display in the form.
    let users: Future<[User]>
    //A flag to tell the template that the page is for editing an acronym.
    let editing = true
    
    let categories: Future<[Category]>
    
}

struct CreateAcronymData: Content {
    /*
        This takes the existing information required for an acronym and adds an optional
        array of String to represent the categories.  This allows users to submit existing
        and new categories instead of only existing ones.
    */
    let userID: User.ID
    let short: String
    let long: String
    let categories: [String]?
}

