import Foundation

protocol PostsPersistanceType {
    func getPosts() -> [Post]?
    func savePosts(posts: [Post])
    
    func getUsers() -> [User]?
    func saveUsers(users: [User])
    
    func getComments(postId: Identifier<Post>) -> [Comment]?
    func saveComments(for postId: Identifier<Post>, comments: [Comment])
}

struct PostsPersistance: PostsPersistanceType {
    private let persistance: Persistance
    
    init(persistance: Persistance) {
        self.persistance = persistance
    }
    
    // MARK: - Posts
    
    func getPosts() -> [Post]? {
        guard let data = self.persistance.get(key: "posts") else {
            return nil
        }
        return self.persistance.decode([Post].self, data: data)
    }
    
    func savePosts(posts: [Post]) {
        guard let data = self.persistance.encode(object: posts) else {
            return
        }
        self.persistance.save(value: data, key: "posts")
    }
    
    // MARK: - Users
    
    func getUsers() -> [User]? {
        guard let data = self.persistance.get(key: "users") else {
            return nil
        }
        return self.persistance.decode([User].self, data: data)
    }
    
    func saveUsers(users: [User]) {
        guard let data = self.persistance.encode(object: users) else {
            return
        }
        self.persistance.save(value: data, key: "users")
    }
    
    // MARK: - Comments
    
    func getComments(postId: Identifier<Post>) -> [Comment]? {
        guard let data = self.persistance.encode(object: self.commentKey(for: postId)) else {
            return nil
        }
        return self.persistance.decode([Comment].self, data: data)
    }
    
    func saveComments(for postId: Identifier<Post>, comments: [Comment]) {
        guard let data = self.persistance.encode(object: comments) else {
            return
        }
        self.persistance.save(value: data, key: self.commentKey(for: postId))
    }
    
    private func commentKey(for postId: Identifier<Post>) -> String {
        return "\(postId.value)-comments"
    }
}
