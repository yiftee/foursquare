module Foursquare
  class VenueProxy
    def initialize(foursquare)
      @foursquare = foursquare
    end

    def find(id)
      Foursquare::Venue.new(@foursquare, @foursquare.get("venues/#{id}")["venue"])
    end

    def search(options={})
      raise ArgumentError, "You must include :ll or :near" unless options[:ll] || options[:near] || (options[:sw] && options[:ne])
      venues = []
      response = @foursquare.get('venues/search', options)["venues"].each do |v|
        venues << Foursquare::Venue.new(@foursquare, v)
      end
      venues
      
    end

    def explore(options={})
      raise ArgumentError, "You must include :ll or :near" unless options[:ll] || options[:near] 
      venues = []
      response = @foursquare.get('venues/explore', options)["groups"]["items"].each do |v|
        venues << Foursquare::Venue.new(@foursquare, v["venue"])
      end
      venues
      
    end

    def trending(options={})
      search_group("trending", options)
    end

    def favorites(options={})
      search_group("favorites", options)
    end

    def nearby(options={})
      search_group("nearby", options)
    end

    private

    def search_group(name, options)
      raise ArgumentError, "You must include :ll" unless options[:ll]
      response = @foursquare.get('venues/search', options)["groups"].detect { |group| group["type"] == name }
      response ? response["items"].map do |json|
        Foursquare::Venue.new(@foursquare, json)
      end : []
    end
  end
end
