class Connector < ActiveRecord::Base
  belongs_to :page
  belongs_to :connectable, :polymorphic => true
  
  acts_as_list :scope => 'connectors.page_id = #{page_id} and connectors.page_version = #{page_version} and connectors.container = \'#{container}\''
  alias :move_up :move_higher 
  alias :move_down :move_lower  
  
  named_scope :for_page_version, lambda{|pv| {:conditions => {:page_version => pv}}}
  named_scope :for_connectable_version, lambda{|cv| {:conditions => {:connectable_version => cv}}}
  named_scope :for_connectable, lambda{|c| 
    {:conditions => { :connectable_id => c.id, :connectable_type => c.class.base_class.name }}
  }  
  named_scope :in_container, lambda{|container| {:conditions => {:container => container}}}
  named_scope :at_position, lambda{|position| {:conditions => {:position => position}}}  
  named_scope :like, lambda{|connector|
    {:conditions => { 
      :connectable_id => connector.connectable_id, 
      :connectable_type => connector.connectable_type,
      :connectable_version => connector.connectable_version,
      :container => connector.container,
      :position => connector.position
    }}
  }
  
  validates_presence_of :page_id, :page_version, :connectable_id, :connectable_type, :container
  
  def current_connectable
    if versioned?
      connectable.as_of_version(connectable_version) if connectable
    else
      get_connectable
    end
  end
  
  def connectable_with_deleted
    c = if connectable_type.constantize.respond_to?(:find_with_deleted)
      connectable_type.constantize.find_with_deleted(connectable_id)
    else
      connectable_type.constantize.find(connectable_id)
    end
    (c && c.class.versioned?) ? c.as_of_version(connectable_version) : c
  end
  
  def get_connectable
    #NOTE: This method only exists to work around a bug
    #If you call connector.connectable and try to use that, 
    #if that connectable has dynamic attributes (a portlet, for example),
    #then you will get a NoMethodError when you try to access a dynamic attribute
    connectable_type.constantize.find(connectable_id)
  end
  
  def status
    published? ? :published : :draft
  end        
  def status_name
    status.to_s.titleize
  end  
  
  def published?
    publishable? ? connectable.published? : true
  end
  
  def publishable?
    connectable_type.constantize.publishable?
  end
  
  def versioned?
    connectable_type.constantize.versioned?
  end
  
end