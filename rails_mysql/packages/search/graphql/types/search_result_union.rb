module Types
  class SearchResultUnion < Types::BaseUnion
    possible_types BookType, ReviewType, UserType

    def self.resolve_type(object, _)
      case object
      when Book then BookType
      when Review then ReviewType
      when User then UserType
      else
        raise "Unexpected Claim: #{object.inspect}"
      end
    end
  end
end
