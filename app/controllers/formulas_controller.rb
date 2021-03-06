class FormulasController < ApplicationController
  before_action :authenticate_user!

  def index

    @user = User.find(params[:user_id])

   @formulas = case
                when current_user.is_self?(@user)
                  if @user.client?
                    # guests can see their whole history
                    @user.formulas.first(4)
                  else
                    # artists would see their complete client history
                    @user.guest_formulas.first(6)
                  end
                when current_user.client? && @user.artist?
                  # when a client visists an artists page, should only return their own client history with specific artist.
                  @user.guest_formulas.where('client_id = ?', current_user.id).first(4)
                when current_user.artist? && @user.client?
                  # when artist visits any client page it shows clients entire general history
                  @user.formulas.first(6)
                when current_user.artist? && @user.artist?
                  # when artists visits another artists page it shows all users OWN formulas, not their clients
                  @user.formulas
                end

    @connection_ids = current_user.connection_ids

  end

  def show

    @formula = Formula.find(params[:id])
    @user = User.find(@formula.client_id)
    @artist = User.find(@formula.artist_id)

    respond_to do |format|
      format.html
      format.json { render json: @formula }
    end

  end

  def new

    @formula = current_user.guest_formulas.new

    if params[:requested_user]
        @user = User.find(params[:requested_user])
    end

  end

  def create

    if params[:copy]
      @formula = Formula.find(params[:copy]).dup
      @formula.artist_id = current_user.id
      @formula.author_name = current_user.full_name
    elsif params[:requested_user]
      @formula = current_user.guest_formulas.new(formula_params)
      @formula.client_id = params[:requested_user]
      @formula.client_name = User.find(@formula.client_id).full_name
    else
      @formula = current_user.guest_formulas.new(formula_params)
      @formula.parse_client
    end

    if @formula.save
      flash[:notice] = params[:copy] ? "Formula successfully copied" : "NEW Formula saved!"
      redirect_to current_user.artist? ? @formula : current_user
    else
      flash[:alert] = "Error saving formula, please try again."
      render :new
    end

  end

  ############## EDIT

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
    @user = User.find(@formula.client_id)
    @formula.assign_attributes(formula_params)

    if current_user.author?(@formula) && @formula.save
      flash[:notice] = "Formula saved!"
      redirect_to current_user.artist? ? @formula : current_user
    else
      # flash[:alert] = @formula.errors.full_messages.join('. ')
      flash[:alert] = "Error saving formula. Please try again"
      render :edit
    end

  end

  def destroy
    # perhaps only if both user and have been cleared, perhaps set the id to nil? or add an attribute of active, triggered.
    #eventually check if 'triggered' in order to fully delete form the system.
    @formula = Formula.find(params[:id])

    @formula.can_delete?

    if current_user.artist? && @formula.pending_deletion_by_guest?
      @formula.delete
    elsif current_user.guest?  && @formula.pending_deletion_by_artist?
      @formula.delete
    else
      @formula.pending_deletion_by_artist
    end


  end

  private

  def formula_params
    params.require(:formula).permit(:artist_id, :client_id, :formulation, :service_type, :client_name)
  end

end
