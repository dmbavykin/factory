require "pry"
class Factory
  class << self
    def new(*arguments, &block)
      name = if arguments.first.is_a? String
        arguments.shift
      else
        nil
      end

      instance = Class.new do
        attr_accessor *arguments

        define_method :initialize do |*params|
          raise ArgumentError.new('Excess arguments') if params.size > arguments.size

          params.each_with_index do |value, index|
            instance_variable_set("@#{arguments[index]}", value)
          end
        end

        def ==(other)
          raise TypeError.new('Wrong class') unless self.class == other.class
          self.instance_variables_values == other.instance_variables_values
        end

        def [](param)
          var = if param.is_a? Integer
                  self.instance_variables[param]
                else
                  "@#{param}"
                end
          instance_variable_get(var)
        end

        def []=(param, value)
          instance_variable_set("@#{param}", value)
        end

        def instance_variables_values
          self.instance_variables.map do |var|
            instance_variable_get(var)
          end
        end

        def size
          self.instance_variables.count
        end

        def members
          instance_variables.map { |var| var.to_s.tr('@', '').to_sym  }
        end

        def each(&block)
          instance_variables_values.each(&block)
        end

        def each_pair(&block)
          Hash[members.zip(instance_variables_values)].each(&block)
        end

        def values_at(*params)
          params.map { |param| to_a[param] }
        end

        def select(&block)
          to_a.keep_if(&block)
        end

        def dig(*params)
          result = self
          params.map do |param|
            break if result.class == NilClass
            result = result[param]
          end
          result
        end


        alias_method :to_a, :instance_variables_values
        alias_method :length, :size
        class_eval(&block) if block_given?
      end

      name ? const_set(name, instance) : instance
    end
  end
end
# Customer = Factory.new('Customer', :name, :city)
# dimas = Customer.new('dimas', 'dievka')
# binding.pry