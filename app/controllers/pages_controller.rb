class PagesController < ActionController::Base
  skip_before_filter :authenticate_user!

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