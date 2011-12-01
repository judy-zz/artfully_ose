module ImportsHelper

  def describe_import_status(import)
    descriptions = {
      "caching" => "Your file is being processed.",
      "pending" => "This import is pending your approval.",
      "approved" => "You have approved this import and it will be procesed soon.",
      "importing" => "Artful.ly is currently importing this file.",
      "imported" => "This import is complete.",
      "failed" => "This import has failed."
    }
    descriptions[import.status]
  end

end
