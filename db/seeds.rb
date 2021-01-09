require 'csv'

User.create!(name: "John C")

# the participants.tsv file we load
participants_tsv = "db/participant-info-7jan21.csv"

all_scans = {}
CSV.foreach(participants_tsv) do |row|
	subject = row[0]
	session = row[4]
	scan_age = row[6]
	gender = row[7] == "1" ? "Male" : "Female"
  scan = "#{subject}-#{session}"

  # header line
  next if subject !~ /^CC.*/

  # duplicate
  next if all_scans.has_key? scan

  all_scans[scan] = {
      subject: subject,
      session: session,
      gender: gender,
      scan_age: scan_age
  }

  puts "creating record for #{scan} .."
  Scan.create!(subject: subject, session: session)

end
