class TestObjectsController < ApplicationController
  before_action :set_test_object, only: [:show, :edit, :update, :destroy]

  # GET /test_objects
  def index
    @test_objects = TestObject.all
  end

  # GET /test_objects/1
  def show
  end

  # GET /test_objects/new
  def new
    @test_object = TestObject.new
  end

  # GET /test_objects/1/edit
  def edit
  end

  # POST /test_objects
  def create
    @test_object = TestObject.new(test_object_params)

    if @test_object.save
      redirect_to @test_object, notice: 'Test object was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /test_objects/1
  def update
    if @test_object.update(test_object_params)
      redirect_to @test_object, notice: 'Test object was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /test_objects/1
  def destroy
    @test_object.destroy
    redirect_to test_objects_url, notice: 'Test object was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_object
      @test_object = TestObject.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def test_object_params
      params.require(:test_object).permit(:subject, :body, :published)
    end
end
