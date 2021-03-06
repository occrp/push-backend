class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Set the cms mode for all controller requests
  before_action :check_for_valid_cms_mode
  DOUBLE_ESCAPED_EXPR = /%25([0-9a-f]{2})/i

<<<<<<< HEAD

  Figaro.load
  #This is just a passthrough for basic GET commands. Takes a URL, calls it, and returns the body.
  #This should conceivably cache responses at some point
  #Should also require auth token
=======
  # This is just a passthrough for basic GET commands. Takes a URL, calls it, and returns the body.
  # This should conceivably cache responses at some point
  # Should also require auth token
>>>>>>> 0930adbdfb041837e23849e58e3e4182238a5b74
  def passthrough
    # We only want this to be for Newscoop
    # Nevermind, we want it for CINS too
    # Screw it, we'll generalize it out to an environment variable

    if ENV["proxy_images"].blank? || ENV["proxy_images"].downcase != "true"
      render plain: "Proxy images not enabled for this installation: proxy_images=#{ENV['proxy_images']}"
      return
    end

    url = params["url"]

    # For Newscoop, the images are returned as an API call, not a permalink. It's not smart, but it's what they do.
    if ENV["cms_mode"] == "newscoop"
      url += "&ImageHeight=#{params['ImageHeight']}" if !params["ImageHeight"].nil?
      url += "&ImageWidth=#{params['ImageWidth']}" if !params["ImageWidth"].nil?
      url += "&ImageId=#{params['ImageId']}" if !params["ImageId"].nil?
    end

    if allow_to_proxy?(url)
      image_response = passthrough_image url

      send_data image_response[:body], type: image_response[:content_type], disposition: "inline", layout: false
    else
      render plain: "Error retreiving #{url}, the host does not match any allowed uris."
    end
  end
<<<<<<< HEAD
  
  




  def passthrough_image url
    cached = true


    image_response = Rails.cache.fetch(url, expires_in: 5.minutes) do
      url_encoded = url
      if url_encoded == URI.encode(url_encoded).gsub(DOUBLE_ESCAPED_EXPR, '%\1') 
        while url_encoded != URI.decode(url_encoded) do
          url_encoded = URI.decode(url_encoded)
        end
      
      else 
        while url_encoded != URI.encode(url_encoded).gsub(DOUBLE_ESCAPED_EXPR, '%\1') do
          
          url_encoded = URI.encode(url_encoded).gsub(DOUBLE_ESCAPED_EXPR, '%\1')
        end
          
      end
      url_encoded = URI.encode(url_encoded).gsub(DOUBLE_ESCAPED_EXPR, '%\1')
        
      raw_response = HTTParty.get(url_encoded,:verify => false)
      content_type = raw_response.headers['content-type']
      

      if (content_type.blank?)
       fm = FileMagic.new(FileMAgic::MAGIC_MIME)
       mime_type = fm.buffer(raw_response.body) 
       content_type = mime_type
      end

      image_response = {body: raw_response.body, content_type: raw_response.headers['content-type']}
      cached = false
      image_response
    end
    #byebug
=======

  def passthrough_image(url)
    cached = true
    image_response = Rails.cache.fetch(url, expires_in: 5.minutes) do
      raw_response = HTTParty.get(url)

      image_response = { body: raw_response.body, content_type: raw_response.headers["content-type"] }
      cached = false
      image_response
    end

>>>>>>> 0930adbdfb041837e23849e58e3e4182238a5b74
    logger.info("Cache for image #{url} hit: #{cached == true ? "true" : "false"}")
    image_response
  end

  def check_for_valid_cms_mode
<<<<<<< HEAD
    @cms_mode
    case ENV['cms_mode']
      when "occrp-joomla"
        @cms_mode = :occrp_joomla
      when "wordpress"
        @cms_mode = :wordpress
      when "newscoop"
        @cms_mode = :newscoop
      when "cins-codeigniter"
        @cms_mode = :cins_codeigniter
      when "blox"
        @cms_mode = :blox
      when "drupal"
        @cms_mode = :drupal
      else
        raise "CMS type #{ENV['cms_mode']} not valid for this version of Push."
    end
=======
    @cms_mode = helpers.check_for_valid_cms_mode
>>>>>>> 0930adbdfb041837e23849e58e3e4182238a5b74
  end
  #   case ENV["cms_mode"]
  #   when "occrp-joomla"
  #     @cms_mode = :occrp_joomla
  #   when "wordpress"
  #     @cms_mode = :wordpress
  #   when "newscoop"
  #     @cms_mode = :newscoop
  #   when "cins-codeigniter"
  #     @cms_mode = :cins_codeigniter
  #   when "blox"
  #     @cms_mode = :blox
  #   when "snworks"
  #     @cms_mode = :snworks
  #   else
  #     raise "CMS type #{ENV['cms_mode']} not valid for this version of Push."
  #   end
  # end

  def cms_url
    case ENV["cms_mode"]
    when "occrp-joomla"
      url = ENV["occrp_joomla_url"]
    when "wordpress"
      url = ENV["wordpress_url"]
    when "newscoop"
      url = ENV["newscoop_url"]
    when "cins-codeigniter"
      url = ENV["codeigniter_url"]
    when "blox"
<<<<<<< HEAD
      url = ENV['blox_url']
    when "drupal"
      url = ENV['drupal_url']
=======
      url = ENV["blox_url"]
    when "snworks"
      url = ENV["snworks_url"]
>>>>>>> 0930adbdfb041837e23849e58e3e4182238a5b74
    else
      raise "CMS type #{ENV['cms_mode']} not valid for this version of Push."
    end

    url
  end

  def allow_to_proxy?(url)
    link_uri = Addressable::URI.parse(url)
    base_uri = Addressable::URI.parse(cms_url)

    if link_uri.host.nil?
      link_uri.host = base_uri.host
      link_uri.scheme = base_uri.scheme
    end

<<<<<<< HEAD
    link_host = link_uri.host.gsub('www.', '')
    base_host = base_uri.host.gsub('www.', '')
    

    # We check if there's optional urls listed in the secret.env file
    if(link_host == base_host || allowed_proxy_hosts().include?(link_host))

=======
    link_host = link_uri.host.gsub("www.", "")
    base_host = base_uri.host.gsub("www.", "")

    # We check if there's optional urls listed in the secret.env file
    if link_host == base_host || allowed_proxy_hosts().include?(link_host)
>>>>>>> 0930adbdfb041837e23849e58e3e4182238a5b74
      return true
    else
      logger.info("Invalid image proxy request #{link_host} vs. #{base_host}")
    end

    logger.info("Invalid image proxy request #{link_host} vs. #{base_host}")
    false
  end

  def allowed_proxy_hosts
    return [] unless ENV.has_key? "allowed_proxy_subdomains"

    allowed_proxy_subdomains = ENV["allowed_proxy_subdomains"]
    allowed_proxy_subdomains = allowed_proxy_subdomains.gsub("[", "")
    allowed_proxy_subdomains = allowed_proxy_subdomains.gsub("]", "")
    allowed_hosts = allowed_proxy_subdomains.split(",")
    allowed_hosts.map! { |host| host.gsub('"', "").strip }


    allowed_hosts
  end

  def heartbeat
    # OK, this checks a bunch of stuff
    # Specifically we have to go through each language and call "articles" on it, that should be good enough for now

    categories = ["true", "false"]
    @response = []

    begin
      if ENV["languages"].nil?
        categories.each do |categorized|
          @response = sample_call nil, categorized
        end
      else
        languages = ENV["languages"].delete('"').split(",")

        # Run through each language, and each iteration of categories
        languages.each do |language|
          categories.each do |categorized|
            @response = sample_call language, categorized
          end
        end
      end
    rescue => e
      message = "Heartbeat failed: #{e}"

      if params.has_key?("v") && params["v"] == "true"
        message += "\n\nBacktrace\n"
        message += "----------------------"
        e.backtrace.each { |line| message += "\n#{line}" }
        message += "\n----------------------\n"
      end

      logger.debug message
      respond_to do |format|
        format.json { render json: { status: message, code: "503" } }
        format.html { render message, status: 503 }
      end
      return
    end

    respond_to do |format|
      format.json { render json:  { status: "Success", code: "200" } }
      format.html { render plain: "Success" }
    end
  end

  def sample_call(language, category)
    params = {}
    params["language"] = language unless language.nil?
    params["categories"] = category unless category.nil?

    case @cms_mode
    when :occrp_joomla
      response = ArticlesController.new.get_occrp_joomla_articles(params)
    when :wordpress
      response = Wordpress.articles(params)
      # @response['results'] = clean_up_response @response['results']
    when :newscoop
      response = Newscoop.articles(params)
    when :cins_codeigniter
      response = CinsCodeigniter.articles(params)
    end

    response.to_json
  end

  # Error code 0 is usually what indicates bad things happend
  def return_error(message, code = 0)
    error = { code: code, message: message }
    error.to_json
  end
end
