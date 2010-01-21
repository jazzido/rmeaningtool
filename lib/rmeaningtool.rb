require 'restclient'
require 'json'

module RMeaningTool
  #MT_BASE_URL = "http://ws.meaningtool.com/0.1/trees"
  MT_BASE_URL = "http://ws.meaningtool.com/ct/restv0.1"

  class Result
    attr_reader :status_errcode, :status_message, :data

    def initialize(status_errcode, status_message, data)
      @status_errcode = status_errcode
      @status_message = status_message
      @data           = data
    end
  end


  class Client

    ALLOWED_ADDITIONALS = %w{top-terms classifiers classifiers-top-terms}
    
    DEFAULT_HEADERS = { 
      :content_type => 'application/x-www-form-urlencoded; charset=UTF-8',
      :accept_charset => 'utf-8',
      :accept => 'application/json'
    }
    
    def initialize(api_key, tree_key, base_url=MT_BASE_URL)
      @api_key = api_key
      @tree_key = tree_key
      @base_url = "#{base_url}/#{tree_key}"
      puts @base_url
    end

    
    def get_categories(source, input, options = {})
      
      validate_parameters(source, input, options)
      
      url = "#{@base_url}/categories.json"

      headers = {}
      data = { 
        :source  => source,
        :input   => input,
        :api_key => @api_key
      }

      if options[:url_hint]
        data[:url_hint] = options[:url_hint]
      end
      
      if options[:additionals]
        data[:additionals] = options[:additionals].uniq.join(',')
      end

      if options[:content_language]
        headers[:content_language] = options[:content_language].downcase
      end


      parse_result(req(:post, url, data, headers))
      
    end

    def get_tags(source, input, options = {})
    end

    private

    def req(method, url, data, headers = {})
      unless method == :get || method == :post
        raise ArgumentError, "method should be :get or :post"
      end
      headers.merge!(DEFAULT_HEADERS)
      RestClient.send(method, url, data, headers)
    end

    def parse_result(raw)
      if raw == 'bad api key' # workaround: The Invalid API key error response doesn't return a valid json response.
        raw = '{"status": "error", "message": "Invalid API key", "data": {}, "errcode": "UserKeyInvalid"}'
      end
      result_dict = JSON.load(raw)

      status = result_dict['status']
      status_errcode = result_dict['status_errcode']
      status_message = result_dict['message']
      data = result_dict['data']
      if status == 'ok'
        Result.new(status_errcode, status_message, data)
      else
        raise MeaningtoolException, status_message
      end
      
    end

    def validate_url(url)
      unless url =~ /(^(http|https):\/\/[a-z0-9]+([-.]{1}[a-z0-9]*)+. [a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
        raise ArgumentError, "#{url} is not a valid url"
      end
    end

    def validate_parameters(source, input, options)
      unless %w{text url html}.include? source
        raise ArgumentError, "The 'source' is invalid" 
      end
      
      if source == 'url'
        validate_url(input)
      end

      if options[:url_hint]
        validate_url(options[:url_hint])
      end
      
      if options[:content_language] and options[:content_language].size != 2
        raise ArgumentError, "The content_language should be 2 chars" 
      end
      
      if options[:additionals]
        unless options[:additionals].all? { |a| ALLOWED_ADDITIONALS.include? a }
          raise ArgumentError, "The 'additionals' is invalid"
        end
      end
    end
  end

  class MeaningtoolException < RuntimeError
  end

end
