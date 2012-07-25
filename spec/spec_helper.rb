$LOAD_PATH.unshift('.') unless $LOAD_PATH.include?('.')

require File.expand_path(File.dirname(__FILE__) + '/../lib/revisionable')

require 'spec/config/config'
require 'support/user'
require 'support/post'
