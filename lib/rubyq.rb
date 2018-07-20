require "rubyq/version"

module Rubyq
  class QueryBuilder
    def initialize
      reset
    end

    def select(fields)
      @type = :select

      @parts[:select] = [*fields]

      self
    end

    def update(name)
      @type = :update

      @parts[:from] = name

      self
    end

    def delete(name)
      @type = :delete

      @parts[:from] = name

      self
    end

    def distinct(flag = true)
      @parts[:distinct] = flag

      self
    end

    def from(name)
      raise 'This method only for SELECT' unless @type == :select

      @parts[:from].push(name)

      self
    end

    def set(field, value)
      @parts[:set].push({ field: field, value: value })

      self
    end

    def where(condition)
      @parts[:where] = [ { condition: condition, operator: 'AND' } ]

      self
    end

    def and_where(condition)
      @parts[:where].push({ condition: condition, operator: 'AND' })

      self
    end

    def or_where(condition)
      @parts[:where].push({ condition: condition, operator: 'OR' })

      self
    end

    def order_by(field, sort = nil)
      @parts[:order_by].push({ field: field, sort: sort })

      self
    end

    def group_by(field)
      @parts[:group_by].push(field)

      self
    end

    def get_query
      query =
        case @type
        when :select then build_query_for_select
        when :update then build_query_for_update
        when :delete then build_query_for_delete
        end

      reset

      query
    end

    private

    def reset
      @type = :select

      @parts = {
        select: [],
        distinct: false,
        from: [],
        set: [],
        where: [],
        group_by: [],
        order_by: [],
        limit: nil,
        offset: nil,
      }
    end

    def build_query_for_select
      query = "SELECT#{@parts[:distinct] == true ? ' DISTINCT ' : ' '}#{@parts[:select].empty? ? '*' : @parts[:select].join(', ')}"

      if @parts[:from].any?
        query << " FROM #{@parts[:from].join(', ')}"
      end

      if @parts[:where].any?
        query << " WHERE#{build_where}"
      end

      if @parts[:group_by].any?
        query << " GROUP BY #{@parts[:group_by].join(', ')}"
      end

      if @parts[:order_by].any?
        query << " ORDER BY "
        query << @parts[:order_by].map { |order| order[:field] + (order[:sort].nil? ? '' : " #{order[:sort]}")}.join(', ')
      end

      query
    end

    def build_query_for_update
      query = "UPDATE #{@parts[:from]}"

      if @parts[:set].any?
        query << " SET #{@parts[:set].map { |set| "#{set[:field]} = '#{set[:value]}'" }.join(', ')}"
      end

      if @parts[:where].any?
        query << " WHERE#{build_where}"
      end

      if @parts[:order_by].any?
        query << " ORDER BY "
        query << @parts[:order_by].map { |order| order[:field] + (order[:sort].nil? ? '' : " #{order[:sort]}")}.join(', ')
      end

      query
    end

    def build_query_for_delete
      query = "DELETE #{@parts[:from]}"

      if @parts[:where].any?
        query << " WHERE#{build_where}"
      end

      if @parts[:order_by].any?
        query << " ORDER BY "
        query << @parts[:order_by].map { |order| order[:field] + (order[:sort].nil? ? '' : " #{order[:sort]}")}.join(', ')
      end

      query
    end

    def build_where
      whereStatement = ''

      @parts[:where].each do |where|
        if !whereStatement.empty?
          whereStatement << " #{where[:operator]}"
        end

        whereStatement << " #{where[:condition]}"
      end

      whereStatement
    end
  end
end
