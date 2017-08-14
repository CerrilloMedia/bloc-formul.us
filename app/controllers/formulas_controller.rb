class FormulasController < ApplicationController
  before_action :authenticate_user!
  
  def index
    
    @user = User.find(params[:user_id])
      
   @formulas = case
                when current_user.is_self?(@user)
                  if @user.client?
                    # guests can see their whole history
                    @user.formulas.first(10)
                  else
                    # artists would see their complete client history
                    @user.guest_formulas.first(10)
                  end
                when current_user.client? && @user.artist?
                  # when a client visists an artists page, should only return their own client history with specific artist.
                  @user.guest_formulas.where('client_id = ?', current_user.id)
                when current_user.artist? && @user.client?
                  # when artist visits any client page it shows clients entire general history
                  @user.formulas
                when current_user.artist? && @user.artist?
                  @user.guest_formulas
                end
    
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
    
    if params[:copy]
      @formula.client_id = current_user.id if current_user.client?
      # if formula is being copied from another artist, assign new artist ID
      @formula.artist_id = current_user.id if current_user.artist?
    end
    
    
    if @formula.save 
      flash[:notice] = params[:copy] ? "Formula successfully copied" : "NEW Formula saved!"
      redirect_to current_user.artist? ? @formula : current_user
    else
      flash[:alert] = @formula.errors.messages
      redirect_to request.referrer
    end
    
  end
  
  def edit
    @formula = Formula.find(params[:id])
    @user = User.find(@formula.client_id)
    
    # only original artist can edit their formula
    unless current_user.id == @formula.artist_id
      flash[:alert] = "Only the original author can edit this formula"
      redirect_to request.referrer || current_user
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
