# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130805074257) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "notifications", :force => true do |t|
    t.integer  "widget_id"
    t.datetime "date"
    t.integer  "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "probes", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "samples", :force => true do |t|
    t.float    "value"
    t.datetime "date"
    t.integer  "widget_id"
    t.integer  "status"
    t.string   "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "templates", :force => true do |t|
    t.string   "uid"
    t.text     "body"
    t.integer  "widget_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "thresholds", :force => true do |t|
    t.string   "operator"
    t.float    "value"
    t.string   "alert"
    t.integer  "widget_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "thresholds", ["widget_id"], :name => "index_thresholds_on_widget_id"

  create_table "widgets", :force => true do |t|
    t.string   "title"
    t.string   "uri"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.float    "min",           :default => 0.0
    t.float    "max",           :default => 100.0
    t.string   "unit",          :default => "%"
    t.string   "refresh_delay", :default => "1000"
    t.integer  "position",      :default => 0
    t.string   "template",      :default => "widget-graph"
    t.integer  "probe_id"
    t.string   "args"
  end

end
