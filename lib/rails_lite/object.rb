class Object
  def try(method, *args)
    return nil if nil?
    respond_to?(method) ? send(method, *args) : nil
  end
end