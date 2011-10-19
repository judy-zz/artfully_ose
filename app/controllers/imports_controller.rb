class ImportsController < ApplicationController

  def index
    @imports = current_user.imports.all
  end

  def approve
    @import = current_user.imports.find(params[:id])
    @import.approve!

    flash[:notice] = "Your file has been entered in the import queue. This process may take some time."
    redirect_to root_path
  end

  def show
    @import = current_user.imports.find(params[:id])
    @offset = params[:offset] ? params[:offset].to_i : 0
    @length = params[:length] ? params[:length].to_i : 5
  end

  def new
    if params[:bucket].present? && params[:key].present?
      @import = current_user.imports.create! \
        :s3_bucket => params[:bucket],
        :s3_key    => params[:key],
        :s3_etag   => params[:etag],
        :status    => "caching"
      @import.caching!
      redirect_to @import
    else
      @import = Import.new
    end
  end

  def create
    @import = Import.new(params[:import])
    @import.user = current_user

    if @import.save
      redirect_to import_path(@import)
    else
      render :new
    end
  end

  def destroy
    @import = current_user.imports.find(params[:id])
    @import.destroy
    redirect_to imports_path
  end

end
