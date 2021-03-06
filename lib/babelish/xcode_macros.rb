module Babelish
  class XcodeMacros
    attr_accessor :content, :table, :keys
    def initialize(table = "Localizable", keys = {})
      @content = ""
      @table = table
      @keys = keys
    end

    def self.write_macros(file_path, table, keys)
      instance = XcodeMacros.new
      instance.process(table, keys)
      instance.write_content(file_path)
    end

    def process(table, keys)
      keys.each do |key|
        clean_key = key.gsub(' ', '')
        clean_key.gsub!(/[[:punct:]]/, '_')       
        clean_key.gsub!('__', '_')
        clean_key = clean_key[1..clean_key.size-1] if clean_key[0] == '_'
        clean_key = clean_key[0..clean_key.size-2] if clean_key.size > 1 and clean_key[clean_key.size-1] == '_'
        macro_name = "LS_#{clean_key.upcase}" 
        macro_name += "_#{table.upcase}" if table != "Localizable" 
        @content << String.new(<<-EOS)
#define #{macro_name} NSLocalizedStringFromTable(@"#{key}",@"#{table}",@"")
        EOS
      end
      @content
    end

    def write_content(file_path)
      header = String.new(<<-EOS)
//
//  file_path
//  
//  This file was generated by Babelish
//  
//  https://github.com/netbe/babelish
//
        EOS
      header.gsub! "file_path", File.basename(file_path)
      file = File.new(file_path, "w")
      file.write header + @content
      file.close
    end
  end
end
