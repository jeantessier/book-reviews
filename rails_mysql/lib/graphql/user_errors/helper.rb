module GraphQL
  module UserErrors
    module Helper
      def user_errors
        @user_errors ||= []
      end

      def add_user_error(argument:, message:)
        user_errors << { argument:, message: }
      end

      def with_user_errors(payload)
        payload.merge(user_errors:)
      end
    end
  end
end
