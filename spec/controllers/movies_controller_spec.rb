require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  let(:valid_attributes) {
    {
      title_local: 'Doom local'
    }
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_session) { {} }

  let(:movie) { create :movie }

  let(:movie_with_attachments) { create :movie_with_attachments }

  def parsed_body
    JSON.parse response.body
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

      it 'PAGE_SIZE is defined' do
        MoviesController::PAGE_SIZE.should be 20
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

    describe 'order' do
      before :example do
        create(:movie, year_of_release: 1991, rating: 1)
        create(:movie, year_of_release: 1990, rating: 2)
        create(:movie, year_of_release: 1992, rating: 0)
      end

      context 'invalid value' do
        it 'will be ignored' do
          get :index, params: { order_by: 'invalid value' }
          expect(response).to be_successful
        end
      end

      context 'ascending by' do
        it '-year_of_release' do
          get :index, params: { order_by: '-year_of_release' }
          expect(parsed_body.map { |hash| hash['-year_of_release'] } )
            .to eq [1990, 1991, 1992]
        end

        it '-rating' do
          get :index, params: { order_by: 'rating' }
          expect(parsed_body.map { |hash| hash['rating'] })
            .to eq [0, 1, 2]
        end
      end

      context 'descending by' do
        it 'year_of_release' do
          get :index, params: { order_by: 'year_of_release ' }
          expect(parsed_body.map { |hash| hash['year_of_release'] } )
            .to eq [1992, 1991, 1990]
        end

        it ':rating' do
          get :index, params: { order_by: 'rating' }
          expect(parsed_body.map { |hash| hash['rating'] })
            .to eq [2, 1, 0]
        end
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: {id: movie.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Movie" do
        expect {
          post :create, params: {movie: valid_attributes}, session: valid_session
        }.to change(Movie, :count).by(1)
      end

      it "renders a JSON response with the new movie" do
        post :create, params: {movie: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(movie_url(Movie.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new movie" do
        post :create, params: {movie: invalid_attributes}, session: valid_session
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
