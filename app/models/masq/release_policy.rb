module Masq
  class ReleasePolicy < ActiveRecord::Base
    belongs_to :site

    validates_presence_of :site
    validates_presence_of :property
    validates_uniqueness_of :property, :scope => [:site_id, :type_identifier]

    #attr_accessible :property, :type_identifier
  end
end
