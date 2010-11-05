module ArbiterModelExtensions
	def self.included(base)
		base.class_eval do
			extend ClassMethods
			include ArbiterModelExtensions::InstanceMethods
		end
	end

	module ClassMethods

		def install_arbiter_callbacks(operator_method = :current_actor)
			before_validation_on_create do |record|
				operator = record.send(operator_method)
				record.errors.add(:current_operation, :not_allowed) if disallowed = (operator && !operator.can?(:create, record))
				!disallowed
			end

			before_validation_on_update do |record|
				operator = record.send(operator_method)
				record.errors.add(:current_operation, :not_allowed) if disallowed = (operator && !operator.can?(:update, record))
				!disallowed
			end

			before_destroy do |record|
				operator = record.send(operator_method)
				record.errors.add(:current_operation, :not_allowed) if disallowed = (operator && !operator.can?(:destroy, record))
				!disallowed
			end
		end

	end

	module InstanceMethods

		def can?(*args)
			Arbiter.can?(*([self]+args))
		end
	end
end