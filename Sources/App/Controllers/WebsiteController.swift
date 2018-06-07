//A type to hold all the website routes and a route that returns an index template:
import Vapor
import Leaf

// 1. Declare a new WebsiteController type that conforms to RouteCollection.
struct WebsiteController: RouteCollection {
    
    // 2. Implement boot(router:) as required by RouteCollection.
    func boot(router: Router) throws {
        // 3. Register indexHandler(_:) to process GET requests to the router's root path,
        //      i.e, a request to /.
        router.get(use: indexHandler)
        
        //Register the route
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
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
                let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                return try req.view().render("acronym", context)
            }
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
}



