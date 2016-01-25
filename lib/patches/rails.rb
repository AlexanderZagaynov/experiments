class Rails::Application

  def cookie_key
    "_#{self.class.parent_name.demodulize.underscore}_session"
  end

end
