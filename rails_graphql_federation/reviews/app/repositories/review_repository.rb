class ReviewRepository
    def self.all
        reviews.values
    end

    def self.save(review)
        raise "Duplicate ID \"#{review[:id]}\"" if reviews.include?(review[:id])
        reviews[review[:id]] = review
    end

    def self.find_by_id(id)
        reviews[id]
    end

    def self.remove(id)
        !(reviews.delete(id).nil?)
    end

    private

    def self.reviews
        @@reviews ||= {}
    end
end
