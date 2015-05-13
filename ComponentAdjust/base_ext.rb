class Hash
  def sort_by_key
    self.sort.map{|k,v| {k=> v}}
  end
end
