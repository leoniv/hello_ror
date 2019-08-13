require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Movies' do
  let(:countries) do
    %w[Italy Franсe Russia].each_with_object({}) do |name, hash|
      hash[name.downcase] = create(:country, name: name)
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

  get '/movies' do
    explanation 'Listing movies'

    context "Listing is issued by pages with"\
            " #{MoviesController::PAGE_SIZE} movies on a page" do
      before :example do
        cook_movies 30
      end

      example "On default returns first page" do
        do_request

        expect(status).to eq 200
        expect(parsed_body.size).to be MoviesController::PAGE_SIZE
      end

      example 'Parameter :page specifies offset of movies listing' do
        params = {
          page: 2
        }
        do_request params

        expect(status).to eq 200
        expect(parsed_body.size).to be(30 - MoviesController::PAGE_SIZE)
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

      def body_map(key)
        parsed_body.map { |item| item[key] }
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
  end
end
