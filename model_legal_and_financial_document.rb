class LegalAndFinancialDocument < ActiveRecord::Base 
  belongs_to :appln_info  
  acts_as_commentable
  attr_accessor :dummy
    
  has_attached_file :articals_of_organization, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :articals_of_organization, :content_type => FILE_EXETN 
  validates_attachment_size :articals_of_organization, :in => 0.megabytes..25.megabytes  
  has_attached_file :minutes_of_meeting, :default_url => "/images/:style/missing.png"  
  validates_attachment_content_type :minutes_of_meeting, :content_type => FILE_EXETN  
  validates_attachment_size :minutes_of_meeting, :in => 0.megabytes..25.megabytes  
  has_attached_file :stock_ledger_and_stock_transfer, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :stock_ledger_and_stock_transfer, :content_type => FILE_EXETN  
  validates_attachment_size :stock_ledger_and_stock_transfer, :in => 0.megabytes..25.megabytes
  has_attached_file :management_agreement, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :management_agreement, :content_type => FILE_EXETN  
  validates_attachment_size :management_agreement, :in => 0.megabytes..25.megabytes 
  has_attached_file :name_doucment, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :name_doucment, :content_type => FILE_EXETN  
  validates_attachment_size :name_doucment, :in => 0.megabytes..25.megabytes 
  has_attached_file :fein_irs, :default_url => "/images/:style/missing.png" 
  validates_attachment_content_type :fein_irs, :content_type => FILE_EXETN  
  validates_attachment_size :fein_irs, :in => 0.megabytes..25.megabytes  
  has_attached_file :financial_statement, :default_url => "/images/:style/missing.png" 
  validates_attachment_content_type :financial_statement, :content_type => FILE_EXETN  
  validates_attachment_size :financial_statement, :in => 0.megabytes..25.megabytes    
  has_attached_file :irs_tax_return, :default_url => "/images/:style/missing.png" 
  validates_attachment_content_type :irs_tax_return, :content_type => FILE_EXETN 
  validates_attachment_size :irs_tax_return, :in => 0.megabytes..25.megabytes  
  has_attached_file :debt_instruments, :default_url => "/images/:style/missing.png" 
  validates_attachment_content_type :debt_instruments, :content_type => FILE_EXETN 
  validates_attachment_size :debt_instruments, :in => 0.megabytes..25.megabytes 
  has_attached_file :shareholders_guarantees_any_debt, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :shareholders_guarantees_any_debt, :content_type => FILE_EXETN 
  validates_attachment_size :shareholders_guarantees_any_debt, :in => 0.megabytes..25.megabytes    
  has_attached_file :assets_purchage_agreement, :default_url => "/images/:style/missing.png" 
  validates_attachment_content_type :assets_purchage_agreement, :content_type => FILE_EXETN  
  validates_attachment_size :assets_purchage_agreement, :in => 0.megabytes..25.megabytes  
  has_attached_file :lease_agreements, :default_url => "/images/:style/missing.png" 
  validates_attachment_content_type :lease_agreements, :content_type => FILE_EXETN   
  validates_attachment_size :lease_agreements, :in => 0.megabytes..25.megabytes   
  has_attached_file :copy_of_bond_certificate, :default_url => "/images/:style/missing.png" 
  validates_attachment_content_type :copy_of_bond_certificate, :content_type => FILE_EXETN
  validates_attachment_size :copy_of_bond_certificate, :in => 0.megabytes..25.megabytes  
  has_attached_file :copy_of_payroll_ledger, :default_url => "/images/:style/missing.png"  
  validates_attachment_content_type :copy_of_payroll_ledger, :content_type => FILE_EXETN  
  validates_attachment_size :copy_of_payroll_ledger, :in => 0.megabytes..25.megabytes 
  has_attached_file :vehicle_title, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :vehicle_title, :content_type => FILE_EXETN  
  validates_attachment_size :vehicle_title, :in => 0.megabytes..25.megabytes  
  
  after_save do
    if (self.articals_of_organization.present? || self.articals_of_organization_link_url.present?) && (self.fein_irs.present? || self.fein_irs_link_url.present?) && (self.financial_statement.present? || self.financial_statement_link_url.present?) && (self.copy_of_payroll_ledger.present? || self.copy_of_payroll_ledger_link_url.present? )  && (self.irs_tax_return.present? || self.irs_tax_return_link_url.present?) && (self.minutes_of_meeting.present? || self.minutes_of_meeting_link_url.present?)
      self.appln_info.update_attribute("legal_financial_vob_done", true) 
    else  
      self.appln_info.update_attribute("legal_financial_vob_done", false)  
    end
    if self.articals_of_organization.present? || self.minutes_of_meeting.present? || self.stock_ledger_and_stock_transfer.present? || self.stock_ledger_and_stock_transfer.present? || self.management_agreement.present? || self.name_doucment.present? || self.fein_irs.present? || self.financial_statement.present? || self.irs_tax_return.present? || self.debt_instruments.present? || self.shareholders_guarantees_any_debt.present? || self.assets_purchage_agreement.present? || self.lease_agreements.present? || self.copy_of_bond_certificate.present? || self.copy_of_payroll_ledger
      self.appln_info.update_attribute("legal_financial_vob_start", true) 
    end
  end
  
  
  def uploded_files
    str = []
    str << self.articals_of_organization.original_filename if self.articals_of_organization.present?                                                 
    str << self.minutes_of_meeting.original_filename if self.minutes_of_meeting.present?
    str << self.stock_ledger_and_stock_transfer.original_filename if self.stock_ledger_and_stock_transfer.present?
    str << self.management_agreement.original_filename if self.management_agreement.present?
    str << self.name_doucment.original_filename if self.name_doucment.present?
    str << self.fein_irs.original_filename if self.fein_irs.present?
    str << self.financial_statement.original_filename if self.financial_statement.present?
    str << self.irs_tax_return.original_filename if self.irs_tax_return.present?
    str << self.debt_instruments.original_filename if self.debt_instruments.present?
    str << self.shareholders_guarantees_any_debt.original_filename if self.shareholders_guarantees_any_debt.present?
    str << self.assets_purchage_agreement.original_filename if self.assets_purchage_agreement.present?
    str << self.lease_agreements.original_filename if self.lease_agreements.present?
    str << self.copy_of_bond_certificate.original_filename if self.copy_of_bond_certificate.present?
    str << self.copy_of_payroll_ledger.original_filename if self.copy_of_payroll_ledger.present?
    str = str.join(", ")
    str    
  end
end
