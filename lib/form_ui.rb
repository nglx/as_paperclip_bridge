module ActiveScaffold
  module Helpers
    module FormColumnHelpers
      def active_scaffold_input_paperclip(column, options)
        if @record.send("#{column.name}_file_name") 
          if @record.send(column.name).styles.include?(:thumb)
            content_tag(
              :div, 
              content_tag(
                :div, 
                link_to(image_tag(@record.send(column.name).url(:thumb), :border => 0), @record.send(column.name).url, :popup => true) + " " + 
                hidden_field(:record, "delete_#{column.name}", :value => "false")
              )
            )
          else
            content_tag(:p, link_to(@record.send("#{column.name}_file_name"), @record.send(column.name).url, :popup => true), :class => "text-input")+" "+
            hidden_field(:record, "delete_#{column.name}", :value => "false")
          end
        else
          file_field(:record, column.name, options)+" "+"<input type=hidden name='record[photos][-1][delete]'>"
        end
      end
    end
  end
end