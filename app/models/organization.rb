class Organization < ActiveRecord::Base
  has_many :events
  has_many :charts
  has_many :shows
  has_many :tickets
  has_many :ticket_offers

  has_many :people
  has_many :segments

  has_many :memberships
  has_one  :bank_account
  has_many :orders
  has_many :items

  has_many :settlements
  has_one  :fiscally_sponsored_project
  has_many :users, :through => :memberships
  has_many :kits, :before_add => :check_for_duplicates,
                  :after_add => lambda { |u,k| k.activate! unless k.activated? }

  has_many :imports
  
  has_one :reseller_profile

  validates_presence_of :name
  validates :ein, :presence => true, :if => :updating_tax_info
  validates :legal_organization_name, :presence => true, :if => :updating_tax_info

  scope :linked_to_fa, where("fa_member_id is not null")

  def owner
    users.first
  end

  def dummy
    Person.dummy_for(self)
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
    fa_member_id.present?
  end

  def available_kits
    Kit.pad_with_new_kits(kits)
  end

  def authorization_hash
    { :authorized   => can?(:receive, Donation),
      :type         => donation_type,
      :fsp_name     => name_for_donations  }
  end

  def name_for_donations
    has_active_fiscally_sponsored_project? ? fiscally_sponsored_project.name : name
  end

  def fsp
    fiscally_sponsored_project || build_fiscally_sponsored_project(:fa_member_id => fa_member_id)
  end

  def has_active_fiscally_sponsored_project?
    connected? and fsp.active?
  end

  def has_fiscally_sponsored_project?
    connected? and fiscally_sponsored_project.present?
  end

  #Before calling this method, organization must have already been conected to an FA membership
  #and have fa_member_id set
  def refresh_active_fs_project
    if fa_member_id.present?
      fsp.refresh
      update_kits
    end
  end

  def donations
    Item.joins(:order).where(:product_type => "Donation", :orders => { :organization_id => id })
  end

  def ticket_sales
    Item.joins(:order).where(:product_type => "Ticket", :orders => { :organization_id => id })
  end

  def has_kit?(name)
    kits.where(:state => "activated").map(&:class).map(&:name).include?(name.to_s.camelize + "Kit")
  end

  private

    def update_kits
      if fsp.active?
        sponsored_kit.activate_without_prejudice!
      else
        sponsored_kit.cancel_with_authority!
      end
    end

    def sponsored_kit
      kits.where(:type => "SponsoredDonationKit").first || SponsoredDonationKit.new({:organization => self})
    end

    def check_for_duplicates(kit)
      raise Kit::DuplicateError if kits.where(:type => kit.type).any?
    end

    def donation_type
      return :sponsored if kits.where(:type => "SponsoredDonationKit").any?
      return :regular if kits.where(:type => "RegularDonationKit").any?
    end
end
