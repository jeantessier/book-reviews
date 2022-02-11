class SearchService
  include Phobos::Producer

  KAFKA_TOPIC = 'book-reviews.searches'

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
      corpus << normalize(json_message['start']) if json_message['start'].present?
      corpus << normalize(json_message['stop']) if json_message['stop'].present?
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

    def search(q, current_user)
      user = current_user&.has_key?(:sub) ? current_user[:sub] : nil

      results_collector = {}

      q.downcase.split(/\s+/).each do |word|
        if indices.has_key?(word)
          indices[word].each do |id, index_entry|
            if results_collector.has_key?(id)
              results_collector[id][:weight] += index_entry[:score]
            else
              results_collector[id] = index_entry.transform_keys { |k| k == :score ? :weight : k }
            end
          end
        end
      end

      results = results_collector.values.sort { |a, b| b[:weight] <=> a[:weight] }

      payload = {
        id: user,
        user: user,
        query: q,
        results: results,
      }

      Rails.logger.info <<-MSG
        Sending message ...
          topic: #{KAFKA_TOPIC}
          key: #{payload[:id]}
          payload: #{payload.to_json}
      MSG

      producer.publish(
        topic: KAFKA_TOPIC,
        key: payload[:id],
        payload: payload.to_json,
      )

      results
    end

    def query_plan(q)
      plan = {
        words: q.downcase.split(/\s+/),
        indices: [],
        results: [],
      }

      results_collector = {}

      plan[:words].each do |word|
        if indices.has_key?(word)
          plan[:indices] << {
            word: word,
            entries: indices[word].values.map { |index_entry| { type: index_entry[:__typename],  }.merge(index_entry) }
          }
          indices[word].each do |id, index_entry|
            if results_collector.has_key?(id)
              results_collector[id][:weights] << { word: word, weight: index_entry[:score] }
              results_collector[id][:total_weight] += index_entry[:score]
            else
              results_collector[id] = {
                weights: [ { word: word, weight: index_entry[:score] } ],
                total_weight: index_entry[:score],
                id: index_entry[:id],
                type: index_entry[:__typename],
              }
            end
          end
        end
      end

      plan[:results] = results_collector.values.sort { |a, b| b[:total_weight] <=> a[:total_weight] }

      plan
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
