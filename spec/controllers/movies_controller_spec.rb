# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  VALID_ATTRIBUTES = {
    title_local: 'Doom local',
    title_original: 'Doom original',
    description: 'description text',
    year_of_release: 2018,
    countries_of_production: %w[Italy Franch Russia],
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

  let(:valid_attributes) { VALID_ATTRIBUTES.merge cover_image: cover_image}

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  let(:valid_session) { {} }

  let(:movie) { create :movie }

  let(:movie_with_attachments) { create :movie_with_attachments }

  def parsed_body
    JSON.parse response.body
  end

  describe 'constants is defined' do
    it 'PAGE_SIZE' do
      MoviesController::PAGE_SIZE.should be 20
    end

    it 'PERMITED_PARAMS' do
      MoviesController::PERMITED_PARAMS.should eq\
        %I[
          title_local
          title_original
          year_of_release
          countries_of_production
          rating
          genres
          cover_image
        ]
    end

    it 'FILTERING_PARAMS' do
      MoviesController::FILTERING_PARAMS.should eq\
        %I[
          title_local
          title_original
          year_of_release
          countries_of_production
          rating
          genres
        ]
    end
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
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
          it ":page defines number of page for paginate" do
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

    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: {id: movie.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Movie' do
        expect do
          post :create, params: { movie: valid_attributes },\
                        session: valid_session
        end.to change(Movie, :count).by(1)
      end

      it 'renders a JSON response with the new movie' do
        post :create, params: { movie: valid_attributes },\
                      session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(movie_url(Movie.last))
        expect(parsed_body).to\
          include('title_local' => 'Doom local').and\
          include('title_original' => 'Doom original').and\
          include('description' => 'description text').and\
          include('year_of_release' => 2018).and\
          include('countries_of_production' => %w[Italy Franch Russia]).and\
          include('rating' => 7).and\
          include('genres' => %w[comedy action trash])
          include('cover_image' => /\/blobs\/\S+/i).and\
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

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested movie" do
        put :update, params: {id: movie.to_param, movie: new_attributes}, session: valid_session
        movie.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the movie" do
        put :update, params: {id: movie.to_param, movie: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the movie" do
        put :update, params: {id: movie.to_param, movie: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested movie" do
      movie.should be movie
      expect {
        delete :destroy, params: {id: movie.to_param}, session: valid_session
      }.to change(Movie, :count).by(-1)
    end
  end
end
