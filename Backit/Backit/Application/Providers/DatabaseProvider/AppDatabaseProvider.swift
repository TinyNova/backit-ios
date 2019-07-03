/**
 * Provides interface to local store.
 *
 * This uses SQLite and protobuff to store properties in the database.
 * Every user will get their own database.
 * Votes will be synchronized when the user logs in.
 *
 * Copyright © 2019 Backit Inc. All rights reserved.
 */

import Foundation

private typealias GuestUser = User

private enum Constant {
    static let guest = "com.backit.backers.user.guest"
}

extension User {
    init() {
        self.avatarUrl = nil
        self.username = Constant.guest
    }
}

extension User {
    var isGuest: Bool {
        return username == Constant.guest
    }
}

class AppDatabaseProvider: DatabaseProvider {
    
    private var user: User = GuestUser()
    
    init(userStream: UserStreamer) {
        userStream.listen(self)
    }
    
    // TODO: Make sure all create/delete of a "like", attempts to re-upload in the event of a failure. The operation _may_ happen many times. Cancel the operation appropriately.
    
    func didVoteForProject(project: Project) -> Bool {
        return false
    }
    
    func voteForProject(project: Project) -> Bool {
        return false
    }
    
    func removeVoteFromProject(project: Project) -> Bool {
        return false
    }
    
    private func synchronizeLikes() {
        guard !user.isGuest else {
            return
        }
        
        // TODO: Synchronize local likes with likes on the server.
        // TODO: Removes all queued operations.
    }
}

extension AppDatabaseProvider: UserStreamListener {
    func didChangeUser(_ user: User?) {
        self.user = user ?? GuestUser()
        synchronizeLikes()
    }
}
