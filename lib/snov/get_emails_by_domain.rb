require 'active_support/core_ext/array'

module Snov
  class GetEmailsByDomain
    include Enumerable

    attr_reader :client, :domain, :page, :per_page

    def initialize(domain:, type: 'all', last_id: 0, limit: 100, client: Snov.client)
      @client = client
      @domain = domain
      @type = type
      @limit = limit
      @last_id = last_id
    end

    def each(&block)
      emails.each(&block)
    end

    def emails
      @emails ||= raw_result.fetch('emails').map do |result|
        EmailResult.new(result)
      end
    end

    def raw_result
      @raw_result ||= client.get_v2("/v2/domain-emails-with-info",
                                  'domain' => @domain.to_s,
                                  'type' => @type.to_s,
                                  'limit' => @limit.to_s,
                                  'lastId' => @last_id.to_s)
                            .deep_transform_keys! { |key| key.underscore }
    end

    class EmailResult
      include ActiveModel::Model

      attr_accessor :email, :first_name, :last_name, :position, :source_page, 
        :company_name, :type, :status
    end
  end
end
