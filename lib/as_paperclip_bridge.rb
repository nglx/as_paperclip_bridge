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
    end
    
    alias_method_chain :initialize, :paperclip
    
    def configure_paperclip_field(field)
      self.columns << field 
      self.columns[field].list_ui ||= self.model.attachment_definitions[:data][:styles].include?(:thumb) ? :paperclip_thumb : :paperclip_link
      self.columns[field].form_ui ||= :paperclip

      ['file_name', 'content_type', 'file_size', 'updated_at'].each{ |f|
        self.columns.exclude("#{field}_#{f}".to_sym)
      }
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
  end
  
  def paperclip_fields
    @paperclip_fields||=PaperclipHelpers.paperclip_fields(self)
  end
end