require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find_in_tmdb).with('Ted').and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
  end
  describe 'searching for invalid terms' do
    it 'should not find any movies with a blank search' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => ""}
      expect(response).to redirect_to(movies_path)
      expect(flash[:notice]).to be == "Invalid search term"
    end
    it 'should not find any results' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => "iddqd"}
      expect(response).to redirect_to(movies_path)
      expect(flash[:notice]).to be == "No matiching movies were found"
    end
  end
  describe 'searching for valid terms' do
    it 'should show the search tmdb results' do
      allow(Movie).to receive(:find_in_tmdb){[double('movie1'), double('movie2')]}
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end
  end
  describe 'adding to rotten potatoes' do
    it 'should call create a new entry if any checkbox is checked' do
      expect(Movie).to receive(:create_from_tmdb).with("941")
      post :add_tmdb, {:tmdb_movies => {"941": "1"}}
      expect(response).to redirect_to(movies_path)
    end
    it 'should not create a new movie if no checkboxes were checked' do
      expect(Movie).not_to receive(:create_from_tmdb)
      post :add_tmdb, {:tmdb_movies => nil}
      expect(response).to redirect_to(movies_path)
      expect(flash[:notice]).to be == "No movies selected"
    end
  end
end
