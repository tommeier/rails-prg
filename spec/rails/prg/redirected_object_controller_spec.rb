require "spec_helper"
require "action_controller"
require_relative "../../dummy/app/controllers/test_controller"

#class TestController < ActionController::Base; end

describe TestController, type: :controller do

  describe "post redirect get with error conditions" do
    # Example Post-Redirect-Get on error conditions
    # without Rails error->render pattern
    class TestObject
      include ActiveModel::Validations
      attr_accessor :some_field

      def initialize(passed_attributes = {})
        self.some_field = passed_attributes[:some_field] if passed_attributes
      end
    end

    controller(TestController) do
      def new
        safe_params = [:some_field, :set_redirected_flash]
        fake_flash_for_test(safe_params)

        @object = TestObject.new(params.permit(*safe_params))

        load_redirected_objects!

        render text: 'successful load'
      end

      def create
        @object = TestObject.new(create_params)

        if params.delete(:error)
          @object.errors.add(:some_field, "not present")
          set_redirected_object!('@object', @object, create_params)
          redirect_to '/back_to_new_page'
        else
          redirect_to '/successful_result'
        end
      end

      private

      def create_params
        @create_params ||= begin
          if params.delete(:with_strong_parameters)
            params.require(:object).permit(:some_field)
          else
            #Unsafe parameters
            params[:object]
          end
        end
      end

      # As request hasn't happened in test yet,
      # we must set flash manually that would handle redirected objects
      # This duplicates the behaviour for unit testing 'after' a redirect
      def fake_flash_for_test(allowed_params)
        if params[:set_redirected_flash]
          content_for_flash = JSON.parse(params[:set_redirected_flash])
          flash[:redirected_objects] = if params.delete(:raw_hash)
            # Checking if a developer has passed raw hashes instead
            # of full parameters hash with permitted attributes
            content_for_flash
          else
            object_params = content_for_flash['@object']['params']
            if object_params
              # Ensure params are set as proper parameters object like they
              # should be in controller before
              controller_params = ActionController::Parameters.new(object_params).permit(*allowed_params)
              content_for_flash['@object']['params'] = controller_params
            end
            content_for_flash
          end
        end
      end
    end

    context "on change" do
      context "when error occurs with unpermitted params" do
        let(:params) do
          {
            error: true,
            object: {
              unknown_field: 'scary unsafe value',
              another_unknown: 'field'
            }
          }
        end

        context "with submission" do
          it "should raise error with descriptive error message for faster debugging" do
            expect { post :create, params }.to raise_error do |exception_received|
              exception_received.should be_a(RuntimeError)
              exception_received.to_s.should eq(
                '[Rails::Prg] Error - Must use permitted strong parameters. Unsafe: unknown_field, another_unknown'
              )
            end
          end
        end
      end

      context "when error occurs for permitted params" do
        let(:params) { { error: true, with_strong_parameters: true, object: { some_field: 'input value'} } }

        before do
          post :create, params
        end
        subject { response }

        it { should redirect_to '/back_to_new_page' }

        context "flash for redirected objects" do
          subject { flash[:redirected_objects] }

          it "should set required attributes" do
            subject.should eq(
              {
                '@object' => {
                  errors: { some_field: ["not present"] },
                  params: { "some_field" => "input value" }
                }
              }
            )
          end
        end
      end

      context "when no error has occured" do
        let(:params) { {} }
        before do
          post :create, params
        end
        subject { response }

        it { should redirect_to '/successful_result' }

        context "flash error" do
          subject { flash[:redirected_objects] }

          it { should_not be_present }
        end
      end
    end

    context "after a redirect" do
      context "after an error has occured" do
        before do
          get :new, params
        end
        subject { controller.instance_variable_get(:@object) }

        let(:object_errors)    { { some_field: ["not present"] } }
        let(:object_params)    { { some_field: "inputted value" } }

        let(:redirected_flash) do
          {
            '@object' => {
              errors: object_errors,
              params: object_params
            }
          }
        end
        let(:params) { { set_redirected_flash: redirected_flash.to_json } }
        its(:errors) { should be_an_instance_of(ActiveModel::Errors) }

        it "should have applied the errors to the object for display" do
          subject.errors.messages.should eq(object_errors)
        end

        it "should have applied any values passed in previous form" do
          subject.some_field.should eq("inputted value")
        end

        it "should have removed the collection from the flash object" do
          flash[:redirected_objects].should be_blank
        end
      end

      context "when a developer sends unsafe parameters" do
        let(:object_errors) { { some_field: ["not present"] } }
        let(:object_params) { { some_field: "inputted value" } }
        let(:params)        { { raw_hash: true, set_redirected_flash: redirected_flash.to_json } }
        let(:redirected_flash) do
          {
            '@object' => {
              errors: object_errors,
              params: object_params
            }
          }
        end

        it 'should raise an error' do
          expect { get :new, params }.to raise_error do |exception_received|
            exception_received.should be_a(RuntimeError)
            exception_received.to_s.should eq('[Rails::Prg] Error - Must pass safe parameters.')
          end
        end

        it 'should always clear the flash' do
          expect { get :new, params }.to raise_error
          flash[:redirected_objects].should be_blank
        end

        it "should set errors on to the object" do
          expect { get :new, params }.to raise_error
          controller.instance_variable_get(:@object).errors.should be_an_instance_of(ActiveModel::Errors)
        end
      end
    end

    context "when no error has occured" do
      let(:redirected_flash) { nil }
      let(:params)           { nil }

      before do
        get :new, params
      end

      subject { controller.instance_variable_get(:@object) }

      its(:errors) { should be_empty }
    end
  end
end
