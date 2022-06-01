require 'uri'
require 'net/http'
require 'json'

class Configuration
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

  # user_token: String, component_name: String, component_type: String, branch: String, flavour: String, brand_id: String, environment: String, version: Integer, dynamic_insertion_params: Hash -> Hash
  def get_configuration(user_token, component_name, component_type, branch = "default", flavour = "default", brand_id = "default", environment = "default", version = nil, dynamic_insertion_params = nil)

    params = {"user_token" => user_token,
              "component_name" => component_name,
              "component_type" => component_type,
              "branch" => branch,
              "flavour" => flavour,
              "brand_id" => brand_id,
              "environment" => environment,
              "version" => version,
              "dynamic_insertion_params" => dynamic_insertion_params}

   post("get-configuration", params)
  end

  # user_token: String, recipe: Hash -> Hash
  def get_multiple_configurations(user_token, recipe)

    params = {"user_token" => user_token,
              "recipe" => recipe}

   post("get-multiple-configurations", params)
  end

  # user_token: String, config: Hash, component_name: String, component_type: String, branch: String, flavour: String, brand_id: String, environment: String, author: String, baseconfig_id: Integer -> Hash
  def upload_configuration(user_token, config, component_name, component_type, branch = "default", flavour = "default", brand_id = "default", environment = "default", author = "unknown", baseconfig_id = nil)

    params = {"user_token" => user_token,
              "config" => config,
              "component_name" => component_name,
              "component_type" => component_type,
              "branch" => branch,
              "flavour" => flavour,
              "brand_id" => brand_id,
              "environment" => environment,
              "author" => author,
              "baseconfig_id" => baseconfig_id}

   post("upload-configuration", params)
  end

  # user_token: String, config: Hash, component_name: String, component_type: String, changes_infra: String -> Hash
  def upload_base_configuration(user_token, config, component_name, component_type, changes_infra = nil)

    params = {"user_token" => user_token,
              "config" => config,
              "component_name" => component_name,
              "component_type" => component_type,
              "changes_infra" => changes_infra}

   post("upload-base-configuration", params)
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
