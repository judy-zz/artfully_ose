module BulkEditHelper
  def verbalize_action(bulk_action)
    if bulk_action=='Put on Sale'
      'putting on sale'
    elsif bulk_action=='Take off Sale'
      'taking off sale'
    elsif bulk_action=='Delete'
      'deleting'
    end
  end
end