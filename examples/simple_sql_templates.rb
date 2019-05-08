# Simple example showing how to use this lib to safely compose SQL
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ticked'
using Ticked::Templates # If you prefer, you can include/extend instead

def posts(type:, is_published:)
  subquery = <<~`SQL`
    SELECT *
    FROM users
    WHERE user_type = ${type}
  SQL

  <<~`SQL`.flatten.chomp
    SELECT *
    FROM posts
    WHERE author_id in (${subquery})
    AND is_published = ${is_published}
  SQL
end


# The inspection of it looks like it's interpolated,
# but that's just how we display it, to make it easier to read.
template = posts type: 'admin', is_published: true
  # => `SELECT *
  #    FROM posts
  #    WHERE author_id in (SELECT *
  #    FROM users
  #    WHERE user_type = ${"admin"}
  #    )
  #    AND is_published = ${true}`

# In reality, we store the values separately:
template.interpolations
  # => ["admin", true]
template.strings
  # => ["SELECT *\n" +
  #     "FROM posts\n" +
  #     "WHERE author_id in (SELECT *\n" +
  #     "FROM users\n" +
  #     "WHERE user_type = ",
  #     "\n" + ")\n" + "AND is_published = ",
  #     ""]
