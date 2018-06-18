json.extract! vote, :id, :vote, :user_id, :scan_id, :created_at, :updated_at
json.url vote_url(vote, format: :json)
