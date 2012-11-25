class SpeedDump < Thor
  desc "load_dump FILE", "loads a dump with the given file name in an optimized fashion"
  method_option :user_name, :aliases => "-u", :desc => "Mysql username, default = root"
  method_option :password,  :aliases => "-p", :desc => "Mysql password, default = nil"
  def load_dump(file)
    puts "you're using the following file name #{file}"
    DbOptimizer.new(file).optimize!
    puts "File optimized"
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

    File.rename(@file_name , @file_name + '.old') 
    File.rename(new_file_path, @file_name)
  end

  private
  def get_base_name
    File.basename(@db_file)
  end

  def get_missing_settings
    puts @detected_settings
    OPTIMIZED_SETTINGS - @detected_settings.compact.uniq
  end

  def already_optimized?
    @db_file.rewind
    @detected_settings.clear
    (1..10).each { |line| @detected_settings << line if OPTIMIZED_SETTINGS.find_index(line) }
    @db_file.rewind
  end

  def new_file_path
    "#{@db_file.path.gsub(File.basename(@db_file), '')}tmp_file"
  end
end
