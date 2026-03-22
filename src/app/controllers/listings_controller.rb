class ListingsController < ApplicationController
  before_action :authenticate_user!, only: [:show, :new, :edit, :update, :destroy]
  before_action :set_listing, only: [:show, :edit, :update, :destroy, :favorite, :attend, :unfavorite, :unattend]

  def favorite
    favorite = @listing.favorites.new(profile_id: current_user.profile.id)
    if favorite.save
      flash.notice = "You have favorited this listing"
      redirect_to listing_path
    else
      flash.notice = "You already favorited this."
      redirect_to listing_path
    end
  end
  
  def unfavorite
    favorite = @listing.favorites.find_by(profile_id: current_user.profile.id)
    if favorite.destroy
      flash.notice = "You have unfavorited this listing"
      redirect_to listing_path
    else
      flash.notice = "Please try again."
      redirect_to listing_path
    end
  end

  def attend
    listing = @listing.attendees.new(profile_id: current_user.profile.id)
    if listing.save
      flash.notice = "You are now attending this listing"
      redirect_to listing_path
    else
      flash.notice = "You are already attending this."
      redirect_to listing_path
    end
  end

  def unattend
    attendee = @listing.attendees.find_by(profile_id: current_user.profile.id)
    if attendee.destroy
      flash.notice = "You are no longer marked as attending this listing"
      redirect_to listing_path
    else
      flash.notice = "Please try again."
      redirect_to listing_path
    end
  end

  # GET /listings
  # GET /listings.json
  def index
    scope = Listing.search(params[:search], params[:city])
    scope = scope.joins(:profile).where.not(profiles: { user_id: current_user.id }) if current_user
    @pagy, @listings = pagy(scope, items: 12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
    if current_user.profile != @listing.profile
      redirect_to profile_path(current_user.profile) and return
    end
  end

  # POST /listings
  # POST /listings.json
  def create
    # @profile_id = current_user.profile.id
    # @profile_name = current_user.profile.first_name
    @listing = current_user.profile.listings.create(listing_params)

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    if current_user.profile != @listing.profile
      redirect_to profile_path(current_user.profile) and return
    end
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    if current_user.profile != @listing.profile
      redirect_to profile_path(current_user.profile) and return
    end
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:profile_id, :hobby_id, :description, :location, :date, :city_id, :equipment, :capacity)
    end
end
