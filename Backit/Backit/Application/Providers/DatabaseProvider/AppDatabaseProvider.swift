/**
 * Provides interface to local store.
 *
 * This uses SQLite and protobuff to store properties in the database.
 * Every user will get their own database.
 * Votes will be synchronized when the user logs in.
 *
 * App Consideration:
 * - Is there a time limit to keep cached likes? Or a max number?
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation
import FMDB

private typealias GuestUser = User

private enum Constant {
    static let guestId = "com.backit.backers.user.guest"
}

extension User {
    init() {
        self.id = Constant.guestId
        self.avatarUrl = nil
        self.username = "Guest"
    }
}

extension User {
    var isGuest: Bool {
        return id == Constant.guestId
    }
}

class AppDatabaseProvider: DatabaseProvider {
    
    private var database: FMDatabase?
    private var user: User = GuestUser()
    private var likes: [ProjectId: Bool] = [:] // O(1) access w/ Dictionary
    
    private var databaseName: String {
        return "\(user.id).db"
    }
    
    private var databasePath: URL {
        var url = URL(fileURLWithPath: NSTemporaryDirectory())
        url.appendPathComponent(databaseName)
        return url
    }

    init(userStream: UserStreamer) {
        userStream.listen(self)
    }
    
    deinit {
        database?.close()
    }
    
    // TODO: Make sure all create/delete of a "like", attempts to re-upload in the event of a failure. The operation _may_ happen many times. Cancel the operation appropriately.
    
    func didVoteForProject(_ project: Project) -> Bool {
        return likes[project.id] ?? false
    }
    
    func voteForProject(_ project: Project) {
        let exists = likes[project.id] ?? false
        guard !exists else {
            return log.i("Will not create like - project exists")
        }
        
        guard let database = database else {
            return log.w("voteForProject - no database connection")
        }
        
        likes[project.id] = true

        let statement = "INSERT TABLE likes VALUES (project_id) VALUES (?);"
        do {
            try database.executeUpdate(statement, values: [project.id])
            log.i("Created like for project \(project.id)")
        }
        catch {
            log.e(error)
        }
    }
    
    func removeVoteFromProject(_ project: Project) {
        let exists = likes[project.id] ?? false
        guard exists else {
            return log.i("Will not delete like - project does not exist")
        }
        
        guard let database = database else {
            return log.w("voteForProject - no database connection")
        }

        likes.removeValue(forKey: project.id)
        
        let statement = "DELETE FROM likes WHERE project_id = ?;"
        do {
            try database.executeUpdate(statement, values: [project.id])
            log.i("Deleted like for project \(project.id)")
        }
        catch {
            log.e(error)
        }
    }
    
    // MARK: - Private methods
    
    private func createDatabaseIfNeeded() {
        if let db = database {
            db.close()
            self.database = nil
        }
        
        let db = FMDatabase(url: databasePath)
        if !db.open() {
            return
        }
        
        let statements = "CREATE TABLE IF NOT EXISTS likes (project_id INTEGER PRIMARY KEY);"
        db.executeStatements(statements)
        
        log.i("Successfully created database \(databaseName)")
        
        self.database = db
    }
    
    private func synchronizeLikes() {
        guard !user.isGuest else {
            return
        }
        
        // TODO: Synchronize local likes with likes on the server.
        // TODO: Removes all queued operations.
    }
    
    private func cacheLikes() {
        likes = [:]
        
        guard let database = database else {
            return log.w("Attempting to cache likes when a database conn has not been opened")
        }
        
        do {
            let rs = try database.executeQuery("SELECT project_id FROM likes", values: nil)
            while rs.next() {
                let projectId = ProjectId(rs.int(forColumn: "project_id"))
                likes[projectId] = true
            }
            log.i("Cached likes")
        }
        catch {
            log.e(error)
        }
    }
}

extension AppDatabaseProvider: UserStreamListener {
    func didChangeUser(_ user: User?) {
        self.user = user ?? GuestUser()
        createDatabaseIfNeeded()
        synchronizeLikes()
        cacheLikes()
    }
}
