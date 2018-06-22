require 'csv'

User.create!(name: "John C")

# the participants.tsv file we load
participants_tsv = "db/qc_participants.tsv"

all_scans = {}
CSV.foreach(participants_tsv, col_sep: "\t") do |row|
	subject = row[0]
	session = row[1]
	gender = row[2]
	birth_ga = row[3]

  # header line
  next if subject == "participant_id"

  # duplicate
  next if all_scans.has_key? subject

  all_scans[subject] = {
      subject: subject,
      gender: gender,
      birth_ga: birth_ga
  }

  Scan.create!(subject: subject, session: session)

end
