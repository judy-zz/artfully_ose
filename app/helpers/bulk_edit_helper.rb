module BulkEditHelper
  def verbalize_action(bulk_action)
    if bulk_action=='PUT_ON_SALE'
      'putting on sale'
    elsif bulk_action=='TAKE_OFF_SALE'
      'taking off sale'
    elsif bulk_action=='DELETE'
      'deleting'  
    end
  end
end