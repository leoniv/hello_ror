class MoviesController < ApplicationController
  before_action :set_movie, only: %I[show update destroy]
  PAGE_SIZE = 20
  PERMITED_PARAMS = %I[
    title_local
    title_original
    description
    year_of_release
    countries_of_production
    rating
    genres
    cover_image
  ].freeze

  FILTERING_PARAMS = %I[
    title_local
    title_original
    year_of_release
    countries_of_production
    rating
    genres
  ].freeze

  # GET /movies
  def index
    @movies = Movie.paginate(page: params[:page], per_page: PAGE_SIZE)
    render json: @movies
  end

  # GET /movies/1
  def show
    render json: @movie
  end

  # POST /movies
  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      render json: @movie, status: :created, location: @movie
    else
      render json: @movie.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /movies/1
  def update
    if @movie.update(movie_params)
      render json: @movie
    else
      render json: @movie.errors, status: :unprocessable_entity
    end
  end

  # DELETE /movies/1
  def destroy
    @movie.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def movie_params
      params.fetch(:movie, {}).permit PERMITED_PARAMS
    end
end
