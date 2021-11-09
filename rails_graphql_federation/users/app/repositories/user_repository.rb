class UserRepository
    def self.all
        users.values
    end

    def self.save(user)
        raise "Duplicate ID \"#{user[:id]}\"" if users.include?(user[:id])
        users[user[:id]] = user
    end

    def self.find_by_id(id)
        users[id]
    end

    def self.find_by_email(email)
        all.find { |u| u[:email] == email }
    end

    def self.remove(id)
        !(users.delete(id).nil?)
    end

    private

    def self.users
        @@users ||= {}
    end
end
