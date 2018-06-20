class SessionsController < ApplicationController

  def new
    user = User.find_by(id: params[:format])
    log_in user
    flash[:success] = "Logged in as #{user.name}"
    redirect_to root_path
  end


  def destroy
    log_out
    flash[:success] = "Logged out"
    redirect_to root_path
  end

end
