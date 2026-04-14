class SetupIssueTracker < ActiveRecord::Migration[8.1]
  def change
    # 1. USUARIS (Només Google OAuth)
    create_table :users do |t|
      t.string :name 
      t.string :email, index: { unique: true } 
      t.string :uid 
      t.string :avatar_url 
      t.timestamps
    end

    # 2. CONFIGURACIONS (Statuses, Priorities, Types, Severities, Tags)
    [:statuses, :priorities, :types, :severities, :tags].each do |table_name|
      create_table table_name do |t|
        t.string :name
        t.string :color 
        t.timestamps
      end
    end

    # 3. ISSUES
    create_table :issues do |t|
      t.string :subject 
      t.text :description
      t.datetime :deadline 
      t.references :creator, null: false, foreign_key: { to_table: :users } 
      t.references :status, foreign_key: true 
      t.references :priority, foreign_key: true 
      t.references :type, foreign_key: true
      t.references :severity, foreign_key: true 
      t.timestamps
    end

    # 4. TAULES INTERMÈDIES I INTERACCIÓ
    create_table :assignments do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true 
    end

    create_table :watchers do |t|
      t.references :issue, null: false, foreign_key: true 
      t.references :user, null: false, foreign_key: true 
    end

    create_table :issue_tags do |t|
      t.references :issue, null: false, foreign_key: true 
      t.references :tag, null: false, foreign_key: true
    end

    create_table :comments do |t|
      t.text :body 
      t.references :issue, null: false, foreign_key: true 
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    create_table :activities do |t|
      t.string :action 
      t.references :issue, null: false, foreign_key: true 
      t.references :user, null: false, foreign_key: true 
      t.datetime :created_at 
    end

    create_table :attachments do |t|
      t.string :file_path 
      t.references :issue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true 
      t.timestamps
    end
  end
end
