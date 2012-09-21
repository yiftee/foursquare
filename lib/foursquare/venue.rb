module Foursquare
  class Venue
    attr_reader :json
    PHOTO_SIZE_LARGE = "500x500"
    PHOTO_SIZE_MEDIUM = "300x300"
    PHOTO_SIZE_SMALL = "100x100"
    PHOTO_SIZE_XSMALL = "36x36"
    
    PHOTO_DEFAULT_SIZE = PHOTO_SIZE_LARGE
    
    
    def initialize(foursquare, json)
      @foursquare, @json = foursquare, json
    end
    
    def fetch
      @json = @foursquare.get("venues/#{id}")["venue"]
      self
    end

    def id
      @json["id"]
    end

    def name
      @json["name"]
    end

    def contact
      @json["contact"]
    end

    def location
      Foursquare::Location.new(@json["location"])
    end

    def categories
      @categories ||= @json["categories"].map { |hash| Foursquare::Category.new(hash) }
    end

    def verified?
      @json["verified"]
    end

    def checkins_count
      @json["stats"]["checkinsCount"]
    end

    def users_count
      @json["stats"]["usersCount"]
    end

    def todos_count
      @json["todos"]["count"]
    end
    
    def stats
      @json["stats"]
    end
    
    def primary_category
      return nil if categories.blank?
      @primary_category ||= categories.select { |category| category.primary? }.try(:first)
    end
    
    # return the url to the icon of the primary category
    # if no primary is available, then return a default icon
    def icon
      primary_category ? primary_category["icon"] : "https://foursquare.com/img/categories/none.png"
    end
    
    def short_url
      @json["shortUrl"]
    end
    
    def photos_count
      fetch if @json["photos"].blank?
      @json["photos"]["count"]
    end
    
    
    def business_photos
      fetch if @json["photos"].blank?
      if(@json["photos"]["count"].to_i == 0 || @json["photos"]["groups"][1]["count"].to_i == 0)
        return []
      end
      photos = []
      @json["photos"]["groups"][1]["items"].each do |item|   
          photos << item["prefix"] + PHOTO_DEFAULT_SIZE + item["suffix"]      
      end
    end
    
    def icon
    
    end
    
    
    
    def all_photos
      fetch if @json["photos"].blank?
      if(@json["photos"]["count"].to_i == 0)
        return []
      end
      photos = []
      @json["photos"]["groups"].each do |g|
        g["items"].each do |item|
          photos << item["prefix"] + PHOTO_DEFAULT_SIZE + item["suffix"]
        end
      end
      
      return photos
    end
    
    # count the people who have checked-in at the venue in the last two hours
    def here_now_count
      fetch unless @json.has_key?("hereNow")
      @json["hereNow"]["count"]
    end
    
    # returns a list of checkins (only if a valid oauth token from a user is provided)
    # https://developer.foursquare.com/docs/venues/herenow.html
    # options: limit, offset, aftertimestamp
    def here_now_checkins(options={:limit => "50"})
      @foursquare.get("venues/#{id}/herenow", options)["hereNow"]["items"].map do |item|
        Foursquare::Checkin.new(@foursquare, item)
      end
    end
    
  end
end
