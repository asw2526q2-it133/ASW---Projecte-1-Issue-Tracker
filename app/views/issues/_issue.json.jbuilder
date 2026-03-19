json.extract! issue, :id, :subject, :description, :issue_type, :severity, :priority, :status, :user_id, :created_at, :updated_at
json.url issue_url(issue, format: :json)
