class ImportsController < ArtfullyOseController

  before_filter { authorize! :create, Import }
  before_filter :set_import_type

  def index
    @imports = organization.imports.all
  end

  def approve
    @import = organization.imports.find(params[:id])
    @import.approve!

    flash[:notice] = "Your file has been entered in the import queue. This process may take some time."
    redirect_to root_path
  end

  def show
    @import = organization.imports.find(params[:id])
    @offset = params[:offset] ? params[:offset].to_i : 0
    @length = params[:length] ? params[:length].to_i : 5
  end

  def new
    if params[:bucket].present? && params[:key].present?
      @import = organization.imports.create \
        :s3_bucket => params[:bucket],
        :s3_key    => params[:key],
        :s3_etag   => params[:etag],
        :status    => "caching",
        :user_id   => current_user.id
      @import.caching!
      redirect_to @import
    else
      @import = Import.new
    end
  end

  def create
    @import = Import.new(params[:import])
    @import.user = current_user
    @import.organization = organization

    if @import.save
      redirect_to import_path(@import)
    else
      render :new
    end
  end

  def destroy
    @import = organization.imports.find(params[:id])
    @import.destroy
    redirect_to imports_path
  end

  def template
    columns = ImportPerson::FIELDS.map { |field, names| names.first }
    csv_string = CSV.generate { |csv| csv << columns }
    send_data csv_string, :filename => "Artfully-Import-Template.csv", :type => "text/csv", :disposition => "attachment"
  end

  protected

    def organization
      current_user.current_organization
    end
    
    def set_import_type
      @import_type = params[:import_type]
    end

end
