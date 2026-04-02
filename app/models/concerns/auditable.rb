module Auditable
  extend ActiveSupport::Concern

  included do
    before_create :audit_created_by
    before_save   :audit_updated_by
  end

  private

  def audit_created_by
    user_identifier = Current.user&.cpf || Current.user&.email
    self.created_by = user_identifier if respond_to?(:created_by=) && created_by.blank?
    self.updated_by = user_identifier if respond_to?(:updated_by=) && updated_by.blank?
  end

  def audit_updated_by
    user_identifier = Current.user&.cpf || Current.user&.email
    self.updated_by = user_identifier if respond_to?(:updated_by=)
  end
end
