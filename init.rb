# add shortcuts methods everywhere (also needed for scopes etc.)
# Class.class_eval { include ArbiterShortcutsHelper }

ActiveRecord::Base.class_eval { include ArbiterModelExtensions }
ActionController::Base.class_eval { include ArbiterControllerExtensions }