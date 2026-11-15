# Doer Seeds matching the mind map:
# Projects -> Project A -> Todo List AA, Todo List AB
# Standalone Lists -> Todo List A, Todo List B

puts "Seeding Doer..."

TodoList.destroy_all
Project.destroy_all

project_a = Project.create!(
  name: "Project A",
  description: "Core developer workflows and architecture checklists"
)

# Todo lists assigned to Project A
TodoList.create!(
  project: project_a,
  title: "Sprint Tasks",
  body: <<~MARKDOWN
    # Sprint 4 Action Items

    Track key engineering tasks for this sprint cycle.

    ## Checklist:
    - [ ] Database query efficiency (N+1 queries avoided)
    - [ ] Proper error handling and edge cases
    - [ ] Idempotent background jobs
    - [x] Strict input validation

    ### Sample Ruby Pattern:
    ```ruby
    def execute_safely
      ActiveRecord::Base.transaction do
        yield
      end
    rescue StandardError => e
      Rails.logger.error("Transaction failed: \#{e.message}")
      raise
    end
    ```

    > Verify all tasks pass CI before merging.
  MARKDOWN
)

TodoList.create!(
  project: project_a,
  title: "API Documentation Checklist",
  body: <<~MARKDOWN
    # OpenAPI Release Checklist

    Checklist for releasing the new REST API endpoints.

    - [x] Define OpenAPI 3.1 schema
    - [ ] Add unit and integration tests
    - [ ] Generate client SDK
    - [ ] Verify error responses (400, 404, 422, 500)
  MARKDOWN
)

# Standalone Todo Lists (no project assigned)
TodoList.create!(
  project: nil,
  title: "Daily Standalone Checklist",
  body: <<~MARKDOWN
    # Daily Standup & Tasks

    - [x] Review pull requests
    - [ ] Triage new GitHub issues
    - [ ] Update staging environment
    - [ ] Send daily wrap-up email
  MARKDOWN
)

TodoList.create!(
  project: nil,
  title: "Weekend Project Goals",
  body: <<~MARKDOWN
    # Personal Goals

    - [ ] Build demo application with Doer
    - [ ] Read Ruby 3.4 release notes
    - [ ] Test Turbo 8 page refreshes
  MARKDOWN
)

puts "Seeded #{Project.count} projects and #{TodoList.count} todo lists successfully!"
