module BlocRecord
  class Collection < Array
    # #5
    def update_all(updates)
      ids = self.map(&:id)
      # #6
      self.any? ? self.first.class.update(ids, updates) : false
    end



#Person.where(first_name: 'John').take;

    def took(arg)



    end

    #add a destrya all method coming out of this class
  end
end
