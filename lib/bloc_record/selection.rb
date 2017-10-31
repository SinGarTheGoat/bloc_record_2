require 'sqlite3'

module Selection

  def find(*ids)

    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end


  def find_one(id)
    sql = <<-SQL
    SELECT #{columns.join ","} FROM #{table}
    WHERE id = "#{id}";
    SQL

    #row = connection.get_first_row sql


    init_object_from_row(row)

  end

  # def find_by(attribute, value)
  #   row = connection.get_first_row <<-SQL
  #   SELECT #{columns.join ","} FROM #{table}
  #   WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
  #   SQL
  #
  #   init_object_from_row(row)
  # end



  def method_missing(m, *args, &block)
    matches = m.match(/^find_by_(.*)$/)
    if matches
      field_name = matches.captures[0]
      find_by(field_name, args[0])
    else
      super
    end
  end

  def find_by(attribute, value)

    row = connection.get_first_row <<-SQL
    SELECT #{columns.join ","} FROM #{table}
    WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    init_object_from_row(row)


    # puts "find_by_internal"
    # sql = <<-SQL
    # SELECT #{columns.join ","} FROM #{table}
    # WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    # SQL
    #
    # rows = connection.execute(sql)
    # return rows_to_array(rows)

    # Contact.find_each do |contact|
    #   contact.check_if_naughty_or_nice
    # end
    #
    # Contact.find_each(start: 2000, batch_size: 2000) do |contact|
    #   contact.check_if_naughty_or_nice
    # end
    #
    # Contact.find_in_batches(start: 4000, batch_size: 2000) do |contacts, batch|
    #   contacts.each { |contact| contact.check_if_naughty_or_nice }
    # end

  end
  # I want to submit this for chapter 3
  #stupid git     dkwoapmfkwel;   ckdlsmkclsncls knxklsdafjkl SPK
  def find_each(start: 0, batch_size: 100)

    total = Entry.count
    till =0
    while till< total-1
      sql = <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size} OFFSET #{start}
      SQL
      puts sql
      rows = connection.execute(sql)
      rows =  rows_to_array(rows)
      rows.each do |x|
        puts "in da loop"
        if x == nil
          break
          end
          yield init_object_from_row(x)

        end
        start = start + 100
      end

    end

    def find_in_batches(start: 0, batch_size: 100)
      sql = <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size} OFFSET #{start}
      SQL

      rows = connection.execute(sql)

      # Changes the rows into a set of objects
      # yield that set resulting from rows_to_arry


      strang = ''
      y=1
      #turn into objects using init_object_from_row, then yield the batch


      rows.each do |x|

        yield init_object_from_row(strang)
      end
      y= 1+y

      # Contact.find_in_batches(start: 4000, batch_size: 2000) do |contacts, batch|
      #   contacts.each do |contact|
      #
      #     contact.check_if_naughty_or_nice
      #   end
      # end
    end

    def take(num=1)
      if num > 1
        rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
        SQL

        return rows_to_array(rows)
      else
        return  take_one
      end
    end

    def take_one
      row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
      SQL

      init_object_from_row(row)
    end


    def first
      row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id ASC LIMIT 1;
      SQL

      init_object_from_row(row)
    end

    def last
      row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id DESC LIMIT 1;
      SQL

      init_object_from_row(row)
    end
    def all
      rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
      SQL

      rows_to_array(rows)
    end

    def where(*args)
      if args.count > 1
        expression = args.shift
        params = args
      else
        case args.first
        when String
          expression = args.first
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
        end
      end

      sql = <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{expression};
      SQL

      rows = connection.execute(sql, params)
      rows_to_array(rows)
    end



    def order(*args)
      final_array = []
      args.each do |x|
        case x
        when Hash
          puts "hash  kik #{x}"
          if x.to_s.include? ","
            extra = TRUE
          end
          puts x
          x = x.to_s
          x = x.gsub(/{:/, ' ')
            x = x.gsub(/=>:/, ' ')
            x= x.gsub(/,/,',')
            x = x.gsub(/}/, '')
            if extra == TRUE
              x = x.gsub(/:/, '')
            end
            puts x
            final_array << x
          when Symbol
            puts "Symbol #{x}"
            x = x.to_s
            final_array << x
          when String
            puts "String #{x}"
            final_array << x
          when Numeriac
            x.to_s
          end
        end

        if final_array.count > 1
          order = final_array.join(",")
        else
          order = final_array.first.to_s
        end
        rows = connection.execute <<-SQL
        SELECT * FROM #{table}
        ORDER BY #{order};
        SQL
        rows_to_array(rows)
      end


      def join(*args)
        if args.count > 1
          joins = args.map { |arg| "INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id"}.join(" ")
          rows = connection.execute <<-SQL
          SELECT * FROM #{table} #{joins}
          SQL
        else
          case args.first
          when String
            rows = connection.execute <<-SQL
            SELECT * FROM #{table} #{BlocRecord::Utility.sql_strings(args.first)};
            SQL
          when Symbol
            rows = connection.execute <<-SQL
            SELECT * FROM #{table}
            INNER JOIN #{args.first} ON #{args.first}.#{table}_id = #{table}.id
            SQL
          when Hash
            args.to_s
            x = x.to_s
            x = x.gsub(/{:/, '')
              x = x.gsub(/}/, '')
              arg_ray = x.split('=>:')
              arg_ray[0] = arg_ray[0].gsub(/,/,'')
              join(arg_ray[0], arg_ray[1])
            end
          end

          rows_to_array(rows)
        end

        private
        def init_object_from_row(row)
          if row
            data = Hash[columns.zip(row)]
            new(data)
          end
        end

        def rows_to_array(rows)
          rows.map { |row| new(Hash[columns.zip(row)]) }
        end
      end
