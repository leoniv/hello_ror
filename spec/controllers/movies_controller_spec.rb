# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  VALID_ATTRIBUTES = {
    title_local: 'Doom local',
    title_original: 'Doom original',
    description: 'description text',
    year_of_release: 2018,
    rating: 7,
    genres: %w[comedy action trash],
    cover_image: nil
  }

  let(:cover_image_file) do
    Tempfile.new('.png') do |f|
      f.write('FAKE IMG')
    end
  end

  let(:cover_image) { fixture_file_upload cover_image_file }

  let(:valid_attributes) do
    VALID_ATTRIBUTES.merge cover_image: cover_image,
                           countries_of_production: countries.map(&:name)
  end

  let(:minimal_attributes) { { title_local: 'Doom local' } }

  let(:countries) do
    %w[Italy Franch Russia].map { |name| create :country, name: name }
  end

  let(:invalid_attributes) { { rating: 100 } }

  let(:valid_session) { {} }

  let(:movie) { create :movie }

  let(:be_expected_body) do
    match('id' => be > 0,
          'title_local' => 'Doom local',
          'title_original' => 'Doom original',
          'description' => 'description text',
          'year_of_release' => 2018,
          'countries_of_production' => match_array(%w[Italy Franch Russia]),
          'rating' => 7,
          'genres' => %w[comedy action trash],
          'cover_image' => match(%r{\/blobs/\S+}i),
          'created_at' => match(/\d{4}-\d{2}-\d{2}T\S+/),
          'updated_at' => match(/\d{4}-\d{2}-\d{2}T\S+/))
  end

  let(:be_expected_movie) do
    have_attributes('id' => be > 0,
                    'title_local' => 'Doom local',
                    'title_original' => 'Doom original',
                    'description' => 'description text',
                    'year_of_release' => 2018,
                    'countries_of_production' => match_array(countries),
                    'rating' => 7,
                    'genres' => match_array(Genre.where name: %w[comedy action trash]),
                    'cover_image' => be_attached,
                    'created_at' => be_a(Time),
                    'updated_at' => be_a(Time)
                  )
  end

  def parsed_body
    JSON.parse response.body
  end

  describe 'constants are defined' do
    it 'PAGE_SIZE' do
      MoviesController::PAGE_SIZE.should be 20
    end

    it 'PERMITED_PARAMS' do
      MoviesController::PERMITED_PARAMS.should match_array\
        [
          :title_local,
          :title_original,
          :description,
          :year_of_release,
          { countries_of_production: [] },
          :rating,
          { genres: [] },
          :cover_image,
        ]
    end

    it 'FILTERING_PARAMS' do
      MoviesController::FILTERING_PARAMS.should match_array\
        %I[
          title_local
          title_original
          year_of_release
          countries_of_production
          rating
          genres
        ]
    end

    describe 'MAPPING_PARAMS' do
      subject { MoviesController::MAPPING_PARAMS }

      it 'is hash of executables' do
        expect(MoviesController::MAPPING_PARAMS).to match(
          genres: respond_to(:call),
          countries_of_production: respond_to(:call)
        )
      end

      it '[:generes] mapping [String] to [Genre]' do
        expect(Genre).to receive(:map!).with([1, 2, 3]) { %w[1 2 3] }
        expect(subject[:genres].call([1, 2, 3])).to eq(%w[1 2 3])
      end

      it '[:countries_of_production] mapping [String] to [Country]' do
        expect(Country).to receive(:where).with(name: %w[1 2 3]) { [1, 2, 3] }
        expect(subject[:countries_of_production].call(%w[1 2 3])).to\
          eq [1, 2, 3]
      end
    end
  end

  describe 'helpers' do
    describe '#map_params' do
      it 'mapping :genres collection' do
        params = { genres: ['foo', 'bar', nil] }
        expect(subject.send(:map_params, params)[:genres]).to\
          match_array [
            be_a(Genre).and(have_attributes name: 'foo'),
            be_a(Genre).and(have_attributes name: 'bar')
          ]
      end

      it 'mapping :countries_of_production collection' do
        foo = create(:country, name: 'foo')
        bar = create(:country, name: 'bar')
        params = { countries_of_production: ['foo', 'bar', 'baz', nil] }
        expect(subject.send(:map_params, params)[:countries_of_production])
          .to match_array [foo, bar]
      end
    end

    describe 'movie_params' do
      it 'fetching and mapping permitted request parameters' do
        expect(subject.params).to receive(:fetch)
          .with(:movie, {}) { subject.params }
        expect(subject.params).to receive(:permit)
          .with(MoviesController::PERMITED_PARAMS) { subject.params }
        expect(subject).to receive(:map_params)
          .with(subject.params) { :permitted_mapped_params }
        expect(subject.send(:movie_params)).to eq :permitted_mapped_params
      end
    end
  end

  describe 'GET #index' do

    it 'returns a success response' do
      item = create(:movie)
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
      expect(parsed_body[0]).to eq(
        (JSON.parse item.to_json).merge(
            'countries_of_production' => [],
            'genres' => [],
            'cover_image' => nil)
      )
    end

    describe 'paginate' do
      before :example do
        create_list(:movie, MoviesController::PAGE_SIZE + 3)
      end

      context 'parameters' do
        it 'without parameters returns first page' do
          get :index, params: { }, session: valid_session
          expect(parsed_body.size).to eq MoviesController::PAGE_SIZE
        end

        [MoviesController::PAGE_SIZE, 3].each_with_index do |expected_size, page|
          it ':page defines number of page for paginate' do
            page += 1
            get :index, params: { page: page }, session: valid_session
            expect(response).to be_successful
            expect(parsed_body.size).to eq expected_size
          end
        end
      end
    end

    describe 'sorting' do
      before :example do
        expect(movies.empty?).to be(false), 'cretate some movies'
      end

      let(:movies) do
        [1, 0, 2].to_a.map do |i|
          create(:movie, year_of_release: 1990 + i, rating: i)
        end
      end

      context 'parameter :sort takes attribute by which to sort' do
        %w[year_of_release rating].each do |attr|
          [nil, ':desc'].each do |desc|
            it "#{desc.nil? ? 'ascend' : 'descend'} `sort=#{attr}#{desc}'" do
              get :index, params: { sort: [attr + desc.to_s] }
              expect(parsed_body.map { |movie| movie[attr] }).to eq movies
                .map(&:"#{attr}").sort.send(desc.nil? ? :itself : :reverse)
            end
          end
        end

        it 'ingnore invalid attributes' do
          get :index, params: { sort: %w[invalid value] }
          expect(response).to be_successful
        end
      end
    end

    describe 'filtering' do
      it 'should has fiters' do
        skip 'FIXME'
      end
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: movie.to_param }, session: valid_session
      expect(response).to be_successful
      expect(parsed_body).to eq(
        (JSON.parse movie.to_json).merge(
          'countries_of_production' => [],
          'genres' => [],
          'cover_image' => nil
        )
      )
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new' do
        expect do
          post :create, params: { movie: minimal_attributes },\
                        session: valid_session
        end.to change(Movie, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(movie_url(Movie.last))
      end

      describe 'renders a JSON response with the new movie' do
        it 'with all attributes set' do
          post :create, params: { movie: valid_attributes },\
                        session: valid_session
          expect(response).to have_http_status(:created)
          expect(parsed_body).to be_expected_body
        end

        it 'with minimal attributes set' do
          post :create, params: { movie: minimal_attributes },\
                        session: valid_session
          expect(response).to have_http_status(:created)
          expect(parsed_body).to include('title_local' => 'Doom local')
        end
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new movie' do
        post :create, params: { movie: invalid_attributes },\
                      session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        valid_attributes
      }

      it 'updates the requested movie' do
        put :update, params: { id: movie.to_param, movie: new_attributes },\
          session: valid_session
        movie.reload
        expect(movie).to be_expected_movie
      end

      it 'renders a JSON response with the movie' do
        put :update, params: { id: movie.to_param, movie: new_attributes },\
          session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        expect(parsed_body).to be_expected_body
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the movie' do
        put :update, params: { id: movie.to_param, movie: invalid_attributes },\
          session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested movie' do
      movie.should be movie
      expect do
        delete :destroy, params: { id: movie.to_param }, session: valid_session
      end.to change(Movie, :count).by(-1)
    end
  end
end
