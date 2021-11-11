class SearchService
  class << self
    def index_book(json_message)
      corpus = [
        json_message['id'],
        json_message['name'],
        json_message['titles'].collect { |title| normalize(title['title']) },
        json_message['authors'].collect { |author| normalize(author) },
        normalize(json_message['publisher']),
        json_message['years'],
      ].flatten
      update_index(
        corpus,
        {
          __typename: 'Book',
          id: json_message['id'],
        }
      )
    end
    
    def index_review(json_message)
      corpus = [
        json_message['id'],
        normalize(json_message['body']),
      ]
      corpus << normalize(json_message['start']) if json_message.include?('start')
      corpus << normalize(json_message['stop']) if json_message.include?('stop')
      update_index(
        corpus,
        {
          __typename: 'Review',
          id: json_message['id'],
        }
      )
    end
    
    def index_user(json_message)
      corpus = [
        json_message['id'],
        normalize(json_message['name']),
        normalize(json_message['email']),
        normalize(json_message['email'].gsub(/@/, ' ')),
      ]
      update_index(
        corpus,
        {
          __typename: 'User',
          id: json_message['id'],
        }
      )
    end
    
    def scrub_indices(json_message)
      update_index(
        [],
        {
          id: json_message['id'],
        }
      )
    end

    def search(q)
      []
    end

    def query_plan(q)
      {
        words: [],
        indices: [],
        results: [],
      }
    end

    private

    def update_index(corpus, index_entry)
        Rails.logger.info 'SearchService.update_index'
        Rails.logger.info '  corpus:'
        corpus.each { |text| Rails.logger.info "    \"#{text}\"" }
        Rails.logger.info '  index_entry:'
        Rails.logger.info "    #{index_entry}"
    end
    
    def normalize(text)
      text.gsub(/[!?.&]/, '')
    end
  end
end
