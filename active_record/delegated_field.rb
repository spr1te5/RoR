module DelegatedField
    extend ActiveSupport::Concern

    module ClassMethods
       #
       # Setters & getters delegations for complex hierarchy accociations where <code>delegate</code> doesn't fit.
       # name - field name.
       # Options:
       #  source [block] - source to get value from;
       #  destination [block] - destination to write value to;
       #  association [true|false] - where destination is a model's association. Defaults to false;
       #  value_source [block] (optional) - destination value source customization. If empty the value is used.
       #
       def delegated_field name, source, destination, options = {}

        define_method name do
          value = instance_variable_get "@#{name}"
          value ||= if src = instance_exec(&source)
            option = src.send name
            option.nil? ? options[:default] : option
          else
            options[:default]
          end
        end

        define_method "#{name}=" do |value|
           instance_variable_set "@#{name}", value
           add_postponed_assignment do
             instance_exec(&destination).map do |dest|
               value_source = options[:value_source]
               new_value = value_source ? instance_exec(value, &value_source) : value
               dest.send "#{name}=", new_value

               unless options[:association]
                 {saver: ->() {dest.save! if dest.changed?}}
               end
             end
          end
        end

      end

    end

end