class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #@movies = Movie.all
    @all_ratings = Movie.all_ratings
    if params.key?(:sort_by) #instead of using order i make use of sort_by
			session[:sort_by] = params[:sort_by] #instead of using order i make use of sort_by, updates the sorting mechanism
		elsif session.key?(:sort_by)
			params[:sort_by] = session[:sort_by] #instead of using order i make use of sort_by, updates the sorting mechanism
			redirect_to movies_path(params) and return
		end
		
		@hilite = sort_by = session[:sort_by] #hilite used in application
		
		#same as the thing above but now includes ratings
		if params.key?(:ratings) #if the person using the app has selected 1 or more rating, update the session
			session[:ratings] = params[:ratings]
		elsif session.key?(:ratings)
			params[:ratings] = session[:ratings] #filter the movies if there are any ratings in session hash
			redirect_to movies_path(params) and return
		end
		
		@checked_ratings = (session[:ratings].keys if session.key?(:ratings)) || @all_ratings
		#properly ordering the movies
    @movies = Movie.order(sort_by).where(rating: @checked_ratings)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
