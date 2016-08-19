require 'json'
require "jsontemplate/version"

class JsonTemplate
    attr_reader :json
    attr_accessor :properties_file, :secrets_file

    def initialize(src, path=nil)
        path ||= src.kind_of?(String) ? src : nil
        @path = path || (src.respond_to?(:path) ? src.path : nil)
        @dir  = File.expand_path(path ? File.dirname(path) : ".")

        @properties_file = File.join(@dir,"properties.json")
        @secrets_file = File.join(@dir,"secrets.json")

        data = src.respond_to?(:read) ? src.read : File.read(src)
        @json = JSON.load(data)
    end

    def process_dirmerge(pattern)
        files = Dir.glob(@dir+"/"+pattern)
        files.collect do |path|
            r = JsonTemplate.new(path,@path).process_dict
            key=File.basename(path).split(".")[0..-2].join(".")
            [key, r]
        end.flatten(1)
    end

    def process_flookup(file, v)
        map = JsonTemplate.new(file,@path).process_dict
        map[v]
    end

    def process_dict(root=nil)
        root ||= @json

        return root if !root.is_a?(Hash) && !root.is_a?(Array)

        pairs = root.collect do |k,v|
            if v.is_a?(Hash)
                v = process_dict(v)
            elsif v.is_a?(Array)
                v = v.collect {|v_| process_dict(v_)}
            end

            if k == "$DirMerge"
                process_dirmerge(v)
            elsif k == "$FLookup"
                process_flookup(*v)
            elsif k == "$Prop"
                process_flookup(@properties_file, v)
            elsif k == "$Secret"
                process_flookup(@secrets_file, v)
            elsif k[0] == "$"
                raise "Unknown directive #{k}"
            else
                [k,v]
            end
        end
        if pairs.length == 1 && !pairs.first.kind_of?(Array)
            pairs.first
        else
            Hash[*pairs.flatten(1)]
        end
    end
end


