#require 'capistrano'
#require 'capistrano/configuration/variables'
#include Capistrano::Configuration::Variables

class CapistranoExtSetHelpers
  VERSION = '1.0.0'
end

###############################################################################
#
# Helpers
#

# use environment variable if provided
# otherwise use the passed value
def env_or_set(variable, value=nil, &block)
  value = if ENV[variable.to_s].nil?
    value
  else
    if ENV[variable.to_s] == /^:/
      ENV[variable.to_s].to_sym
    else
      ENV[variable.to_s].to_s
    end
  end
  set( variable ) {
    value = block.call if block_given? && value.nil?
    value = true if value =~ /true/i
    value = false if value =~ /false/i
    value
  }
end

# sets variable from environment variable if provided
# otherwise does nothing.
def env_set_optional(variable)
  value = if ENV[variable.to_s] == /^:/
            ENV[variable.to_s].to_sym
          else
            ENV[variable.to_s].to_s
          end
  set(variable, value) unless value.empty?
end

# checks the environment first for a variable,
# then asks the user to select its value from
# the provided list of options.
def env_or_menu(variable, options, default=nil)
  question = "( ? ) Select #{variable.to_s}"
  value = if ENV[variable.to_s].nil?
    Capistrano::CLI.ui.choose do |menu|
      unless default.nil?
        menu.default = default
        menu.prompt = "%s |%s|" % [question,default]
      else
        menu.prompt = question
      end
      options.each {|c| menu.choice(c)}
      menu.header = question
    end
  else
    if ENV[variable.to_s] == /^:/
      ENV[variable.to_s].to_sym
    else
      ENV[variable.to_s].to_s
    end
  end
  yield(value) if block_given?
  return value
end

# check the environment first for a variable,
# then asks the user a question to provide
# the value
def env_or_ask(variable, question, default=nil)
  value = if ENV[variable.to_s].nil?
    Capistrano::CLI.ui.ask(question) do |q|
      unless default.nil?
        q.default = default
      end
    end
  else
    if ENV[variable.to_s] == /^:/
      ENV[variable.to_s].to_sym
    else
      ENV[variable.to_s].to_s
    end
  end
  yield(value) if block_given?
  return value
end

# lazy set a variable with env_or_menu
def set_ask_menu(variable, options, default=nil)
  set(variable) do
    env_or_menu(variable,options,default) do |value|
      yield(value) if block_given?
    end
  end
end

# lazy set a variable with env_or_ask
def set_ask(variable, question, default=nil)
  set(variable) do
    env_or_ask(variable,question,default) do |value|
      yield(value) if block_given?
    end
  end
end

