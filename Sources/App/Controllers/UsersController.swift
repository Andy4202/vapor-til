import Vapor


//Define a new type UsersController that conforms to RouteCollection.
struct UsersController: RouteCollection {
    
    //Implement boot(router:) as required by RouteCollection
    func boot(router: Router) throws {
        
        //Create a new route group for the path /api/users.
        let usersRoute = router.grouped("api", "users")
        
        //Register createHandler(_:user:) to handle a POST request to /api/users.
        //This uses the POST helper method to decode the request body into a User object.
        usersRoute.post(User.self, use: createHandler)
        
        //Register getAllHandler(_:) to process GET requests to /api/users/
        usersRoute.get(use: getAllHandler)
        
        //Register getHandler(_:) to process GET requests to /api/users/<USER ID>
        usersRoute.get(User.parameter, use: getHandler)
        
        //Register the route handler...
        //This connects an HTTP GET request to /api/users/<USER ID>/acronyms to
        //  getAcronymsHandler(_:)
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
        
    }
    
    //Define the route handler function.
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        //Save the decoded user form the request.
        return user.save(on: req)
    }
    
    //Define a new route handler, getAllHandler(_:) that returns Future<[User]>
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        //Return all the users using a Fluent query.
        return User.query(on: req).all()
    }
    
    //Define a new route handler, getHandler(_:) that returns Future<User>
    func getHandler(_ req: Request) throws -> Future<User> {
        //Return the user specified by the request's parameter.
        return try req.parameters.next(User.self)
    }
    
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
    
        //Fetch the user specified in the request's parameters and unwrap the returned future.
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) {
            user in
            
            //Use the new computed property created above to get the acronyms using a Fluent query to return all the acronyms.
            try user.acronyms.query(on: req).all()
            
        }
        
    }
    
}
