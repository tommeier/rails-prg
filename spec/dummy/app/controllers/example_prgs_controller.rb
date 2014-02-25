# With Post-Redirect-Get pattern on error
# - > Standard Rails scaffold, with redirect back on error using RailsPrg helpers
# -> Create -> Post-Redirect-Get in secure environment,
#              redirected object loaded via filter on :new
# -> Update -> Post-Redirect-Get in non-secure environment
#              redirected object loaed via direct call on :edit
class ExamplePrgsController < ApplicationController
  before_filter :set_secure_environment, except: [:edit, :update]
  before_action :set_example_prg, only: [:show, :edit, :update, :destroy]

  # Load any redirected objects with errors for display via filter
  before_filter :load_redirected_objects!,  only: [:edit]

  # GET /example_prgs
  def index
    @example_prgs = ExamplePrg.all
  end

  # GET /example_prgs/1
  def show
  end

  # GET /example_prgs/new
  def new
    @example_prg = ExamplePrg.new
    # Load any redirected objects with errors for display via direct call
    load_redirected_objects!
  end

  # GET /example_prgs/1/edit
  def edit
  end

  # POST /example_prgs
  def create
    @example_prg = ExamplePrg.new(example_prg_params)

    if @example_prg.save
      redirect_to @example_prg, notice: 'Example prg was successfully created.'
    else
      # render action: 'new' # Removed standard rails way
      set_redirected_object!('@example_prg', @example_prg, example_prg_params)
      redirect_to new_example_prg_path
    end
  end

  # PATCH/PUT /example_prgs/1
  def update
    if @example_prg.update(example_prg_params)
      redirect_to @example_prg, notice: 'Example prg was successfully updated.'
    else
      # render action: 'edit' # Removed original Rails render method
      set_redirected_object!('@example_prg', @example_prg, example_prg_params)
      redirect_to edit_example_prg_path(@example_prg)
    end
  end

  # DELETE /example_prgs/1
  def destroy
    @example_prg.destroy
    redirect_to example_prgs_url, notice: 'Example prg was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_example_prg
      @example_prg = ExamplePrg.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def example_prg_params
      params.require(:example_prg).permit(:subject, :body, :published)
    end
end
