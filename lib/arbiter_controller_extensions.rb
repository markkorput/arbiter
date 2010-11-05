module ArbiterControllerExtensions
	def self.included(base)
		base.class_eval do
			extend ClassMethods
			include ArbiterControllerExtensions::InstanceMethods
		end
	end

	module ClassMethods

		def install_arbiter_before_filters(halt_method = nil, operator_method = :current_actor)
			before_filter :only => [:index, :show] do |kontroller|
				kontroller.send(halt_method || default_arbiter_halt_method) if !kontroller.send(operator_method).can?(:access, kontroller.controller_name.to_sym)
			end

			before_filter :only => [:new, :create] do |kontroller|
				kontroller.send(halt_method || default_arbiter_halt_method) if !kontroller.send(operator_method).can?(:create, kontroller.controller_name.to_sym)
			end

			before_filter :only => [:edit, :update] do |kontroller|
				kontroller.send(halt_method || default_arbiter_halt_method) if !kontroller.send(operator_method).can?(:update, kontroller.preload_resources_for_arbiter_before_filters || kontroller.controller_name.to_sym)
			end

			before_filter :only => [:destroy] do |kontroller|
				kontroller.send(halt_method || default_arbiter_halt_method) if !kontroller.send(operator_method).can?(:destroy, kontroller.preload_resources_for_arbiter_before_filters || kontroller.controller_name.to_sym)
			end
		end

	end

	module InstanceMethods

		def preload_resources_for_arbiter_before_filters
			# we're gonna try to pre-load the request object(s) for the current action make_resourceful-style
			preloader = Resourceful::PLURAL_ACTIONS.include?(action_name.to_sym) ? :current_objects : (Resourceful::SINGULAR_PRELOADED_ACTIONS.include?(action_name.to_sym) ? :current_object : :build_object)
			# make sure the current controller supports the preloader method; which it does if it use make_resourceful
			return self.respond_to?(preloader) ? self.send(preloader) : nil
		end

		def default_arbiter_halt_method
			redirect_to :back
		end

	end
end