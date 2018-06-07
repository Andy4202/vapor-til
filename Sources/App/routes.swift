import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Register a new route at:
    //  /api/ acronyms
    // that accepts a POST request and returns Future<Acronym>
    router.post("api", "acronyms") { req -> Future<Acronym> in
        
        //Decode the request's JSON into an Acronym model using Codable.
        // This returns a Future<Acronym> so it uses a flatMap(to:) to extract the acronym when the decoding is complete.
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
           // Save the model using Fluent.
           // This returns Future<Acronym> as it returns the model once it's saved.
            return acronym.save(on: req)
            
        }
    }
    
    
    //Retrieve all acronyms
    //Register a new route handler for the request which returns Future<[Acronym]>,
    //  a future array of Acronyms.
//    router.get("api", "acronyms") { req -> Future<[Acronym]>  in
//        // Perform a query to get all the acronyms.
//        return Acronym.query(on: req).all()
//
//    }
    
    //To get a single acronym, you need a new route handler.
    // Register a route at /api/acronyms/<ID> to handle a GET request.
    // The route takes the acronym's id property as the final path segment.
    // This returns Future<Acronym>
//    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//        /*
//            Extract the acronym from the request using the parameter function.
//            This function performs all the work necessary to get the acronym  from the database.
//            It also handles the error cases when the acronym does not exist, or the ID type is wrong,
//            for example, when you pass it an integer when the ID is a UUID.
//        */
//        return try req.parameters.next(Acronym.self)
//        
//    }
    
    
    //Register a route for a PUT request to /api/acronyms/<ID> that returns Future<Acronym>
//    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//
//        //Use flatMap(to:_:_:), the dual future form of flatMap, to wait for both the parameter
//        // extraction and content decoding to complete.  This provides both the acronym from the database
//        //  and acronym from the request body to the closure.
//        return try flatMap(to: Acronym.self,
//                           req.parameters.next(Acronym.self),
//                           req.content.decode(Acronym.self)){
//
//                            acronym, updatedAcronym in
//
//                            // Update the acronym's properties with the new values.
//                            acronym.short = updatedAcronym.short
//                            acronym.long = updatedAcronym.long
//
//                            // Save the acronym and return the result.
//                            return acronym.save(on: req)
//
//        }
//    }
    
    //Register a route for a DELETE request to /api/acronyms/<ID> that returns Future<HTTPStatus>
//    router.delete("api", "acronyms", Acronym.parameter) {
//        //Extract the acronym to delete from the request's parameter.
//        req -> Future<HTTPStatus> in
//        //Delete the acronym using delete(on:)
//        //Instead of requiring you to unwrap the returned Future, Fluent allows you to call delete(on:)
//        //directly on that Future.  This helps tidy up code and reduce nesting.  Fluent provides convenience functions for delete, update, create and save.
//        //Transform the return into a 204 No Content response.
//        //This tells the client the request has successfully completed but there's no content to return.
//        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent)
//
//    }
    
    
    //Handling searches.
    //Register a new route handler for /api/acronyms/search that returns Future<[Acronym]>
//    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
//        // Retrieve the search term from the URL query string.
//        // You can do this with any Codable object by calling req.query.decode(_:)
//        // If this fails, throw a 400 Bad Request Error.
//        guard let searchTerm = req.query[String.self, at: "term"] else {
//            throw Abort(.badRequest)
//        }
//
//        //Use filter(_:) to find all acronyms whose short property matches the searchTerm.
//        /*
//            Because this uses key paths, the compiler can enforce type-safety on the properties
//            and filter terms.  This prevents run-time issues caused by specifying an invalid column name or invalid type to filter on.
//        */
//        //return try Acronym.query(on: req).filter(\.short == searchTerm).all()
//
//
//        // Create a filter group using the .or relation
//        return try Acronym.query(on: req).group(.or) { or in
//            // Add a filter to the group to filter for acronyms whose short property matches the search term.
//            try or.filter(\.short == searchTerm)
//            // Add a filter to the group to filter for acronyms whose long property matches the search term.
//            try or.filter(\.long == searchTerm)
//            // Return all the results.
//        }.all()
//
//    }
    
    // Register a new HTTP GET route for /api/acronyms/first that returns Future<Acronym>
//    router.get("api", "acronyms", "first") {
//        req -> Future<Acronym> in
//        // Perform a query to get the first acronym.
//        // Use the map(to:) function to unwrap the result of the query.
//        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
//
//            //Ensure an acronym exists.  first() returns an optional as there may be no acronyms in the database.  Throw a 404 Not Found if no acronym is returned.
//            guard let acronym = acronym else {
//                throw Abort(.notFound)
//            }
//            // Return the first acronym.
//            return acronym
//        }
//    }
    
    
    //Register a new HTTP GET route for /api/acronyms/sorted that returns Future<[Acronym]>
//    router.get("api", "acronyms", "sorted") {
//        req -> Future<[Acronym]> in
//        //Create a query for Acronym and use sort(_:_:) to perform the sort.
//        //This function takes the field to sort on and the direction to sort in.
//        //Finally use all() to return all the results of the query.
//        return try Acronym.query(on: req).sort(\.short, .ascending).all()
//    }
    
    
    //Now using AcronymsController.
    //Create a new AcronymsController.
    let acronymsController = AcronymsController()
    
    //Register the new type with the router to ensure the controller's routes get registered.
    try router.register(collection: acronymsController)
 
    //Create a UsersController instance.
    let usersController = UsersController()
    //Register the new controller instance with the router to hook up the routes.
    try router.register(collection: usersController)
    
    // Create a CategoriesController instance.
    let categoriesController = CategoriesController()
    
    // Register the new instance with the router to hook up the routes.
    try router.register(collection: categoriesController)
    
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
    
}
