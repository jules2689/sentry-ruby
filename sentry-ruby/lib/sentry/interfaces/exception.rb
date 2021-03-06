module Sentry
  class ExceptionInterface < Interface
    attr_accessor :values

    def to_hash
      data = super
      data[:values] = data[:values].map(&:to_hash) if data[:values]
      data
    end
  end
end
