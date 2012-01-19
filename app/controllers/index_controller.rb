class IndexController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :faq, :pricing, :features, :updates, :sign_up, :sign_up_form]

  def index
    redirect_to admin_root_path if admin_signed_in?
  end

  def login_success
    redirect_to root_path
  end

  def dashboard
    if current_user.is_in_organization?
      @events = current_user.current_organization.events.paginate(:page => params[:page], :per_page => 10)
      @people = current_user.current_organization.people.limit(5)
    end
  end

  def updates
    require 'open-uri'
    require 'nokogiri'

    @posts = []
    doc = Nokogiri::HTML(open('http://www.fracturedatlas.org/site/blog/tag/artfully/'))

    begin
      doc.css('.post').each do |post|
        content = {}
        content[:title] = post.css('h2').first.content
        content[:link] = post.css('h2 a').first['href']
        content[:byline] = post.css('.byline').first.content
        content[:entry] = post.css('.entry').first.content
        @posts << content
      end
    rescue
      logger.info "Pulling in updates from the FA blog on index#updates failed."
      # todo: send to airbrake or exceptional
    end
  end

  def sign_up_form
    render :sign_up_form, :layout => false
  end
end
