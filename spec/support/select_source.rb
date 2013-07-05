class SelectSource
  def self.all
    [
      { id: 1, name: 'Option 1' },
      { id: 2, name: 'Option 2' },
      { id: 3, name: 'Option 3' }
    ]
  end

  def self.first
    all.first
  end
end