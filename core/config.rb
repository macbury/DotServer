class DConfig
  def self.load(file_path)
    @@configs ||= {}
    
    name            = File.basename(file_path).gsub(/\..+/i,'')
    config          = JSON.parse(File.open(file_path, "r").read)
    @@configs[name] = config[Server.env]

    if respond_to?("default_#{name}")
      default_config = self.send("default_#{name}")
      @@configs[name] = default_config.merge(@@configs[name]) 
    end
  end

  def self.method_missing(method_name, *args, &block)
    if @@configs[method_name.to_s].present?
      @@configs[method_name.to_s]
    else
      super(method_name, *args, &block)
    end
  end
  
  def self.default_database
    {
      :database => "dot_server",
      :hosts => ["localhost:27017"]
    }
  end

  def self.write_example(file_path)
    name = File.basename(file_path).gsub(/\..+/i,'')
    out  = {}
    ["production", "test", "development"].each { |env| out[env] = self.send("default_#{name}") }
    File.open(file_path, "w") { |file| file.write(JSON.pretty_generate(out)) }
  end

end
