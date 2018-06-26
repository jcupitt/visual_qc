class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]

  # GET /votes
  # GET /votes.json
  def index
    @votes = Vote.all
  end

  # GET /votes/1
  # GET /votes/1.json
  def show
  end

  # GET /votes/new
  def new
    p = vote_params

    vote = Vote.find_by user_id: p[:user_id], scan_id: p[:scan_id]
    if vote
      vote.update(p)
    else
      vote = Vote.new(p)
      vote.save
    end

    scan = Scan.find(vote.scan_id)
    new_scan = scan.next

    if new_scan
      redirect_to new_scan 
    else
      redirect_to scans_path
    end

  end

  # GET /votes/1/edit
  def edit
  end

  # POST /votes
  # POST /votes.json
  def create
  end

  # PATCH/PUT /votes/1
  # PATCH/PUT /votes/1.json
  def update
  end

  # DELETE /votes/1
  # DELETE /votes/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote
      @vote = Vote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.permit(:vote_value, :user_id, :scan_id)
    end
end
