module RMeaningTool
  MT_BASE_URL = "http://ws.meaningtool.com/0.1/trees"

  class Result
    attr_reader :status_errcode, :status_message, :data

    def initialize(status_errcode, status_message, data)
      @status_errcode = status_errcode
      @status_message = status_message
      @data           = data
    end
  end


  class Client

    def initialize(api_key, tree_key, base_url=MT_BASE_URL)
    end
    
    def get_categories(source, input, options = {})
    end

    def get_tags(source, input, options = {})
    end
  end
end
