require 'themoviedb'

class Movie < ActiveRecord::Base
  
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NR)
  end

  class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    movies = []
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562") 
    begin
      Tmdb::Movie.find(string).each do |mov|
        puts "#{mov.title}:"
        movies.push({:tmdb_id => mov.id, :title => mov.title, :rating => self.get_rating(mov.id), :release_date => mov.release_date})
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
      if loc["iso_3166_1"] == "US" && loc["certification"] != ""
        rating =  loc["certification"]
        break
      end
    end
    rating = "NR" if (rating.empty? or rating == "")
    return rating
  end
  
  def self.create_from_tmdb(tmdb_id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    mov_details = Tmdb::Movie.detail(tmdb_id)
    Movie.create({:title => mov_details["original_title"], :rating => self.get_rating(tmdb_id), :release_date => mov_details["release_date"]})
  end
end
