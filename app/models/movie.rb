require 'themoviedb'

class Movie < ActiveRecord::Base
  
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end

  class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    movies = []
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562") 
    begin
      Tmdb::Movie.find(string).each do |mov|
        movies.push({:title => mov.title, :rating => self.get_rating(mov.id), :release_date => mov.release_date})
      end
      return movies
    rescue NoMethodError => tmdb_gem_exception
      if Tmdb::Api.response['code'] == '401'
        raise Movie::InvalidKeyError, 'Invalid API key'
      else
        raise tmdb_gem_exception
      end
    end
  end
  
  def self.get_rating(tmdb_id)
    rating = ""
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    Tmdb::Movie.releases(tmdb_id)["countries"].each do |loc|
      if loc["iso_3166_1"] == "US"
        rating =  loc["certification"]
        break
      end
    end
    return rating
  end

end
