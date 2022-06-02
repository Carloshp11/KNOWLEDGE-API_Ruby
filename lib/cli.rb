#noinspection RubyInstanceMethodNamingConvention
def cliConfiguration
  require_relative 'arg_parser'
  require_relative 'Configuration'
  require_relative 'api_errors'

  args = ArgParserConfiguration.new.parse(ARGV)
  if args[:verbose]
    puts :'Acessed via cli'
    puts :arguments
    puts args
  end

  api = Configuration.new(base_url=args[:url])

  begin
    entry_point = api.method(args[:entry_point])
  rescue
    raise ArgumentError, "Calling non-existing entry point: #{args[:entry_point]}"
  end

  entry_point.parameters.each do |optional, name|
    if optional == :req
      raise ArgumentError, "Argument #{name} required for execution of #{args[:entry_point]} entry point" unless args.has_key?(name)
    end

  end


  if args[:entry_point] == 'get_configuration'
    response = api.get_configuration(user_token=args[:user_token],
                                     component_name=args[:component_name],
                                     component_type=args[:component_type],
                                     branch=args[:branch],
                                     flavour=args[:flavour],
                                     brand_id=args[:brand_id],
                                     environment=args[:environment],
                                     version=args[:version],
                                     dynamic_insertion_params=args[:dynamic_insertion_params])
    elsif args[:entry_point] == 'get_multiple_configurations'
    response = api.get_multiple_configurations(user_token=args[:user_token],
                                     recipe=args[:recipe])
    elsif args[:entry_point] == 'upload_configuration'
    response = api.upload_configuration(user_token=args[:user_token],
                                     config=args[:config],
                                     component_name=args[:component_name],
                                     component_type=args[:component_type],
                                     branch=args[:branch],
                                     flavour=args[:flavour],
                                     brand_id=args[:brand_id],
                                     environment=args[:environment],
                                     author=args[:author],
                                     baseconfig_id=args[:baseconfig_id])
    elsif args[:entry_point] == 'upload_base_configuration'
    response = api.upload_base_configuration(user_token=args[:user_token],
                                     config=args[:config],
                                     component_name=args[:component_name],
                                     component_type=args[:component_type],
                                     changes_infra=args[:changes_infra])
  end
  puts JSON(response)
end


#noinspection RubyInstanceMethodNamingConvention
def cliExecutionControl
  require_relative 'arg_parser'
  require_relative 'ExecutionControl'
  require_relative 'api_errors'

  args = ArgParserExecutionControl.new.parse(ARGV)
  if args[:verbose]
    puts :'Acessed via cli'
    puts :arguments
    puts args
  end

  api = ExecutionControl.new(base_url=args[:url])

  begin
    entry_point = api.method(args[:entry_point])
  rescue
    raise ArgumentError, "Calling non-existing entry point: #{args[:entry_point]}"
  end

  entry_point.parameters.each do |optional, name|
    if optional == :req
      raise ArgumentError, "Argument #{name} required for execution of #{args[:entry_point]} entry point" unless args.has_key?(name)
    end

  end


  if args[:entry_point] == 'read'
    response = api.read(table_name=args[:table_name],
                                     execution_is_full=args[:execution_is_full],
                                     layer_name=args[:layer_name],
                                     brand_id=args[:brand_id])
    elsif args[:entry_point] == 'write'
    response = api.write(table_name=args[:table_name],
                                     execution_is_full=args[:execution_is_full],
                                     layer_name=args[:layer_name],
                                     brand_id=args[:brand_id],
                                     read_since=args[:read_since],
                                     written_to=args[:written_to])
  end
  puts JSON(response)
end
