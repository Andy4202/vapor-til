import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    //RouteCollection requires you to implement boot(router:) to register routes.
    func boot(router: Router) throws {

        //Create a route group...
        let acronymsRoutes = router.grouped("api", "acronyms")


        
//        func createHandler(_ req: Request) throws -> Future<Acronym> {
//            return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) {
//                acronym in return acronym.save(on: req)
//            }
//        }
        
        func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
            return acronym.save(on: req)
        }
        
        
        func getHandler(_ req: Request) throws -> Future<Acronym> {
            return try req.parameters.next(Acronym.self)
        }
        
        func updateHandler(_ req: Request) throws -> Future<Acronym> {
            
            return try flatMap(to: Acronym.self,
                               req.parameters.next(Acronym.self),
                               req.content.decode(Acronym.self)) {
                                acronym, updatedAcronym in
                                    acronym.short = updatedAcronym.short
                                    acronym.long = updatedAcronym.long
                                    acronym.userID = updatedAcronym.userID
                                return acronym.save(on: req)
            }
        }
       
        func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
            return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent)
        }
        
        
        func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
            guard let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
            }
            return try Acronym.query(on: req).group(.or) { or in
                try or.filter(\.short == searchTerm)
                try or.filter(\.long == searchTerm)
            }.all()
        }
        
        func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
            return Acronym.query(on: req).first().map(to: Acronym.self) {
                acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
            }
        }
        
        func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
            return try Acronym.query(on: req).sort(\.short, .ascending).all()
        }
        
        // Define a new route handler, getUserHandler(_:) that returns Future<User>
        func getUserHandler(_ req: Request) throws -> Future<User> {
            //Fetch the acronym specified in the request's parameters and unwrap the returned future.
            return try req.parameters.next(Acronym.self).flatMap(to: User.self) {
                acronym in
                //Use the new computed property created above to get the acronym's owner.
                try acronym.user.get(on: req)
            }
        }
        
        
        //Register the route.
        //This will make a GET request to /api/acronyms call getAllHandler(_:)
        //router.get("api", "acronyms", use: getAllHandler)
        
        //This works as before but greatly simplifies code, making it easier to maintain.
        acronymsRoutes.get(use: getAllHandler)
        
        //Register createHandler(_:) to process POST requests to /api/acronyms
        //acronymsRoutes.post(use: createHandler)
        acronymsRoutes.post(Acronym.self, use: createHandler)
        
        //Register getHandler(_:) to process GET requests to /api/acronyms/<ACRONYM ID>
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        
        //Register updateHandler(_:) to process PUT requests to /api/acronyms/<ACRONYM ID>
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        
        //Register deleteHandler(_:) to process DELETE requests to  /api/acronyms/<ACRONYM ID>
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        
        //Register searchHandler(:_) to process GET requests to  /api/acronyms/search
        acronymsRoutes.get("search", use: searchHandler)
        
        //Register getFirstHandler(:_) to process GET requests to  /api/acronyms/first
        acronymsRoutes.get("first", use: getFirstHandler)
        
        //Register sortedHandler(:_) to process GET requests to  /api/acronyms/sorted
        acronymsRoutes.get("sorted", use: sortedHandler)
        
        //This connects an HTTP GET request to /api/acronyms/<ACRONYM ID>/user to
        //  getUserHandler(_:)
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
        
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    
    
    
}
