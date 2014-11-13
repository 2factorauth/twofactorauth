module TFA
  module Helpers

    def question(question, a1, a2)
      puts question
      puts a1.upcase + '/' + a2.upcase
      answer = gets.chomp.downcase
      if answer == a1.downcase
        true
      elsif answer == a2.downcase
        return false
      else
        question(question, a1, a2)
      end
    end

    #sort the hash inplace
    def sort!(hash)
      hash.sort! do |x, y|
        x["name"].downcase <=> y["name"].downcase
      end
    end

  end
end
