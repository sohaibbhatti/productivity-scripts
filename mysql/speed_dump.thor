class SpeedDump < Thor
  desc "load_dump FILE", "loads a dump with the given file name in an optimized fashion"
  method_option :user_name, :aliases => "-u", :desc => "Mysql username, default = root"
  method_option :password,  :aliases => "-p", :desc => "Mysql password, default = nil"
  method_option :database,  :aliases => "-d", :desc => "MYsql Database, default = Moviepass_development"
  def load_dump(file)
    puts "you're using the following file name #{file}"
    DbOptimizer.new(file).optimize!
    puts "File optimized"
    puts "Loading Dump"
    Db.new(file, options).load_db
    puts "Dump Loaded"
  end
end

class Db
  def initialize(file_name, options)
    @file_name = file_name
    init_db_settings options
  end

  def load_db
    if @password
      `mysql -u#{@user_name} -p#{@password} #{@database} < #{@file_name}`
    else
      `mysql -u#{@user_name} #{@database} < #{@file_name}`
    end
  end

  private
  def init_db_settings(options)
    @user_name = options[:user_name] || 'root'
    @database  = options[:database] || "Moviepass_development"
    @password ||= options[:password]
  end
end

class DbOptimizer
  OPTIMIZED_SETTINGS = [
    "SET autocommit=0;",
    "SET unique_checks=0;",
    "SET foreign_key_checks=0;"
  ]

  def initialize(file)
    @db_file = File.open(file)
    @file_name = file
    @detected_settings = []
    already_optimized?
  end

  def optimize!
    puts "FILE ALREADY OPTIMIZED" if get_missing_settings.empty?
    return true if get_missing_settings.empty?
    File.open(new_file_path, 'w') do |fo|
      get_missing_settings.each { |settings| fo.puts settings }
      File.foreach(@db_file) { |li| fo.puts li }
    end

    File.delete @db_file
    File.rename new_file_path, @file_name
  end

  private
  def get_base_name
    File.basename(@db_file)
  end

  def get_missing_settings
    OPTIMIZED_SETTINGS - @detected_settings.compact.uniq
  end

  def already_optimized?
    maintain_file_index_integrity do
      @detected_settings.clear
      10.times { @detected_settings << find_setting }
    end
  end

  def find_setting
    line = @db_file.gets.delete("\n")
    line if OPTIMIZED_SETTINGS.find_index(line)
  end

  def maintain_file_index_integrity
    @db_file.rewind
    yield if block_given?
    @db_file.rewind
  end

  def new_file_path
    "#{@db_file.path.gsub(File.basename(@db_file), '')}tmp_file"
  end
end
