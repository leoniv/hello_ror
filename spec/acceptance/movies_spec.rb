require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Movies' do
  let(:countries) do
    %w[Italy Franсe Russia].each_with_object({}) do |name, hash|
      hash[name.downcase.to_sym] = create(:country, name: name)
    end
  end

  let(:genres) do
    {
      comedy: create(:genre, name: 'Comedy'),
      action: create(:genre, name: 'Action'),
      crime: create(:genre, name: 'Crime')
    }
  end

  def movies(count = 1, countries = [], genres = [], **attributes)
    @movies ||= create_list(:movie, count,
                            **attributes.merge(
                                countries_of_production: countries,
                                genres: genres
                              ))
  end
  alias_method :cook_movies, :movies

  def parsed_body
    JSON.parse response_body
  end

  def body_map(key)
    parsed_body.map { |item| item[key.to_s] }
  end

  get '/movies' do
    explanation 'Listing movies'

    def self.page_size
      MoviesController::PAGE_SIZE
    end
    delegate :page_size, to: :class

    context '200' do
      def do_request(*args, **opts)
        super
        expect(status).to eq 200
      end

      context "Listing is issued by pages with #{page_size} movies on a page" do
        before :example do
          cook_movies 30
        end

        example "On default returns first page" do
          do_request

          expect(parsed_body.size).to be page_size
        end

        example 'Parameter :page specifies offset of movies listing' do
          params = {
            page: 2
          }
          do_request params

          expect(parsed_body.size).to be(30 - page_size)
        end
      end

      context 'Listing can be sorted with parameter :sort_by' do
        let(:movies) do
          [2, 0, 1].map do |i|
            create(:movie, rating: i, year_of_release: 1990 + i)
          end
        end

        before :example do
          movies
        end

        context 'Sorting by year of release' do
          example 'Ascending sorting' do
            params = {
              sort_by: 'year_of_release'
            }

            do_request params
            expect(body_map 'year_of_release').to eq [1990, 1991, 1992]
          end

          example 'Descending sorting' do
            params = {
              sort_by: 'year_of_release:desc'
            }

            do_request params
            expect(body_map 'year_of_release').to eq [1992, 1991, 1990]
          end
        end

        context 'Sorting by rating' do
          example 'Ascending sorting' do
            params = {
              sort_by: 'rating'
            }

            do_request params
            expect(body_map 'rating').to eq [0, 1, 2]
          end

          example 'Descending sorting' do
            params = {
              sort_by: 'rating:desc'
            }

            do_request params
            expect(body_map 'rating').to eq [2, 1, 0]
          end
        end
      end

      describe 'Filtering' do
        before :example do
          cook_movies
        end

        let(:expected_movie) do
          create(:movie,
                 title_local: 'expected movie',
                 title_original: 'expected movie',
                 countries_of_production: countries.values,
                 genres: [genres[:comedy]],
                 year_of_release: 2019,
                 rating: 7)
        end

        def cook_movies
          super 3, rating: 3, year_of_release: 1990
          expected_movie
        end

        parameter :title_local, 'Where local title of movie like string'
        parameter :title_original, 'Where original title of movie like string'
        parameter :year_of_release_from,
          'Where year of release more or equal number'
        parameter :year_of_release_to,
          'Where year of release less or equal number'
        parameter :rating_from,
          'Where rating more or equal number'
        parameter :rating_to,
          'Where rating less or equal number'
        parameter :countries_of_production,
          'Where countries of production includes country like name'
        parameter :genres, 'Where genres crossing with names',
          method: :param_genres

        let(:title_local) { 'expected%' }
        let(:title_original) { '%movie' }
        let(:year_of_release_from) { 2019 }
        let(:year_of_release_to) { 2019 }
        let(:rating_from) { 7 }
        let(:rating_to) { 7 }
        let(:countries_of_production) { 'Russia' }
        let(:param_genres) { %w[comedy crime] }

        context 'Validate query parameters', document: false do
          subject { params }
          its(:keys) { should match_array(Movie.filter.scopes) }
        end

        example_request 'Listing can be filtred' do
          explanation 'One parameter generate one'\
            ' condition. All conditions are concatenated by AND statment'

          expect(body_map :title_local).to eq ['expected movie']
        end
      end
    end
  end
end
