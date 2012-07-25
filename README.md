MongoMapper Revisionable
======================
A MongoMapper plugin which enables document revision tracking.

Install
-------
$ gem install mm-revisionable

Note on Patches/Pull Requests
-----------------------------
* Fork the project
* Make your feature addition or bug fix.
* Add tests for it. This is critical so that things dont break unintentionally.
* Commit, do not make any changes in the rakefile, version, or history. (If you want to have your own version, that is fine but bump the version in a commit by itself so I can ignore it when I pull)
* Send me a pull request.

Usage
-----
The following example should demonstrate how to use revisioning well :

    require 'mongo_mapper'
    require 'revisionable' # gem 'mm-revisionable', :require => 'revisionable' -- Put this in your Gemfile if you're using bundler

    class Thing
        include MongoMapper::Document
        plugin Revisionable

        limit_revisions_to 20
        #:limit here defines the size of the revision history that will be loaded into memory,
        #By default, if not specified, the value is 10, if you wish to load all revisions set it to 0

        key :name, String, :required => true
        key :date, Time
    end

    thing = Thing.create(:name => 'Dhruva Sagar', :date => Time.now)

    thing.name = 'Change Thing'
    thing.save

    #Alternatively you can also pass in a "updater_id" to the save method which will be saved within the revision, this can be used to track who made changes
    #example :
    #thing.save :updater_id => "4cef9936f61aa33717000001"

    #Also you can now pass :updater_id to update_attributes
    #example :
    #thing.update_attributes(:updater_id => "4cef9936f61aa33717000001", params[:thing])

    thing.revisions_count
    #=> 2

    thing.revisions
    #=> [#<Revision _id: BSON::ObjectId('4cef96c4f61aa33621000002'), data: {"_id"=>BSON::ObjectId('4cef96c4f61aa33621000001'), "revision_message"=>nil, "revision_number"=>nil, "name"=>"Dhruva Sagar", "date"=>2010-11-26 11:15:16 UTC}, date: 2010-11-26 11:15:16 UTC, pos: 0, doc_id: "4cef96c4f61aa33621000001", message: nil, updater_id: nil>, #<Revision _id: BSON::ObjectId('4cef96c4f61aa33621000003'), data: {"_id"=>BSON::ObjectId('4cef96c4f61aa33621000001'), "revision_message"=>nil, "revision_number"=>nil, "name"=>"Change Thing", "date"=>2010-11-26 11:15:16 UTC}, date: 2010-11-26 11:15:16 UTC, pos: 1, doc_id: "4cef96c4f61aa33621000001", message: nil, updater_id: nil>]

    thing.all_revisions
    #=> #<Plucky::Query doc_id: "4cef96c4f61aa33621000001", sort: [["pos", -1]]>

    thing.rollback(:first)
    #=> #<Thing _id: BSON::ObjectId('4cef96c4f61aa33621000001'), revision_message: nil, revision_number: 0, name: "Dhruva Sagar", date: 2010-11-26 11:15:16 UTC>

    thing.rollback(:last)
    #=> #<Thing _id: BSON::ObjectId('4cef96c4f61aa33621000001'), revision_message: nil, revision_number: 0, name: "Dhruva Sagar", date: 2010-11-26 11:15:16 UTC>

    thing.rollback!(:latest)
    #=> #<Thing _id: BSON::ObjectId('4cef96c4f61aa33621000001'), revision_message: nil, revision_number: 1, name: "Change Thing", date: 2010-11-26 11:15:16 UTC>
    #rollback! saves the document as well

    thing.diff(:name, 0, 1)
    #=> "<del class=\"differ\">Change</del><ins class=\"differ\">Dhruva</ins> <del class=\"differ\">Thing</del><ins class=\"differ\">Sagar</ins>"

    thing.diff(:name, 0, 1, :ascii)
    #=> "{\"Change\" >> \"Dhruva\"} {\"Thing\" >> \"Sagar\"}"

    thing.diff(:name, 0, 1, :color)
    #=> "\e[31mChange\e[0m\e[32mDhruva\e[0m \e[31mThing\e[0m\e[32mSagar\e[0m"

    thing.current_revision
    #=> #<Revision _id: BSON::ObjectId('4cf03822f61aa30fd8000004'), data: {"_id"=>BSON::ObjectId('4cf03816f61aa30fd8000001'), "revision_message"=>nil, "revision_number"=>nil, "name"=>"Change Thing", "date"=>2010-11-26 22:43:34 UTC}, date: 2010-11-26 22:43:46 UTC, pos: nil, doc_id: "4cf03816f61aa30fd8000001", message: nil, updater_id: nil>

    thing.revision_at(:first)
    #=> #<Revision _id: BSON::ObjectId('4cef96c4f61aa33621000002'), data: {"_id"=>BSON::ObjectId('4cef96c4f61aa33621000001'), "revision_message"=>nil, "revision_number"=>nil, "name"=>"Dhruva Sagar", "date"=>2010-11-26 11:15:16 UTC}, date: 2010-11-26 11:15:16 UTC, pos: 0, doc_id: "4cef96c4f61aa33621000001", message: nil, updater_id: nil>

    thing.revision_at(:current)
    #=> #<Revision _id: BSON::ObjectId('4cef986df61aa33621000004'), data: {"_id"=>BSON::ObjectId('4cef96c4f61aa33621000001'), "revision_message"=>nil, "revision_number"=>1, "name"=>"Change Thing", "date"=>2010-11-26 11:15:16 UTC}, date: 2010-11-26 11:22:21 UTC, pos: nil, doc_id: "4cef96c4f61aa33621000001", message: nil, updater_id: nil>

    thing.revision_at(:last)
    #=> #<Revision _id: BSON::ObjectId('4cef96c4f61aa33621000002'), data: {"_id"=>BSON::ObjectId('4cef96c4f61aa33621000001'), "revision_message"=>nil, "revision_number"=>nil, "name"=>"Dhruva Sagar", "date"=>2010-11-26 11:15:16 UTC}, date: 2010-11-26 11:15:16 UTC, pos: 0, doc_id: "4cef96c4f61aa33621000001", message: nil, updater_id: nil>

    thing.revision_at(:latest)
    #=> #<Revision _id: BSON::ObjectId('4cef96c4f61aa33621000003'), data: {"_id"=>BSON::ObjectId('4cef96c4f61aa33621000001'), "revision_message"=>nil, "revision_number"=>nil, "name"=>"Change Thing", "date"=>2010-11-26 11:15:16 UTC}, date: 2010-11-26 11:15:16 UTC, pos: 1, doc_id: "4cef96c4f61aa33621000001", message: nil, updater_id: nil>

    thing.revision_at(10)
    #=> nil

    thing.delete_revision(:all) # This will delete all revisions and reset revisions_count to 0
    # Or
    thing.delete_revision(1) # This will delete the revision at pos = 1, and reset the pos of all subsequent revisions to one less to maintain linear sequence.
    # delete_revision API pos follows he revision_at API in that you can use :first, :current, :last, :latest
    thing.delete_revision(:first)
    thing.delete_revision(:current)
    thing.delete_revision(:last)
    thing.delete_revision(:latest)


Problems or Questions?
----------------------
Hit up on the mongomapper google group:
http://groups.google.com/group/mongomapper

Hop on IRC:
irc://chat.freenode.net/#mongomapper

Copyright
---------
See LICENSE for details.
