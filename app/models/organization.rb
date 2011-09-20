class Organization < ActiveRecord::Base
  has_many :memberships
  has_one  :bank_account
  has_many :users, :through => :memberships
  has_many :kits, :before_add => :check_for_duplicates,
                  :after_add => lambda { |u,k| k.activate! unless k.activated? }

  validates_presence_of :name
  validates :ein, :presence => true, :if => :updating_tax_info
  validates :legal_organization_name, :presence => true, :if => :updating_tax_info

  def owner
    users.first
  end

  delegate :can?, :cannot?, :to => :ability
  def ability
    OrganizationAbility.new(self)
  end

  attr_accessor :updating_tax_info
  def update_tax_info(params)
    @updating_tax_info = true
    update_attributes({
      :ein => params[:ein],
      :legal_organization_name => params[:legal_organization_name]
    })
  end

  def has_tax_info?
    !(ein.blank? or legal_organization_name.blank?)
  end

  def connected?
    !fa_member_id.blank?
  end

  def available_kits
    Kit.pad_with_new_kits(kits)
  end

  def authorization_hash
    { :authorized   => can?(:receive, Donation),
      :type         => donation_type,
      :organization => name }
  end

  private

  def check_for_duplicates(kit)
    raise Kit::DuplicateError if kits.where(:type => kit.type).any?
  end

  def donation_type
    return :regular if kits.where(:type => "RegularDonationKit").any?
    return :sponsored if kits.where(:type => "SponsoredDonationKit").any?
  end
end