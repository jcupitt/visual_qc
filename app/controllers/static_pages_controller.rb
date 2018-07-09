class StaticPagesController < ApplicationController
  def help
  end

  def results
    @users = User.all
    @scans = Scan.all
  end
end
