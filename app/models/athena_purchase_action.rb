class AthenaPurchaseAction < AthenaResource::Base

  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'actions'
  self.collection_name = 'actions'

  schema do
    attribute 'person_id',  :string
    attribute 'item_type',  :string
    attribute 'item_id',    :string
    attribute 'type',       :string
  end

  def type=(type);;end

  validates_presence_of :person_id, :item_type, :item_id

  def initialize(attributes = {})
    super(attributes)
    @attributes['type'] = "purchase"
  end

  def person
    @person ||= find_person
  end

  def person=(person)
    if person.nil?
      @person = person_id = person
      return
    end

    raise TypeError, "Expecting an AthenaPerson" unless person.kind_of? AthenaPerson
    @person, self.person_id = person, person.id
  end

  def item
    @item ||= find_item
  end

  def item=(item)
    return if item.nil? or item.id.nil?
    self.item_id = item.id
    self.item_type = item.class.to_s
    @item = item
  end

  private
    def find_person
      return if self.person_id.nil?

      begin
        AthenaPerson.find(self.person_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:person_id, nil)
        return nil
      end
    end

    def find_item
      # Find item by item_type
    end
end