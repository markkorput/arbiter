class Arbiter
	def self.can?(operator = nil, action = nil, subject = nil, *args)
		# operator and subject can both be symbols or objects
		# so all of these examples are valid:
		# Arbiter.can?(current_user, :create, Page.new)
		# Arbiter.can?(current_user, :create, :pages)
		# Arbiter.can?(:user, :create, :pages)
		# Arbiter.can?(:user, :create, Page.new)
		operator_sym = obj_to_sym(operator)
		subject_to_sym = obj_to_sym(subject)

		operator = param_to_arbiter(operator)
		subject = param_to_arbiter(subject)

		# both the operator class and the subject class can define methods to restrict certain actions
		# for example, if a user is trying to create a page you'd get something like Arbiter.can?(user, :create, page)
		# so, the operator is a user object, the action is the :create symbol and the subject is a page object
		# in this case the following methods could specify restrictions about which user can create what kind of pages:
		# user.can_create_page(subject) # this method has higher priority than the one below
		# user.can_create?(subject) # this method should check if subject is a page object (or for example the :pages symbol)
		# page.allow_create_by_user(subject) # this method has higher priority than the one below
		# page.allow_create_by(subject) # this method should check if subject is a user object (or the :users symbol)
		operator_methods = [
			"can_#{action}_#{obj_to_sym(subject)}?",								# can_create_post(Post)
			"can_#{action}_#{obj_to_sym(subject).to_s.pluralize}?",	# can_create_posts(Post)
			"can_#{action}?"																				# can_create(Post)
		]

		subject_methods = [
			"allow_#{action}_by_#{obj_to_sym(operator)}?",								# allow_destroy_by_user(user)
			"allow_#{action}_by_#{obj_to_sym(operator).to_s.pluralize}?",	# allow_destroy_by_users(user)
			"allow_#{action}_by?"																					# allow_destroy_by(user) or allow_destroy_by(User)
		]

		# take the value of the first operator method we can find
		operator_allowed = operator_methods.map{|method_name| operator.send(*([method_name, subject]+args).compact) if operator.respond_to?(method_name)}.select{|result| result == false}.empty? # compact.first
		# take the value of the first subject method we can find
		subject_allowed = subject_methods.map{|method_name| subject.send(*([method_name, operator]+args).compact) if subject.respond_to?(method_name)}.select{|result| result == false}.empty? # compact.first

		# todo: launch_callback_for_missing_arbiter_check_methods if operator_allowed.nil? && subject_allowed.nil?

		# result may be either true or nil
		return operator_allowed != false && subject_allowed != false
	end

	private

	def self.obj_to_sym(obj)
		if obj.is_a?(Symbol) || obj.is_a?(String)
			obj.to_s.singularize.to_sym
		else
			obj.is_a?(Class) ? obj.to_s.underscore.to_sym : obj.class.to_s.underscore.to_sym
		end
	end

	# here param can be either a symbol or an object, in case of a symbol this method returns a class, otherwise it returns the object
	# param_to_arbiter(:user) # => User
	# param_to_arbiter(User.first) # => User.first
	def self.param_to_arbiter(param)
		if param.is_a?(Symbol) || param.is_a?(String)
			begin 
				(param.to_s.classify.constantize)
			rescue NameError
				param
			end
		else
			param
		end
	end
end
