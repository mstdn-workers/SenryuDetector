module Mastodon
  module REST
    class Client
      def create_status(text, spoiler_text )
        perform_request_with_object(:post, '/api/v1/statuses', {status: text, spoiler_text: spoiler_text}, Mastodon::Status)
      end
    end
  end
end
