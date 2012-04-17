module KitHelper
  include LinkHelper
  include ActionView::Helpers::NumberHelper
  
  def kit_message(kit)
    if kit.pending? && current_user.current_organization.bank_account.nil?
      "We haven't processed your ACH authorization form #{link_to( "(download)", "/forms/artfully_etf_sign_up.pdf")}. If you have not already done so, please submit this form and a voided check by email to support@artful.ly or by fax to (212) 277-8025, ATTN: Artful.ly.".html_safe
    else
      kit.pitch
    end
  end
  
end