begin
    $LOAD_PATH.unshift File.join(File.dirname(__FILE__), "Libraries")
#    require "pluggaloid"
    puts "Hello mruby world!"

    Delayer.default = Delayer.generate_class(priority: %i<high normal low>, default: :normal)

    plugins = []
    require File.join(File::dirname(__FILE__), 'hoge')
rescue Exception => e
    puts e.inspect.gsub(File::dirname(__FILE__), "/{APP_DIR}").gsub(IMAST_PLUGIN_DIRECTORY, "/{PLUGIN_DIR}")
    puts e.backtrace.map{|v| "\t" + v}.join("\n").gsub(File::dirname(__FILE__), "/{APP_DIR}").gsub(IMAST_PLUGIN_DIRECTORY, "/{PLUGIN_DIR}")
end
