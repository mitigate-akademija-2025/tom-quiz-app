# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_24_195034) do
  create_table "answers", force: :cascade do |t|
    t.integer "question_id", null: false
    t.text "answer_text"
    t.boolean "is_correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.integer "quiz_id", null: false
    t.text "question_text"
    t.string "question_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "difficulty", default: 1
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_id", null: false
    t.string "language"
    t.string "author"
    t.integer "user_id", null: false
    t.index ["category_id"], name: "index_quizzes_on_category_id"
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "api_key"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "quizzes", "categories"
  add_foreign_key "quizzes", "users"
  add_foreign_key "sessions", "users"
end
