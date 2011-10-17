class ImportsController < ApplicationController

  def approve
    @import = current_user.imports.find(params[:id])
    @import.approve!
    Delayed::Job.enqueue @import

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
        :s3_etag   => params[:etag]
      redirect_to @import
    else
      @import = Import.new
    end
  end

  def create
    @import = Import.new(params[:import])

    if @import.save
      redirect_to import_path(@import)
    else
      render :new
    end
  end

end
