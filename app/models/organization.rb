class Organization < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :kits, :before_add => :check_for_duplicates,
                  :after_add => lambda { |u,k| k.activate! unless k.activated? }

  validates_presence_of :name

  def owner
    users.first
  end

  delegate :can?, :cannot?, :to => :ability
  def ability
    OrganizationAbility.new(self)
  end

  def connected?
    !fa_member_id.blank?
  end

  def authorization_hash
    { :authorized => can?(:receive, Donation),
      :type       => donation_type }
  end

  private

  def check_for_duplicates(kit)
    raise Kit::DuplicateError if kits.where(:type => kit.type).any?
  end

  def donation_type
    if can?(:receive, Donation)
      :sponsored
    end
  end
end