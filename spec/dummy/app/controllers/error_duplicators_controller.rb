# Without Post-Redirect-Get pattern on error
# - > Standard Rails scaffold, this duplicates the error by showing:
#       Create -> Secure environment -> render error, success, back -> Displays error
#       Update -> Non-Secure environment -> render error, success, back -> No error
class ErrorDuplicatorsController < ApplicationController
  before_action :set_error_duplicator, only: [:show, :edit, :update, :destroy]

  before_filter :set_secure_environment, except: [:edit, :update]

  # GET /error_duplicators
  def index
    @error_duplicators = ErrorDuplicator.all
  end

  # GET /error_duplicators/1
  def show
  end

  # GET /error_duplicators/new
  def new
    @error_duplicator = ErrorDuplicator.new
  end

  # GET /error_duplicators/1/edit
  def edit
  end

  # POST /error_duplicators
  def create
    @error_duplicator = ErrorDuplicator.new(error_duplicator_params)

    if @error_duplicator.save
      redirect_to @error_duplicator, notice: 'Error duplicator was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /error_duplicators/1
  def update
    if @error_duplicator.update(error_duplicator_params)
      redirect_to @error_duplicator, notice: 'Error duplicator was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /error_duplicators/1
  def destroy
    @error_duplicator.destroy
    redirect_to error_duplicators_url, notice: 'Error duplicator was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_error_duplicator
      @error_duplicator = ErrorDuplicator.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def error_duplicator_params
      params.require(:error_duplicator).permit(:subject, :body, :published)
    end
end
