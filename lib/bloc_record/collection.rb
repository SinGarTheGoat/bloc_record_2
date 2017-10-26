
module BlocRecord
  class Collection < Array
    # #5
    def update_all(updates)
      ids = self.map(&:id)
      # #6

      if self.any?
        arr_class = self.first.class
        arr_class.update(ids, updates)
      else
        false
      end
    end

    #Person.where(first_name: 'John').take;

    def take(n=1)
      #just return n number of entries
      self.take

    end

    def where(*args)
      self.select{ |item|

        args[0].map{ |key,value|
        item.send(key) == value}.all?
        }
    end

  def not(*args)
    self.select{ |item|
      not args[0].map{ |key,value|
      item.send(key) == value}.any? #any? and /or
      }
  end

  end
end
