require 'json'
require "jsontemplate/version"

class JsonTemplate
    def initialize(path)
        @path = path
        @dir  = File.dirname(path)
        @json = JSON.load(File.read(path))
    end

    def process_dirmerge(pattern)
        files = Dir.glob(@dir+"/"+pattern)
        files.collect do |path|
            r = JsonTemplate.new(path).process_dict
            key=File.basename(path).split(".")[0..-2].join(".")
            [key, r]
        end.flatten(1)
    end

    def process_dict(root=nil)
        root ||= @json

        pairs = root.collect do |k,v|
            if v.is_a?(Hash)
                v = process_dict(v)
            end

            if k == "$DirMerge"
                process_dirmerge(v)
            elsif k[0] == "$"
                raise "Unknown directive #{k}"
            else
                [[k,v]]
            end
        end
        Hash[*pairs.flatten(2)]
    end
end


