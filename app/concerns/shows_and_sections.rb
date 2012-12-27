module ShowsAndSections
  extend ActiveSupport::Concern

  included do
    attr_accessor :shows, :sections
    before_validation :set_shows_and_sections
    serialize :shows_and_sections, HashWithIndifferentAccess
  end

  module ClassMethods
  end

  def set_shows_and_sections
    show_ids = @shows.try(:collect, &:id)
    section_ids = @sections.try(:collect, &:id)
    shows_and_sections = {:shows => show_ids, :sections => section_ids}
  end
end
