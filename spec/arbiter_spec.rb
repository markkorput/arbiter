require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

class Operator
end

class Subject
end

describe Arbiter do
  before(:each) do
		@subject = Subject.new
		@operator = Operator.new

    @valid_attributes = {
      
    }
  end

	after(:each) do
	end

	it "should provide a can? gateway method" do
		Arbiter.respond_to?(:can?).should == true
	end

	it "should default to true" do
		Arbiter.can?(:subject, :not_specified_privilege).should == true
	end

	xit "should only delegate when a symbol indicates a valid, defined class" do
		Arbiter.can?(:xxxyz).should == true
	end

	it "should use available operator class methods when a symbol or a class is given" do
		Operator.should_receive(:can_destroy?).exactly(3).times.and_return(false)
		Arbiter.can?(:operator, :destroy).should == false
		Arbiter.can?(:operators, :destroy).should == false
		Arbiter.can?(Operator, :destroy).should == false
	end

	it "should use available subject class methods when a symbol or a class is given" do
		Subject.should_receive(:allow_defeat_by?).exactly(3)
		Arbiter.can?(:operator, :defeat, :subject).should == true
		Arbiter.can?(:operator, :defeat, :subjects).should == true
		Arbiter.can?(:operator, :defeat, Subject).should == true
	end

	it "should use available operator instance methods when an object is given" do
		@operator.should_receive(:can_login?).and_return(false)
		Arbiter.can?(@operator, :login).should == false
	end

	it "should use available subject instance methods when an object is given" do
		@subject.should_receive(:allow_change_by?).with(@operator).and_return(false)
		Arbiter.can?(@operator, :change, @subject).should == false
	end

	xit "should call try to find specific, as well as generic methods in subject and operator" do
		# should_receives:
		# :can_destroy?
		# :can_destroy_post?
		# :allow_destroy_by?
		# :allow_destroy_by_user?
	end

	it "should give pecific operator methods higher priority over more generics ones" do
		@operator.stub!(:can_create?).and_return(false)
		@operator.stub!(:can_create_subject?).and_return(true)
		Arbiter.can?(@operator, :create, :subject).should == true

		@operator.stub!(:can_destroy?).and_return(true)
		@operator.stub!(:can_destroy_subject?).and_return(false)
		Arbiter.can?(@operator, :destroy, :subject).should == false
	end

	it "should give pecific subject methods higher priority over more generic ones" do
		@subject.stub!(:can_create?).and_return(false)
		@subject.stub!(:can_create_subject?).and_return(true)
		Arbiter.can?(@operator, :create, :subject).should == true

		@operator.stub!(:can_destroy?).and_return(true)
		@operator.stub!(:can_destroy_subject?).and_return(false)
		Arbiter.can?(@operator, :destroy, :subject).should == false
	end

end
