# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamPolicyPassRoleWildcardResourceRule < BaseRule
  def rule_text
    'IAM policy should not allow * resource with PassRole action'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F39'
  end

  def passrole_action?(statement)
    statement.actions.find { |action| action == 'iam:PassRole' }
  end

  def wildcard_resource?(statement)
    statement.resources.find { |resource| resource == '*' }
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::Policy').select do |policy|
      violating_statements = policy.policy_document.statements.select do |statement|
        passrole_action?(statement) && wildcard_resource?(statement)
      end
      !violating_statements.empty?
    end
    violating_policies.map(&:logical_resource_id)
  end
end
