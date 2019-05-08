# This expands on simple_sql_templates.rb
# To show how you could use this library in practice

# Set up ActiveRecord
require 'active_record'
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Schema.define do
  self.verbose = false
  create_table(:users) { |t| t.string :name }
  create_table(:posts) { |t| t.string :name; t.integer :user_id }
end

# Models
User = Class.new(ActiveRecord::Base) { has_many :posts  }
Post = Class.new(ActiveRecord::Base) { belongs_to :user }

# Seed Data
kanye = User.create! name: 'Kanye', posts: [Post.new(name: 'Keep ya love lockdown')]
keanu = User.create! name: 'Keanu', posts: [Post.new(name: 'Life is good when you’ve a good sandwich')]
josh  = User.create! name: 'Josh',  posts: [Post.new(name: 'yo ho ho'), Post.new(name: 'and a bottle of rum')]

# Potential lib code that wires ticked templates into Sqlite
class TemplatedSqlite
  def initialize(connection)
    @connection = connection
  end
  def exec(template)
    template = template.flatten # merge nested templates into a single template
    query    = template.strings.join(??)
    binds    = template.interpolations
    @connection.execute(query, binds).map do |row|
      row.each_with_object({}) do |(key, value), attributes|
        attributes[key.intern] = value if key.is_a? String
      end
    end
  end
end
sqlite = TemplatedSqlite.new(ActiveRecord::Base.connection.raw_connection)

# Load ticked templates
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ticked/templates'
using Ticked::Templates

# We can now write SQL, but the interpolations are kept separate, so this is safe
template = <<~`SQL`
  SELECT id, name FROM posts WHERE user_id = ${josh.id}
SQL
template                # => `SELECT id, name FROM posts WHERE user_id = ${3}\n`
template.strings        # => ["SELECT id, name FROM posts WHERE user_id = ", "\n"]
template.interpolations # => [3]
sqlite.exec template    # => [{:id=>3, :name=>"yo ho ho"}, {:id=>4, :name=>"and a bottle of rum"}]

# We can even compose templates
query1 = `select name from posts where user_id = ${kanye.id}`
query2 = `select name from posts where user_id = ${josh.id}`
sqlite.exec <<~`SQL`  # => [{:name=>"Keep ya love lockdown"}, {:name=>"and a bottle of rum"}, {:name=>"yo ho ho"}]
  ${query1}
  UNION
  ${query2}
SQL
