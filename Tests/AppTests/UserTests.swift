
@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    //setUp() reverts the database, generates an Application for the test, and creates a connection to the database.
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        
        _ = try User.create(on: conn)
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        
        // 1. Create a User object with known values.
        let user = User(name: usersName, username: usersUsername)
        
        // 2. Use the new getResponse(to: method:headers:data:decodeTo) to send a POST
        // request to the API and get the response. Use the user object as the request body and set the
        // headers correctly to simulate to JSON request.  Convert the response into a User object.
        let receivedUser = try app.getResponse(to: usersURI, method: .POST, headers: ["Content-Type":"application/json"], data: user, decodeTo: User.self)
        
        // 3.  Assert the response from the API matches the expected values.
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        
        // 4. Get all the users from API.
        let users = try app.getResponse(to: usersURI, decodeTo: [User].self)
        
        // 5. Ensure the response only contains the user you created in the first request.
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
    
    //Test to get a single user from the API.
    func testGettingASingleUserFromTheAPI() throws {
        
        // 1. Save a user in the database with known values.
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        // 2. Get the user at /api/users/<USER ID>
        let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.self)
        
        // 3. Assert the values are the same as provided when creating the user.
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        
        // 1. Create the user for the acronyms.
        let user = try User.create(on: conn)
        
        // 2. Define some expected values for an acronym.
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        
        // 3. Create two acronyms in the database using the created user.
        //      Use the expected values for the first acronym.
        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: conn)
        
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: conn)

        // 4. Get the user's acronyms from the API by sending a request to /api/users/<USER UD>/acronyms.
        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)
        
        // 5. Assert the response returns the correct number of acronyms and the first one matches the expected values.
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
        
    }
    
    //When you call swift test or vapor test on Linux, the test executable uses this array to determine which tests to run.
    static let allTests = [
        ("testUsersCanBeRetrievedFromAPI", testUsersCanBeRetrievedFromAPI),
        ("testUserCanBeSavedWithAPI",testUserCanBeSavedWithAPI),
        ("testGettingASingleSUerFromTheAPI", testGettingASingleUserFromTheAPI),
        ("testGettingAUsersAcronymsFromTheAPI", testGettingAUsersAcronymsFromTheAPI)
    ]
    
    
    
    
//    func testUsersCanBeRetrievedFromAPI() throws {
//
//        /********************/
//
//        // 1. Set the arguments the Application should execute.
//        let revertEnvironmentArg = ["vapor", "revert", "--all", "-y"]
//
//        // 2. Set up the services, configuration and testing environment.
//        var revertConfig = Config.default()
//        var revertServices = Services.default()
//        var revertEnv = Environment.testing
//
//        // 3. Set the arguments in the environment.
//        revertEnv.arguments = revertEnvironmentArg
//
//        // 4. Set up the application as earlier in the test.
//        //  This creates a different Application object that executes the revert command.
//        try App.configure(&revertConfig, &revertEnv, &revertServices)
//
//        let revertApp = try Application(config: revertConfig, environment: revertEnv, services: revertServices)
//        try App.boot(revertApp)
//
//        // 5. Call asyncRun() which starts the application and execute the revert command.
//        try revertApp.asyncRun().wait()
//
//
//        /*********************/
//
//        // 1. Define some expected values for the test: a user's name and username.
//        let expectedName = "Alice"
//        let expectedUsername = "alice"
//
//        // 2. Create an Application, as in main.swift.
//        //  This creates an entire Application object but doesn't start running the application.
//        //  This helps ensure you configure your real application correctly as your test calls the same App.configure(_:_:_:).  Note, you're using the .testing environment here.
//        var config = Config.default()
//        var services = Services.default()
//        var env = Environment.testing
//
//        try App.configure(&config, &env, &services)
//        let app = try Application(config: config, environment: env, services: services)
//
//        try App.boot(app)
//
//        // 3. Create a database connection to perform database operations.
//        //  Note the use of .wait() here and throughout the test.
//        //  As you aren't running the test on an EventLoop, you can use wait() for the future to return.
//        //  This helps simplify the code.
//        let conn = try app.newConnection(to: .psql).wait()
//
//        // 4. Create a couple of users and save them in the database.
//        let user = User(name: expectedName, username: expectedUsername)
//
//        let savedUser = try user.save(on: conn).wait()
//
//        _ = try User(name: "Luke", username: "lukes").save(on: conn).wait()
//
//        // 5. Create a Responder type; this is what responds to your requests.
//        let responder = try app.make(Responder.self)
//
//        // 6. Send a GET HTTPRequest to /api/users/, the endpoint for getting all the users.
//        //  A Request object wraps the HTTPRequest so there's a Worker to execute it.
//        //  Since this is a test, you can force unwrap variables to simplify the code.
//        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
//
//        let wrappedRequest = Request(http: request, using: app)
//
//        // 7. Send the request and get the response.
//        let response = try responder.respond(to: wrappedRequest).wait()
//
//        // 8. Decode the response data into an array of Users.
//        let data = response.http.body.data
//        let users = try JSONDecoder().decode([User].self, from: data!)
//
//        // 9. Ensure there are correct numbers of users in the response and the users match those created at the start of the test.
//        XCTAssertEqual(users.count, 2)
//        XCTAssertEqual(users[0].name, expectedName)
//        XCTAssertEqual(users[0].username, expectedUsername)
//        XCTAssertEqual(users[0].id, savedUser.id)
//
//        // 10. Close the connection to the database once the test has finished.
//        conn.close()
//    }
}
