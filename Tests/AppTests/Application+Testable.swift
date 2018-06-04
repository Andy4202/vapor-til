import Vapor
import App
import FluentPostgreSQL

extension Application {
    
    //This function allows you to create a testable Application object.
    static func testable(envArgs: [String]? = nil) throws -> Application {
        
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        
        let app = try Application(config: config, environment: env, services: services)
        
        try App.boot(app)
        
        return app
    
    }
    
    //Function to reset the database
    //This uses testable(envArgs:) to create an application that runs the revert command.
    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        
        try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
    }
    
    
    //1. A method that sends a request to a path and returns a Response.
    //  Allow the HTTP method, headers and body to be set; this is for later tests.
    func sendRequest(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(),
                     body: HTTPBody = .init()) throws -> Response {
        
        // 2. Create a responder, request and wrapped request.
        let responder = try self.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!,
                                  headers: headers, body: body)
        let wrappedRequest = Request(http: request, using: self)
        
        // 3. Send the request and return the response.
        return try responder.respond(to: wrappedRequest).wait()
    }
 
    // 4. Define a generic method that accepts a Decodable type.
    func getResponse<T>(to path: String, method: HTTPMethod = .GET,
                        headers: HTTPHeaders = .init(),
                        body: HTTPBody = .init(),
                        decodeTo type: T.Type) throws -> T where T: Decodable {
        // 5. Use the first method to get the response.
        let response = try self.sendRequest(to: path, method: method, headers: headers, body: body)
        
        // 6. Decode the response body to the generic type and return the result.
        return try JSONDecoder().decode(type, from: response.http.body.data!)
        
    }
    
    //getResponse<T, U> sends a request with an encoded model as the body.
    func getResponse<T, U>(to path: String,
                           method: HTTPMethod = .GET,
                           headers: HTTPHeaders = .init(),
                           data: U,
                           decodeTo type: T.Type) throws -> T where T: Decodable, U: Encodable {
        let body = try HTTPBody(data: JSONEncoder().encode(data))
        return try self.getResponse(to: path, method: method, headers: headers, body: body, decodeTo: type)
    }
    
    
    //This helper method sends a request with a body but ignores the response.
    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders, data: T) throws where T: Encodable {
        
        let body = try HTTPBody(data: JSONEncoder().encode(data))
        
        _ = try self.sendRequest(to: path, method: method, headers: headers, body: body)
        
    }
    
    
}
