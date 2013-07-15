class Hash
  def assert_required_keys(*required_keys)
    (required_keys - (keys & required_keys)).tap do |missing_keys|
      if missing_keys.present?
        raise ArgumentError, "Missing required keys: #{missing_keys.map(&:inspect).join(', ')}"
      end
    end
  end
end
