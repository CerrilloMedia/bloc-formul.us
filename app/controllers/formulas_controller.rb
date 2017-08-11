class FormulasController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @user = User.find(params[:user_id])
    @formulas = @user.formulas || []
    @connections = current_user.connections
  end
  
  def show
    @formula = Formula.find(params[:id])
    @user = User.find(@formula.client_id)
    @artist = User.find(@formula.artist_id)
  end
  
  def new
    
    @formula = Formula.new
    
    @user = User.find(params[:requested_user])
    
    if current_user.artist?
      params[:artist_id], params[:client_id]  = current_user.id, @user.id
    else
      params[:artist_id], params[:client_id] = @user.id, current_user.id
    end
    
  end
  
  def create
    
    @formula = if params[:copy]
                  Formula.find(params[:copy]).dup
                else
                  Formula.new(formula_params)
                end
                
    # if duplication request is not from original author, set current_user (requestor) as new artist_id
    @formula.artist_id = current_user.id
    
    unless current_user.artist?
      @formula.artist_id, @formula.client_id = @formula.client_id, @formula.artist_id
    end
    
    if @formula.save 
      flash[:notice] = params[:copy] ? "Formula successfully copied" : "NEW Formula saved!"
      redirect_to current_user.artist? ? @formula : current_user
    else
      flash[:alert] = "Error saving formula. Please try again"
      puts @formula.errors.messages
      redirect_to request.referrer
    end
    
  end
  
  def edit
    @formula = Formula.find(params[:id])
    @user = User.find(@formula.client_id)
    # only original artist can edit their formula
    unless current_user.artist? && current_user.id == @formula.artist_id
      flash[:alert] = "Only the original author can edit this formula"
      redirect_to request.referrer
    end
    
  end
  
  def update
    @formula = Formula.find(params[:id])
    @formula.assign_attributes(formula_params)
    
    if current_user.id == @formula.artist_id && @formula.save 
      flash[:notice] = "Formula saved!"
      redirect_to current_user.artist? ? @formula : current_user
    else
      flash[:alert] = "Error saving formula. Please try again"
      redirect_to request.referrer
    end
    
  end
  
  def destroy
    # perhaps only if both user and have been cleared, perhaps set the id to nil? or add an attribute of active, triggered.
    #eventually check if 'triggered' in order to fully delete form the system.
  end
  
  private
  
  def formula_params
    params.require(:formula).permit(:artist_id, :client_id, :formulation, :service_type)
  end
  
end
