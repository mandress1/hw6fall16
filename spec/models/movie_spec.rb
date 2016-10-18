
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(NoMethodError)
        allow(Tmdb::Api).to receive(:response).and_return({'code' => '401'})
        expect { Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  describe 'searching for movies' do
    it 'should return all movies whose titles contain the serach terms' do
      search_terms = "lethal weapon"
      Movie.find_in_tmdb(search_terms).each {|movie| expect(movie[:title].downcase).to include(search_terms)}
    end
    it 'should not find any movies with the search terms' do
      search_terms = "iddqd"
      expect(Movie.find_in_tmdb(search_terms)).to be_empty
    end
  end
  describe 'getting all ratings' do
    it "should return all ratings options" do
      rating_options = %w(G PG PG-13 NC-17 R NR)
      expect(Movie.all_ratings).to match_array(rating_options)
    end
  end
end
