require 'redmine'

Redmine::Plugin.register :redmine_fields_permissions do
  name 'Redmine Fields Permissions Plugin'
  author 'Romain E SILVA (Sysdream)'
  description 'This Redmine plugin add additional permissions for fields in workflow. This plugin is based on http://9thport.net/2011/03/20/redmine-hide-assigned-to-field-with-role-permissions-plugin/ by Aaron Addleman'
  version '1.0.0'
  url 'http://www.sysdream.com/'
  author_url 'http://www.sysdream.com/'

  project_module :issue_tracking do
    permission :edit_assigned_to, {}, :require => :member
    permission :edit_start_date, {}, :require => :member
    permission :edit_due_date, {}, :require => :member
    permission :edit_estimated_hours, {}, :require => :member 
    permission :edit_priority, {}, :require => :member 
    permission :edit_fixed_version, {}, :require => :member 
    permission :edit_category, {}, :require => :member 
  end

  ActionDispatch::Callbacks.to_prepare do
    FIELDS = %w( assigned_to_id start_date due_date estimated_hours done_ratio priority_id fixed_version_id category_id )
    Issue.safe_attributes.each {|attrs, options| attrs.delete_if(&FIELDS.method(:include?)) }

    Issue.safe_attributes 'assigned_to_id',
      :if => lambda {|issue, user| user.allowed_to?(:edit_assigned_to, issue.project) && (user.allowed_to?(:edit_issues, issue.project) || issue.new_record?) }

    Issue.safe_attributes 'start_date',
      :if => lambda {|issue, user| user.allowed_to?(:edit_start_date, issue.project) && (user.allowed_to?(:edit_issues, issue.project) || issue.new_record?) }

    Issue.safe_attributes 'due_date',
      :if => lambda {|issue, user| user.allowed_to?(:edit_due_date, issue.project) && (user.allowed_to?(:edit_issues, issue.project) || issue.new_record?) }

    Issue.safe_attributes 'estimated_hours',
      'done_ratio',
      :if => lambda {|issue, user| user.allowed_to?(:edit_estimated_hours, issue.project) && (user.allowed_to?(:edit_issues, issue.project) || issue.new_record?) }

    Issue.safe_attributes 'priority_id',
      :if => lambda {|issue, user| user.allowed_to?(:edit_priority, issue.project) && (user.allowed_to?(:edit_issues, issue.project) || issue.new_record?) }

    Issue.safe_attributes 'fixed_version_id',
      :if => lambda {|issue, user| user.allowed_to?(:edit_fixed_version, issue.project) && (user.allowed_to?(:edit_issues, issue.project) || issue.new_record?) }

    Issue.safe_attributes 'category_id',
      :if => lambda {|issue, user| user.allowed_to?(:edit_category, issue.project) && (user.allowed_to?(:edit_issues, issue.project) || issue.new_record?) }

    Issue.safe_attributes 'assigned_to_id',
      :if => lambda {|issue, user| issue.new_statuses_allowed_to(user).any? && user.allowed_to?(:edit_assigned_to, issue.project) }

    Issue.safe_attributes 'fixed_version_id',
      :if => lambda {|issue, user| issue.new_statuses_allowed_to(user).any? && user.allowed_to?(:edit_fixed_version, issue.project) }
  end
end