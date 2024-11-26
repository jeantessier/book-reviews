require 'rails_helper'

describe BookConsumer do
  let(:book_id) { '1234' }

  let(:metadata) do
    {
      topic: '',
      partition: 0,
      offset: 13,
      headers: {},
      key: nil,
      retry_count: 0,
    }
  end

  context '#consume' do
    let(:payload) do
      {}.to_json
    end

    it 'consumes my message' do
      expect_any_instance_of(described_class).to receive(:around_consume).with(payload, metadata).once.and_call_original
      expect_any_instance_of(described_class).to receive(:consume).with(payload, metadata).once.and_call_original

      process_message(handler: described_class, payload:, metadata:)
    end

    context 'bookAdded message' do
      let(:book) do
        {
          id: book_id,
          name: 'some name',
          titles: [
            {
              title: 'some title',
              link: 'some link',
            },
          ],
          authors: [ 'some author' ],
          publisher: 'some publisher',
          years: [ 'some year' ],
        }
      end

      let(:payload) do
        {
          type: 'bookAdded',
        }.merge(book).to_json
      end

      it 'adds book to BookRepository' do
        expect(BookRepository).to receive(:save).with(book).once

        process_message(handler: described_class, payload:, metadata:)
      end
    end

    context 'bookUpdated message' do
      let(:original_book) do
        {
          id: book_id,
          name: 'original name',
          titles: [
            {
              title: 'original title',
              link: 'original link',
            },
          ],
          authors: [ 'original author' ],
          publisher: 'original publisher',
          years: [ 'original year' ],
        }
      end

      let(:modified_book) do
        original_book.merge(json_message)
      end

      let(:payload) do
        {
          type: 'bookUpdated',
        }.merge(json_message).to_json
      end

      context 'with invalid id' do
        let(:json_message) do
          {
            id: book_id,
          }
        end

        it 'raises an error', skip: 'message is being consumed by another instance' do
          expect(BookRepository).to receive(:find_by_id).with(book_id).and_return(nil)
          expect_any_instance_of(described_class).to receive(:consume).with(payload, metadata).and_raise("No book with ID #{book_id}")

          process_message(handler: described_class, payload:, metadata:)

          expect(original_book).to eq(modified_book)
        end
      end

      context 'with valid id' do
        shared_examples 'updates in-memory book' do
          it 'updates in-memory book' do
            expect(BookRepository).to receive(:find_by_id).with(book_id).and_return(original_book)

            process_message(handler: described_class, payload:, metadata:)

            expect(original_book).to eq(modified_book)
          end
        end

        context 'updates name' do
          let(:json_message) do
            {
              id: book_id,
              name: "updated name",
            }
          end

          include_examples 'updates in-memory book'
        end

        context 'updates titles' do
          let(:json_message) do
            {
              id: book_id,
              titles: [
                {
                  title: "updated title",
                },
              ],
            }
          end

          include_examples 'updates in-memory book'
        end

        context 'updates authors' do
          let(:json_message) do
            {
              id: book_id,
              authors: [ "updated author" ],
            }
          end

          include_examples 'updates in-memory book'
        end

        context 'updates publisher' do
          let(:json_message) do
            {
              id: book_id,
              publisher: "updated publisher",
            }
          end

          include_examples 'updates in-memory book'
        end

        context 'updates years' do
          let(:json_message) do
            {
              id: book_id,
              years: [ "updated year" ],
            }
          end

          include_examples 'updates in-memory book'
        end
      end
    end

    context 'bookRemoved message' do
      let(:payload) do
        {
          type: 'bookRemoved',
          id: book_id,
        }.to_json
      end

      it 'removes book from BookRepository' do
        expect(BookRepository).to receive(:remove).with(book_id).once

        process_message(handler: described_class, payload:, metadata:)
      end
    end
  end
end
