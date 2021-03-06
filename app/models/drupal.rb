class Drupal < CMS

	
	def self.articles params
		cache = true;
	  cached_articles = Rails.cache.fetch("sections/#{params.to_s}", expires_in: 1.hour) do
		cache = false;
		
		  language = language_parameter params['language']
		  language = default_language if language.blank?
		raise "Requested language is not enabled"	if !languages().include?(language)
		
		  options = {}
		articles = {}

		articlesUrgent = {}
		articlesActual = {}
		articlesCompany = {}
		
		  categories_string = Setting.categories
		  most_recent_articles = nil
		  
		  if(!categories_string.blank? && !params['categories'].blank? && params['categories']=='true' && Setting.consolidated_categories.blank?)
			  categories = YAML.load(categories_string)
			  categories[language] = [] if categories[language].nil?
			  options[:post_types] = categories[language].join(',')
		  if(!Setting.consolidated_categories)
			options[:categorized]='true'
		  end
		  
		  most_recent_articles_params = params.dup
		  most_recent_articles_params['categories'] = nil
		  
		  most_recent_articles = articles(most_recent_articles_params)[:results]
		  end

			url = get_url language, "articles/urgent?", options
			urlActual = get_url language, "articles/actual?", options
			urlCompany = get_url language, "articles/company?", options

			articles = get_articles url
			articlesActual = get_articles urlActual
			articlesCompany = get_articles urlCompany



			if language == 'tj'
				articles['categoriesOrder'] = { "Фаврӣ" => "1", "Муҳим" => "2", "Навгонии ширкатҳо" => "3" } 
				#articles['categoriesOrder'] = { "Фаврӣ" : "0" , "Муҳим" : "1" , "Навгонии ширкатҳо" : "2"}
				 articles['categories'] = [ "Фаврӣ", "Муҳим", "Навгонии ширкатҳо"]
				 articles[:results] = {"Фаврӣ":articles[:results], "Муҳим":articlesActual[:results], "Навгонии ширкатҳо":articlesCompany[:results]}
			 elsif language == 'ru'
				articles['categoriesOrder'] = { "Срочно" => "1", "Актуально" => "2", "Новости компаний" => "3" } 
			   articles['categories'] = ["Срочно", "Актуально", "Новости компаний"]
			   articles[:results] = {"Срочно":articles[:results], "Актуально":articlesActual[:results], "Новости компаний":articlesCompany[:results]}
			 else
				articles['categoriesOrder'] = { "Urgent" => "1", "Actual" => "2", "Company" => "3" } 
			   articles['categories'] = ["Urgent", "Actual", "Company"]
			   articles[:results] = {"Urgent":articles[:results], "Actual":articlesActual[:results], "Company":articlesCompany[:results]}
      end



		  if(!most_recent_articles.nil? && !Setting.show_most_recent_articles.nil?)
		  # There maybe a bug where an array is returned, even if categories are enabled
		  if(articles[:results].is_a?(Array))
			articles[:results] = {translate_phrase("most_recent", language) => most_recent_articles}
			articles['categories'] = []
			
		  else
			  articles[:results][translate_phrase("most_recent", language)] = most_recent_articles
			end
			
			articles["categories"].insert(0, translate_phrase("most_recent", language))
		  end
		  
		  articles
	  end
	  
	  logger.debug("/articles.json #{params.to_s} Cache hit") if cache == true
	  logger.debug("/articles.json #{params.to_s} Cache missed") if cache == true
	
       


		return cached_articles
	end


	def self.language_parameter language
	    if(!language.blank?)
	      language = language
	    end

	    return language
	end

	private

	def self.get_url language, path, options = {}
		url = ENV['drupal_url'] 
		
	    
 	    url_string = "#{url}?#{path}"

	    # If there is more than one language specified (or any language at all for backwards compatibility)
	    if(languages().count > 1 && languages().include?(language))
		   url_string = "#{url}#{path}lang=#{language}&limit=10"
  	  end
	    
	    if(!ENV['wp_super_cached_donotcachepage'].blank?)
	    	options[:donotcachepage] = ENV['wp_super_cached_donotcachepage']
	    end

	    options.keys.each do |key|
	    	url_string += "&#{key}=#{options[key]}"
	    end

	    return url_string
	end

	def self.make_request url
		logger.debug("Making request to #{url}")
  		response = HTTParty.get(URI.encode(url), :verify => false)
        #byebug
    begin
	    body = JSON.parse response.body
	  rescue => exception
      logger.debug "Exception parsing JSON from CMS"
      logger.debug "Statement returned"
      logger.debug "---------------------------------------"
      logger.debug response.body
      logger.debug "---------------------------------------"
      raise
    end
	  return body
	end

	def self.get_articles url, extras = {},  version = 1
	    logger.debug("Calling: #{url}")

	    body = make_request url

			#byebug
	    if(body['results'].nil?)
	    	body['results'] = Array.new
	    end
      
	  if(body['categories'].nil?)			
    
        
        body['results'].each do |article|
		  self.extract_images article
			#article['images'] = images
			#article['image_urls'] = image_urls
			
		end

	
  	    results = clean_up_response(body['results'], version)
   	    results = clean_up_for_wordpress results
  	  else
  	    results = {}
  	    body['categories'].each do |category|
    	    if(body['results'][category].blank?)
      	    	results[category] = []
      	    	next
      	  	end

			body['results'][category].each do |article|

				_, images, image_urls = self.extract_images article

				article['images'] = images
				article['image_urls'] = image_urls

			end


    	    results[category] = clean_up_response(body['results'][category], version)
			results[category] = clean_up_for_wordpress results[category]
			logger.debug "hello"
    	  end    	  
  	  end
      
	    response = {start_date: "19700101",
	               end_date: DateTime.now.strftime("%Y%m%d"),
	               total_results: 3,
	               page: "1",
	               results: results
	              }
	   
	    response['categories'] = body['categories'] if !body['categories'].nil?

	    # add in any extras from the call, query string etc.
	    response = response.merge(extras)
	    return response
	end

	def self.language_parameter language
	    if(!language.blank?)
	      language = language
	    end

	    return language
	end

	def self.clean_up_for_wordpress articles	
		articles.each do |article|
		    article['body'] = scrubCDataTags article['body']
   		    article['body'] = scrubScriptTagsFromHTMLString article['body']
		    article['body'] = scrubWordpressTagsFromHTMLString article['body']
		    #article['body'] = cleanUpNewLines article['body']
		    article['body'] = scrubJSCommentsFromHTMLString article['body']
		    article['body'] = scrubSpecialCharactersFromSingleLinesInHTMLString article['body']
		    article['body'] = scrubHTMLSpecialCharactersInHTMLString article['body']
   		    article['body'] = normalizeSpacing article['body']

			article['headline'] = HTMLEntities.new.decode(article['headline'])

			
            article['url'] = "#{base_url}/#{article['id']}" #base_url article['id']
            
			article['body'] = CMS.normalizeSpacing article['body']
		end

		#
		
	    return articles
	end

 	def self.search params
 		language = language_parameter params['language']

 	    query = params['q']

			 
 	    google_search_engine_id = ENV['google_search_engine_id']
 		if(!google_search_engine_id.blank?)
 			logger.debug "Searching google with id: #{google_search_engine_id}"
 			articles_list = search_google_custom query, google_search_engine_id
 			url = get_url "noauth/articles/search?what=#{articles_list.join(',')}", language
 		else
				 url = get_url language, "articles/search?what=#{query}&"
				 
 		end
		 #byebug
 		return get_articles url, {query: query}
 	end



end
