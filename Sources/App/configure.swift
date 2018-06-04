//import FluentSQLite
import FluentPostgreSQL
//import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(
        _ config: inout Config,
        _ env: inout Environment,
        _ services: inout Services)
    throws {
    /// Register providers first
    //try services.register(FluentSQLiteProvider())
    try services.register(FluentPostgreSQLProvider())
    //try services.register(FluentMySQLProvider())
        
        
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    //let sqlite = try SQLiteDatabase(storage: .memory)

    // Configure a database
    // Create a DatabasesConfig() to configure the database.
    var databases = DatabasesConfig()
    /* Use Environment.get(_:) to fetch environment variables set by Vapor Cloud.
    If the function call returns nil (i.e. the application is running locally), default to the values required for the Docker container */
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    //let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    
    /****/
        
        //For testing:
        let databaseName: String
        let databasePort: Int
        
        if (env == .testing) {
            databaseName = "vapor-test"
            //databasePort = 5433
            
            //This uses the DATABASE_PORT environment variable if set, otherwise defaults the port to 5433.  This allows you to set the port in docker-compose.yml
            if let testPort = Environment.get("DATABASE_PORT") {
                databasePort = Int(testPort) ?? 5433
            } else {
                databasePort = 5433
            }
            
            
        } else {
            databaseName = Environment.get("DATABASE_DB") ?? "vapor"
            databasePort = 5432
        }
        
    /****/
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    // Use the properties to create a new PostgreSQLDatabaseConfig.
    //let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, username: username, database: databaseName, password: password)
    
    //The above is now replaced for testing:
    //If running in the .testing environment, set the database name and port to different values.
    //Configure the database port in the PostgreSQLDatabaseConfig
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, database: databaseName, password: password)
        
        
        
        
        
    // Create a PostgreSQLDatabase using the configuration.
    let database = PostgreSQLDatabase(config: databaseConfig)
    
    //Add the database object to the DatabasesConfig using the default .psql identifier.
    databases.add(database: database, as: .psql)
    
    //Register DatabasesConfig with the services.
    services.register(databases)
        
        
    
    /// Configure migrations
    var migrations = MigrationConfig()
        
    //Change the Acronym migration to use the .psql database.
    //migrations.add(model: Todo.self, database: .sqlite)
    //migrations.add(model: Acronym.self, database: .sqlite)

    //migrations.add(model: Acronym.self, database: .mysql)
    //Add the new model to the migrations so Fluent prepares the table in the database.
    migrations.add(model: User.self, database: .psql)
    
    //Because you're linking the acronym's userID property to the User table, you must create the USer table first.  So make sure  the User migration is before the Acronym migration.
    migrations.add(model: Acronym.self, database: .psql)
        
    //Add the new model to the MigrationConfig so that Fluent creates the table in the database at the next application start.
    migrations.add(model: Category.self, database: .psql)
        
    //Add the AcronymCategoryPivot model to the migration list,
    //Fluent will prepate the table in the database at the next application start.
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
        
    services.register(migrations)
        
    // Create a CommandConfig with the default configuration.
    var commandConfig = CommandConfig.default()
    // Add the revert command with the identifier revert.  This is the string you use to invoke the command.
    commandConfig.use(RevertCommand.self, as: "revert")
    //Register the commandConfig as a service.
    services.register(commandConfig)
        
}
