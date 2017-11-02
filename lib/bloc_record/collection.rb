
module BlocRecord
  class Collection < Array
    # #5
    def update_all(updates)
      ids = self.map(&:id)

      if self.any?
        arr_class = self.first.class
        arr_class.update(ids, updates)
      else
        false
      end
    end

    #Person.where(first_name: 'John').take;

    def take(n=1)
      puts "in collection"
      #just return n number of entries
      BlocRecord::Selection.take(n)
      #self.take
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

    def destroy_all
      ids = self.map(&:id)

      ids.each {|thang|
        puts thang.name
      BlocRecord::Persistence.destroy_all(thang.name)
    }
    end

  end
end
