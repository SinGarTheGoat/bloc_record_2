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

  def method_missing(m, *args, &block)
    if m == :find_by
      self.send(:find_by_internal, args[0], args[1])
    else
      super
    end
  end

  def find_by_internal(attribute, value)
    puts "find_by_internal"
    sql = <<-SQL
    SELECT #{columns.join ","} FROM #{table}
    WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    rows = connection.execute(sql)
    return rows_to_array(rows)

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
  def find_each(attribute, value, start: 0, batch_size: 1)

    sql = <<-SQL
    SELECT #{columns.join ","} FROM #{table}
    WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    ORDER BY #{attribute}
    OFFSET #{start} ROWS
    FETCH NEXT #{batch_size} ROWS ONLY
    SQL

    rows = connection.execute(sql)
    rows.each do |x|
      yield x
    end
  end

  def find_in_batches(attribute, value, batch_size)
    Contact.find_in_batches(start: 4000, batch_size: 2000) do |contacts, batch|
      contacts.each { |contact| contact.check_if_naughty_or_nice }
    end
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
    if args.count > 1
      order = args.join(",")
    else
      order = args.first.to_s
    end

    rows = connection.execute <<-SQL
    SELECT * FROM #{table}
    ORDER BY #{order};
    SQL
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


#
# class Person
#   initialize(first_name, last_name)
#     @first_name = first_name
#     @last_name  = last_name
#   end
#
#   def full_name
#     return "#{@first_name} #{@last_name}"
#   end
#
#   def self.population
#     return 8_000_000_000
#   end
# end
#
# bob = Person.new("Bob", "Smith")
# puts bob.full_name
#
# puts bob.population # This fails
#
# puts Person.population
#
# puts Person.full_name # This fails

#
# Entry.order(:name, {phone_number: :desc})
#
# SELECT columns
# FROM entry
# ORDER BY name, phone_number desc
#
# # or
# Entry.order({name: :asc, phone_number: :desc})
#
# SELECT columns
# FROM entry
# ORDER BY name asc, phone_number desc
#
# # or
# Entry.order("name ASC, phone_number DESC")
#
# SELECT columns
# FROM entry
# ORDER BY name ASC, phone_number DESC
#
# # or
# Entry.order("name ASC", "phone_number DESC")
#
# ORDER BY name, phone_number desc
