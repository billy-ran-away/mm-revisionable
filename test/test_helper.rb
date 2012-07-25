$LOAD_PATH.unshift('.') unless $LOAD_PATH.include?('.')

require File.expand_path(File.dirname(__FILE__) + '/../lib/revisionable')
require 'test/config/config'

require 'pp'
require 'shoulda'

require 'test/models/post'
require 'test/models/user'

User.delete_all
