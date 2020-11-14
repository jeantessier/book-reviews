module Types
  class SearchResultUnion < Types::BaseUnion
    possible_types BookType, ReviewType, UserType

    def self.resolve_type(object, context)
      if object.is_a? Book
        BookType
      elsif object.is_a? Review
        ReviewType
      elsif object.is_a? User
        UserType
      else
        raise "Unexpected Claim: #{object.inspect}"
      end
    end
  end
end