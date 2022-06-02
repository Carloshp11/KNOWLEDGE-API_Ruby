require 'uri'
require 'net/http'
require 'json'

class ExecutionControl
  HEADERS = { "user-agent" => "KAPI Client/0.3.3 (language: scala)",
              "Content-Type" => "application/json" }

  # {base_url: String} -> NilClass
  def initialize(base_url)
    if base_url.empty? | base_url == ""
      @base_url = :'http://127.0.0.1:8000/'
    else
      if base_url[-1] == '/'
        @base_url = base_url[0..-2]
      else
        @base_url = base_url
      end
    end
    @retries_lag = {3 => rand(3..7),
                    2 => rand(8..13),
                    1 => rand(25..35)}
  end

  # table_name: String, execution_is_full: String, layer_name: String, brand_id: String -> Hash
  def read(table_name, execution_is_full, layer_name, brand_id)

    params = {"table_name" => table_name,
              "execution_is_full" => execution_is_full,
              "layer_name" => layer_name,
              "brand_id" => brand_id}

   post("read", params)
  end

  # table_name: String, execution_is_full: String, layer_name: String, brand_id: String, read_since: String, written_to: String -> Hash
  def write(table_name, execution_is_full, layer_name, brand_id, read_since, written_to)

    params = {"table_name" => table_name,
              "execution_is_full" => execution_is_full,
              "layer_name" => layer_name,
              "brand_id" => brand_id,
              "read_since" => read_since,
              "written_to" => written_to}

   post("write", params)
  end


  private

  def recursive_cast(value)
    if value.is_a?(Hash)
      new_value = Hash.new
      value.each do |k, v|
        new_value[k] = recursive_cast v
      end
    elsif value.is_a?(Array)
      new_value = Array.new
      value.each do |v|
        new_value.push(recursive_cast v)
      end
    elsif [true, false].include? value
      new_value = value.to_s
    else
      new_value = value
    end
    new_value
  end

  def recursive_uncast(value)
    if value.is_a?(Hash)
      new_value = Hash.new
      value.each do |k, v|
        new_value[k] = recursive_uncast v
      end
    elsif value.is_a?(Array)
      new_value = Array.new
      value.each do |v|
        new_value.push(recursive_uncast v)
      end
    elsif value.is_a?(String)
      new_value = value.downcase
      if %w[true false].include? new_value
        new_value = "true" == value
      elsif value == 'None'
        new_value = nil
      else
        new_value = value
      end
    else
      new_value = value
    end
    new_value
  end

  # {response: Hash,status_code: Integer} -> NilClass
  def check_error_code(response, status_code)
    if status_code != 200
      if status_code == 400
                raise BadRequest, response["statusMessage"]
      elsif status_code == 401
                raise Unauthorized, response["statusMessage"]
      elsif status_code == 403
                raise Forbidden, response["statusMessage"]
      elsif status_code == 404
                raise NotFoundError, response["statusMessage"]
      elsif status_code == 422
                raise UnprocessableEntity, response["statusMessage"]
      elsif status_code == 500
                raise InternalServerError, response["statusMessage"]
      elsif status_code == 501
                raise NotImplemented, response["statusMessage"]
      elsif status_code == 502
                raise BadGateway, response["statusMessage"]
      else
        raise APIException, response.detail
      end
    end
  end

  # {params: Hash} -> Hash
  def get(params)
    params = recursive_cast params
    params = params.select { |_, value| !value.nil? }

    uri = URI(@baseUrl)
    uri.query = URI.encode_www_form(params)

    retries = 3

    begin
      raw_response = Net::HTTP.get_response(uri, HEADERS)
    rescue => error
      lag = @retries_lag[retries]
      retries -= 1
      puts "Connection to the server failed. Error message: #{error.message}"
      puts "Retrying in #{lag} seconds. Retries left: #{retries}"
      sleep(lag)
      if retries > 0
        retry
      else
        raise error
      end
    end

    response = recursive_uncast(raw_response.body[:content])
    response['raw'] = raw_response

    if ENV["uncheck_api_errors"].nil?
        check_error_code(response = response,
                         status_code=response[:statusCode])
    end
    response
  end

  # {resource: String, params: Hash} -> Hash
  def post(resource, params)
    params = recursive_cast params
    params = params.select { |_, value| !value.nil? }

    if resource.include? "_"
      resource["_"] = "-"
    end
    uri = URI("#{@base_url}/function/#{resource}.kapi")

    retries = 3

    begin
      raw_response = Net::HTTP.post(uri, params.to_json, HEADERS)
    rescue => error
      lag = @retries_lag[retries]
      retries -= 1
      puts "Connection to the server failed. Error message: #{error.message}"
      puts "Retrying in #{lag} seconds. Retries left: #{retries}"
      sleep(lag)
      if retries > 0
        retry
      else
        raise error
      end
    end

    response = recursive_uncast(JSON(raw_response.body))
    response['raw'] = raw_response
    if ENV["uncheck_api_errors"].nil?
        check_error_code(response = response,
                         status_code=response['statusCode'])
    end

    response
  end
end
