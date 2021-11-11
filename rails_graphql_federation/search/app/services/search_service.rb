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
        json_message['email'],
        json_message['email'].gsub(/@/, ' '),
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

    def log_indices
      Rails.logger.info 'indices:'
      indices.each do |word, index|
        Rails.logger.info "  #{word}"
        index.each do |id, index_entry|
          Rails.logger.info "    #{id}: #{index_entry}"
        end
      end
    end

    private

    def update_index(corpus, index_entry)
      old_index_entries = find_current_index_entries(index_entry[:id])
      new_index_entries = compute_new_index_entries(corpus, index_entry)

      old_index_entries.keys.reject { |word| new_index_entries.has_key?(word) }.each { |word| scrub_index(word, index_entry[:id]) }
      new_index_entries.each { |word, scored_index_entry| index_word(word, scored_index_entry) }
    end

    def find_current_index_entries(id)
      indices.transform_values { |index| index[id] }.reject { |_, v| v.nil? }
    end

    def compute_new_index_entries(corpus, index_entry)
      word_scores = {}
      word_scores.default = 0
      corpus.each do |words|
        compute_score_for_words(words).each do |word, score|
          word_scores[word] += score
        end
      end

      word_scores.transform_values { |score| { score: score }.merge(index_entry) }
    end

    def compute_score_for_words(words)
      word_scores = {}
      word_scores.default = 0.0
      words.downcase.split(/\s+/).each do |word|
        word_scores[word] += word.length
      end

      word_scores.transform_values { |score| score / words.length }
    end

    def index_word(word, index_entry)
      indices[word][index_entry[:id]] = index_entry
    end

    def scrub_index(word, id)
      indices[word].delete(id)
      indices.delete(word) if indices[word].empty?
    end

    def normalize(text)
      text.gsub(/[!?.&]/, '')
    end

    # word --> id --> scored index entries
    def indices
      @indices ||= begin
                     indices = {}
                     indices.default_proc = lambda { |hash, key| hash[key] = {} }
                     indices
                   end
    end
  end
end
