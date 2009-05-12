module ActiveScaffold
  module Helpers
    module ListColumnHelpers

      def active_scaffold_column_paperclip_link(column, record)
        return nil if record.send(column.name).nil?
        link_to( 
          record.send("#{column.name}_file_name"), 
          record.send(column.name).url, 
          :popup => true)
      end
      
      def active_scaffold_column_paperclip_thumb(column, record)
        link_to( 
          image_tag(record.send(column.name).url(:thumb), :border => 0), 
          record.send(column.name).url, 
          :popup => true)
      end
    end
  end
end
