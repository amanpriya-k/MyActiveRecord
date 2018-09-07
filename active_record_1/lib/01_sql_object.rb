require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    col = instance_variable_get("@columns")
    return col if col
    table = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        1
    SQL
    cols = table[0].map { |col| col.to_sym }
    instance_variable_set("@columns", cols)
  end

  def self.finalize!
    self.columns.each do |attr_name|
      define_method(attr_name) do
        attributes[attr_name]
      end
      define_method("#{attr_name}=") do |val|
        attributes[attr_name.to_sym] = val
      end
    end
  end

  def self.table_name=(table_name)
    instance_variable_set("@table_name", table_name)
  end

  def self.table_name
    return @table_name if @table_name
    self.to_s.tableize
  end

  def self.all
    all_instances = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(all_instances)
  end

  def self.parse_all(results)
    results.map { |attr_hash| self.new(attr_hash) }
  end

  def self.find(id)
    
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_sym = attr_name.to_sym
      unless self.class.columns.include?(attr_sym)
        raise "unknown attribute '#{attr_sym}'"
      else
        self.send("#{attr_sym}=", val)
      end
    end
  end

  def attributes
    return @attributes if @attributes
    @attributes = {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
