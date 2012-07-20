class Config
  def self.load(file_path)
    @@configs ||= {}
    
    name            = File.basename(file_path).gsub(/\..+/i,'')
    config          = JSON.parse(File.open(file_path, "r").read)
    @@configs[name] = config[Server.env]
    @@configs[name].merge!(self.send("default_#{file_path}")) if respond_to?("default_#{file_path}")
  end

  def self.method_missing(method_name, args*, &block)
    if @@configs[method_name].present?
      @@configs[method_name]
    else
      super(method_name, args*, &block)
    end
  end

  
end
