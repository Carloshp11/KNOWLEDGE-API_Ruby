class APIException < Exception
    def initialize(message)
      super(message)
    end
end

class BadRequest < APIException
    def initialize(message)
      super(message)
      @status_code = 400
    end
end

class Unauthorized < APIException
    def initialize(message)
      super(message)
      @status_code = 401
    end
end

class Forbidden < APIException
    def initialize(message)
      super(message)
      @status_code = 403
    end
end

class NotFoundError < APIException
    def initialize(message)
      super(message)
      @status_code = 404
    end
end

class UnprocessableEntity < APIException
    def initialize(message)
      super(message)
      @status_code = 422
    end
end

class InternalServerError < APIException
    def initialize(message)
      super(message)
      @status_code = 500
    end
end

class NotImplemented < APIException
    def initialize(message)
      super(message)
      @status_code = 501
    end
end

class BadGateway < APIException
    def initialize(message)
      super(message)
      @status_code = 502
    end
end
