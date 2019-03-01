class Plugin < Pluggaloid::Plugin
    # mikutterコマンドを定義
    # ==== Args
    # [slug] コマンドスラッグ
    # [options] コマンドオプション
    # [&exec] コマンドの実行内容
    def command(slug, options, &exec)
        command = options.merge(slug: slug, exec: exec, plugin: @name).freeze
        add_event_filter(:command){ |menu|
            menu[slug] = command
            [menu]
        }
    end
end

Dir.foreach(IMAST_PLUGIN_DIRECTORY) { |f|
    p f
    require File.join(IMAST_PLUGIN_DIRECTORY, f) if f.end_with? ".rb"
}

p Plugin.filtering(:command, Hash.new)
