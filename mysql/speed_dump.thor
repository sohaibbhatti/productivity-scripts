class SpeedDump < Thor
  desc "load_dump FILE", "loads a dump with the given file name in an optimized fashion"
  method_option :user_name, :aliases => "-u", :desc => "Mysql username, default = root"
  method_option :password,  :aliases => "-p", :desc => "Mysql password, default = nil"
  def load_dump(file)
    puts "you're using the following file name #{file}"
    DbOptimizer.new(file).optimize!
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
    @detected_settings = []
    already_optimized?
  end

  def optimize!
    return true if get_missing_settings.empty?
    File.open('tmp_file', 'w') do |fo|
      get_missing_settings.each { |settings| fo.puts settings }
      File.foreach(@db_file) { |li| fo.puts li }
    end

    file_name = get_base_name
    File.rename(file_name , file_name + '.old')
    File.rename('tmp_file', file_name)
  end

  private
  def get_base_name
    File.basename(@db_file)
  end

  def get_missing_settings
    OPTIMIZED_SETTINGS - @detected_settings.compact.uniq
  end

  def already_optimized?
    @db_file.rewind
    @detected_settings.clear
    (1..10).each { |line| @detected_settings << line if OPTIMIZED_SETTINGS.find_index(line) }
    @db_file.rewind
  end
end
