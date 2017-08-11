require "mysql"

def rnd_char(rnd)
  v = rnd.rand(62)
  if v < 10
    '0' + v
  elsif v < 10 + 26
    'a' + v - 10
  else
    'A' + v - 36
  end
end

DB.open "mysql://test@localhost/test" do |db|
  db.exec("DROP TABLE IF EXISTS perf_test")
  db.exec("CREATE TABLE perf_test(
  	id INT AUTO_INCREMENT PRIMARY KEY,
  	flag TINYINT(1) DEFAULT 0 NOT NULL,
  	name VARCHAR(255) NOT NULL,
  	description TEXT NOT NULL
  	) ENGINE INNODB"
  )
  rnd = Random.new
  n_buf = Pointer(UInt8).malloc(15)
  d_buf = Pointer(UInt8).malloc(40000)
  db.transaction do |tr|
    con = tr.connection
    10000.times do
      n_len = rnd.rand(3..15)
      n_len.times { |i| n_buf[i] = rnd_char(rnd).ord.to_u8 }
      n = String.new(n_buf, n_len)
      d_len = (rnd.rand(200.0) ** 2).to_i
      d_len.times { |i| d_buf[i] = rnd_char(rnd).ord.to_u8 }
      d = String.new(d_buf, d_len)
      con.exec("INSERT INTO perf_test (name, description) VALUES(?, ?)", n, d)
    end
  end
end
