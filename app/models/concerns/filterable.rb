# Make model filterable and sortable.
#  Sorting attributes passed in params can have a `:desc` suffix for reverse
#  sorting direction
#
# @example
#   # in the Model
#   include Filterable
#
#   # add filter-scope
#   filter_sope :age_from, ->(from) { where('age >=', from) }
#   filter_sope :age_to, ->(to) { where('age <=', to)  }
#
#   # add sorting attributes
#   sort_by %w[name age]
#
#   # in the ModelsController
#
#   def index
#     Model.filter.apply params
#   end
#
module Filterable
  extend ActiveSupport::Concern

  # @api private
  class FilterBuilder
    SORT_PARAM_NAME = :sort_by
    DESC = 'desc'

    attr_reader :model
    def initialize(model)
      @model = model
    end

    # @todo should combine same name scopes with `or` stantament
    # @api public
    # Apply `params` to {#scopes}
    # @param params [ActionController::Parameters] of params
    # @return [ActiveRecord::Relation] combinated from {#scopes} with `params`
    # @example (see Filterable)
    def apply(params)
      where(params).merge(order params)
    end

    def where(params)
      result = model.where(nil)
      scopes.each do |scope|
        result = result.public_send(scope, params[scope]) if\
          params[scope].present?
      end
      result
    end

    def order(params)
      result = model.where(nil)
      sort_attributes.each do |param_name, attributes|
        next unless params[param_name].present?
        parsed = parse_sort_by(params[param_name])
        accepted = attributes.map(&:to_s) & parsed.keys.map(&:to_s)
        accepted.each do |attr|
          if parsed[attr] =~ /#{DESC}/i
            result = result.order(attr).reverse_order
          else
            result = result.order(attr)
          end
        end
      end
      result
    end

    def parse_sort_by(passed_attr)
      result = []
      result << passed_attr
      result.flatten!
      result.map(&:to_s).map do |s|
        a = s.split(':')
        [a[0], a[1]]
      end.to_h
    end

    def add_scope(scope_name)
      scopes << scope_name.to_s
    end

    def scopes
      @scopes ||= []
    end

    def sort_attributes
      @sort_attributes ||= {}
    end
  end

  # nodoc
  module ClassMethods
    def filter_builder
      @filter_builder ||= FilterBuilder.new(self)
    end
    alias filter filter_builder

    # Adds and registers scope `name` in model
    #  All scopes must have exatly one argumet
    #
    # @exaple (see Filterable)
    #
    def filter_scope(name, body, &block)
      filter.add_scope name
      scope name, body, &block
    end

    # Adds sorting attributes
    #
    # @exaple (see Filterable)
    #
    def sort_by(attributes, sort_param_name = FilterBuilder::SORT_PARAM_NAME)
      filter.sort_attributes.merge! sort_param_name => attributes
    end
  end
end
