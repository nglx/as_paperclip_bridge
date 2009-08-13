module ActiveScaffold::Config
  class Core < Base

    def initialize_with_paperclip(model_id)
      initialize_without_paperclip(model_id)
      return unless PaperclipHelpers.has_paperclip_fields(self.model)

      self.model.send :extend, PaperclipHelpers

      self.update.multipart = true
      self.create.multipart = true

      self.model.paperclip_fields.each{ |field|
        configure_paperclip_field(field.to_sym)
      }

      # include the "delete" helpers for use with active scaffold, unless they are already included
      self.model.generate_delete_helpers
    end

    alias_method_chain :initialize, :paperclip

    def configure_paperclip_field(field)
      self.columns << field
      self.columns[field].list_ui ||= self.model.attachment_definitions[field][:styles].try(:include?, :thumbnail) ? :paperclip_thumb : :paperclip_link
      self.columns[field].form_ui ||= :paperclip

      ['file_name', 'content_type', 'file_size', 'updated_at'].each{ |f|
        self.columns.exclude("#{field}_#{f}".to_sym)
      }

      #very dirty hack, but somehow I have to tell AS to call the virtual delete_#field attribute method. This can't be attachted to the
      #same column (as it used for file_column), as it wouldn't be called in case the column value is empty, aka. no picture uploaded
      #so choos first column which is not a paperclip column
      #TODO: what todo if no column found!?
      column = nil
      self.columns.each do |c|
        column ||= c unless self.model.paperclip_fields.include?(c.name.to_sym)
      end
      column.params.add "delete_#{field}" if column

    end
  end
end

module PaperclipHelpers
  class << self
    def paperclip_fields(klass)
      klass.attachment_definitions.nil? ? [] : klass.attachment_definitions.keys
    end

    def has_paperclip_fields(klass)
      paperclip_fields(klass).size > 0 if paperclip_fields(klass)
    end

    def generate_delete_helpers(klass)
      paperclip_fields(klass).each { |field|
        klass.send :class_eval, <<-EOF, __FILE__, __LINE__ + 1  unless klass.methods.include?("#{field}_with_delete=")
          attr_reader :delete_#{field}

          def delete_#{field}=(value)
            value = (value=="true") if String===value
            return unless value

            # passing nil to the file column causes the file to be deleted.  Don't delete if we just uploaded a file!
            self.#{field}.destroy unless self.#{field}.dirty?
          end
        EOF
      }
    end
  end

  def paperclip_fields
    @paperclip_fields||=PaperclipHelpers.paperclip_fields(self)
  end
  
  def generate_delete_helpers
    PaperclipHelpers.generate_delete_helpers(self)
  end    
end