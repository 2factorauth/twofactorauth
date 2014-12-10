require "#{(__FILE__)}/../tfa/tfa"
require "#{(__FILE__)}/../tfa/provider"
require "#{(__FILE__)}/../tfa/helpers"

class NewEntryService

  include ::TFA::Helpers

  def run
    if question('Is the site you want to add a provider(P) or website(W)?', 'P', 'W')
      ::TFA::Provider.new.run
    else
      ::TFA::TFA.new.run
    end
  end

end
