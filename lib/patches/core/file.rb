class File

  def self.barename name
    basename name, '.*'
  end

  def basename
    self.class.basename self
  end

  def barename
    self.class.barename self
  end

end

class Pathname

  def barename
    basename '.*'
  end

end
