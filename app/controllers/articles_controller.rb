class ArticlesController < ApplicationController

  def index

    url = ENV['occrp_joomla_url']

    # Shortcut
    # We need the request to look like this, so we have to get the correct key.
    # At the moment it makes the call twice. We need to cache this.
    # response = HTTParty.get(url, headers: {'Cookie' => '6e5451c5a544c9e9a591c2fe3b28408c[lang]=en;'})
    response = HTTParty.get(url, headers: {'Cookie' => get_cookie()})
    body = response.body

    @response = JSON.parse(response.body)
    @response.body = clean_up_response @response.body

    respond_to do |format|
      format.json
    end

  end

  def search
    #http = Net::HTTP.new("joomla-docker-129154.nitrousapp.com")
    #request = Net::HTTP::Get.new("/index.php?option=com_push&format=json&view=articles")
    #uri = URI.parse("http://joomla-docker-129154.nitrousapp.com/index.php?option=com_push&format=json&view=articles")
    #url = "http://joomla-docker-129154.nitrousapp.com/index.php?option=com_push&format=json&view=search&query=#{params[:query]}"
    url = "https://www.googleapis.com/customsearch/v1?key=AIzaSyCahDlxYxTgXsPUV85L91ytd7EV1_i72pc&cx=003136008787419213412:ran67-vhl3y&q=lectures"
    # Shortcut
    response = HTTParty.get(url)
    #For the moment all images are empty, so we'll just leave this here
    url = "https://www.occrp.org/index.html?option=com_push&format=json&view=urllookup&u="
    @response = {items: []}
    links = []
    response['items'].each do |result|
      url << result['link'] + ","
    end

    response = HTTParty.get(url, headers: {'Cookie' => get_cookie()})

    @response = clean_up_response JSON.parse(response.body)

    respond_to do |format|
      format.json
    end
  end

  private

  def get_cookie
    url = "https://www.occrp.org/index.html?option=com_push&format=json&view=urllookup&u="
    response = HTTParty.get(url)
    cookies = response.headers['set-cookie']
    correct_cookie = nil
    cookies.split(', ').each do |cookie|
      if cookie.include? "[lang]"
        return cookie
        break
      end
    end

    return nil
  end

  def clean_up_response articles
    articles.each do |article|
      if article['headline'].blank?
        next
      end

      # If there is no body (which is very prevalent in the OCCRP data for some reason)
      # this takes the intro text and makes it the body text
      if article['body'].nil? || article['body'].empty?
        article['body'] = article['description']
      end
      # Limit description to number of characters since most have many paragraphs

      article['description'] = ActionView::Base.full_sanitizer.sanitize(article['description']).squish
      if article['description'].length > 140
        article['description'] = article['description'].slice(0, 140) + "..."
      end

      # Extract all image urls in the article and put them into a single array.
      article['image_urls'] = []
      elements = Nokogiri::HTML article['body']
      elements.css('img').each do |image|
        image_address = image.attributes['src'].value
        if !image_address.starts_with?("http")
          article['image_urls'] << "https://www.occrp.org/" + image.attributes['src'].value
        else
          article['image_urls'] << image_address
        end
      end

      # Just in case the dates are improperly formatted
      begin
        published_date = DateTime.strptime(article['publish_date'], '%F %T')
      rescue => error
        published_date = DateTime.new(1970,01,01)
      end
      # right now we only support dates on the mobile side, this will be time soon.
      #published_date = result['publish_date'].to_date
      article['publish_date'] = published_date.strftime("%Y%m%d")
    end
    return articles
  end
end
