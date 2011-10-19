module ImportsHelper

  def describe_import_status(import)
    descriptions = {
      "pending" => "This import is pending your approval.",
      "approved" => "You have approved this import and it will be procesed soon.",
      "importing" => "Artful.ly is currently importing this file.",
      "imported" => "This import is complete."
    }
    descriptions[import.status]
  end

end
