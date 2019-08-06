class MoviesController < ApplicationController
  before_action :set_movie, only: %I[show update destroy]
  PAGE_SIZE = 20
  PERMITED_PARAMS = %I[
    title_local
    title_original
    description
    year_of_release
    rating
    cover_image
  ]
  PERMITED_PARAMS << { countries_of_production: [] }
  PERMITED_PARAMS << { genres: [] }
  PERMITED_PARAMS.freeze

  FILTERING_PARAMS = %I[
    title_local
    title_original
    year_of_release
    countries_of_production
    rating
    genres
  ].freeze

  MAPPING_PARAMS = {
    genres: ->(arr) { Genre.map! arr },
    countries_of_production: ->(arr) { Country.where name: arr }
  }.freeze

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
    @movie.cover_image.purge if @movie.cover_image.attached?
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def movie_params
    map_params params.fetch(:movie, {}).permit(PERMITED_PARAMS)
  end

  def map_params(params)
    MAPPING_PARAMS.each do |param, f|
      params[param] = f.call(params[param]) unless params[param].nil?
    end
    params
  end
end
