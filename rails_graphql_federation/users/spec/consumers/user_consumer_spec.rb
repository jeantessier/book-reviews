require 'rails_helper'

describe UserConsumer do
  let(:user_id) { '1234' }

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

    context 'userAdded message' do
      let(:user) do
        {
          id: user_id,
          name: 'some name',
          email: 'some email address',
          password: 'some password',
          roles: [ 'some role' ],
        }
      end

      let(:payload) do
        {
          type: 'userAdded',
        }.merge(user).to_json
      end

      it 'adds user to UserRepository' do
        expect(UserRepository).to receive(:save).with(user).once

        process_message(handler: described_class, payload:, metadata:)
      end
    end

    context 'userUpdated message' do
      let(:original_user) do
        {
          id: user_id,
          name: 'original name',
          email: 'original email address',
          password: 'original password',
          roles: [ 'original role' ],
        }
      end

      let(:modified_user) do
        original_user.merge(json_message)
      end

      let(:payload) do
        {
          type: 'userUpdated',
        }.merge(json_message).to_json
      end

      context 'with invalid id' do
        let(:json_message) do
          {
            id: user_id,
          }
        end

        it 'raises an error', skip: 'message is being consumed by another instance' do
          expect(UserRepository).to receive(:find_by_id).with(user_id).and_return(nil)
          expect_any_instance_of(described_class).to receive(:consume).with(payload, metadata).and_raise("No user with ID #{user_id}")

          process_message(handler: described_class, payload:, metadata:)

          expect(original_user).to eq(modified_user)
        end
      end

      context 'with valid id' do
        shared_examples 'updates in-memory user' do
          it 'updates in-memory user' do
            expect(UserRepository).to receive(:find_by_id).with(user_id).and_return(original_user)

            process_message(handler: described_class, payload:, metadata:)

            expect(original_user).to eq(modified_user)
          end
        end

        context 'updates name' do
          let(:json_message) do
            {
              id: user_id,
              name: "updated name",
            }
          end

          include_examples 'updates in-memory user'
        end

        context 'updates email' do
          let(:json_message) do
            {
              id: user_id,
              email: 'updated email address',
            }
          end

          include_examples 'updates in-memory user'
        end

        context 'updates password' do
          let(:json_message) do
            {
              id: user_id,
              password: 'updated password',
            }
          end

          include_examples 'updates in-memory user'
        end

        context 'updates roles' do
          let(:json_message) do
            {
              id: user_id,
              roles: [ 'updated role' ],
            }
          end

          include_examples 'updates in-memory user'
        end
      end
    end

    context 'userRemoved message' do
      let(:payload) do
        {
          type: 'userRemoved',
          id: user_id,
        }.to_json
      end

      it 'removes user from UserRepository' do
        expect(UserRepository).to receive(:remove).with(user_id).once

        process_message(handler: described_class, payload:, metadata:)
      end
    end
  end
end
