class Transaction < ActiveResource::Base
  headers['X-ATHENA-Key'] = 'artful.ly'

  self.site = Artfully::Application.config.tickets_site
  self.format = :json
  self.prefix = "/tickets/"

  schema do
    attribute 'lockExpires',  :string
    attribute 'lockedByApi',  :string
    attribute 'lockedByIp',   :string
    attribute 'status',       :string
  end

  def tickets
    @tickets ||= TicketCollection.new(attributes[:tickets])
  end

  def tickets=(tickets)
    tickets.replace(tickets)
  end

  def encode
    @attributes[:tickets] = tickets.to_a
    @attributes.to_json
  end

  #TODO: Move this to macro at some point.
  class << self
    def collection_path(prefix_options = {}, query_options = nil)
      check_prefix_options(prefix_options)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/.#{format.extension}#{query_string(query_options)}"
    end

    private

      def check_prefix_options(prefix_options)
        p_options = HashWithIndifferentAccess.new(prefix_options)
        prefix_parameters.each do |p|
          raise(MissingPrefixParam, "#{p} prefix_option is missing") if p_options[p].blank?
        end
      end
  end
end
