require 'test/unit'
require "rubygems"
require 'active_record'
require 
require 'active_support'

class MyModel < ActiveRecord::Base
  has_attached_file :data,
  :styles => {
    :thumb => "50x50#",
    :large => "640x480#"
  }
 
  validates_attachment_presence :data
  validates_attachment_content_type :data, 
  :content_type => ['image/jpeg', 'image/pjpeg', 
                                   'image/jpg', 'image/png']
end

class PaperclipColumnTest < Test::Unit::TestCase
  def setup
    @model = MyModel.new
  end

  def test__sth
    
  end
end

