class ApplnInfo < ActiveRecord::Base

  belongs_to :veteran, class_name: "User" , foreign_key: "vob_id"
  belongs_to :certification_admin, class_name: "User"  , foreign_key: "ca_id" 
  belongs_to :account_admin, class_name: "User"  , foreign_key: "aa_id"  
  belongs_to :contractor, class_name: "User" , foreign_key: "contractor_id" 
  
  
  has_attached_file :certificate_doc, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :certificate_doc,  :content_type => FILE_EXETN    
  validates_attachment_size :certificate_doc, :in => 0.megabytes..25.megabytes 
  
  has_attached_file :certificate_denied_doc, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :certificate_denied_doc,  :content_type => FILE_EXETN
  validates_attachment_size :certificate_denied_doc, :in => 0.megabytes..25.megabytes  

  has_one :company_info, dependent: :destroy
  has_one :identity_info, dependent: :destroy
  has_one :business_profile_info, dependent: :destroy
  has_one :business_structure, dependent: :destroy
  has_one :business_relationship_info, dependent: :destroy
  has_one :staff_and_responsibility, dependent: :destroy
  has_one :bank_detail, dependent: :destroy
  has_one :legal_and_financial_document, dependent: :destroy
  has_one :declaration, dependent: :destroy
  has_one :site_visit, dependent: :destroy
  has_one :alternate_certification, dependent: :destroy
  has_many :histories, dependent: :destroy 
  has_many :user_code_lists 
  has_many :site_visit_schedule_histories 
  
  has_many :notifications  
  
  scope :ca_company_info, -> (dat) {pending_review.where("date(appln_submitted_date) <= ?", (dat) )}  
  scope :ca_all_application_steps, -> (dat) {accept_approved_denied.where("date(appln_submitted_date) <= ?", (dat) )}
  scope :ca_schedule_site_visit, -> (dat) {under_site_visit.where("date(site_visit_shedule_date) <= ?", (dat) )} 
  scope :ca_site_visit_scheduled_thirty_days, -> (dat) {submitted.where("date(site_visit_shedule_date) >= date(appln_submitted_date) + #{30.days}")} 
  scope :ca_site_visit_rescheduled, -> (dat) {under_site_visit.where("date(site_visit_shedule_date) <= ?", (dat) )} 
  scope :ca_site_visit_report, -> (dat) {under_site_visit.where("date(site_visit_shedule_date) <= ?", (dat) )} 
  scope :not_started, -> {where(appln_status: 'Not Started')}
  scope :in_progress, -> {where(appln_status: 'In Progress')}
  scope :submitted, -> {where(appln_status: 'Submitted')}
  scope :pending_review, -> {where(appln_status: 'AA Pending Review')}
  scope :review_in_progress, -> {where(appln_status: 'AA Review In Progress')}
  scope :review_done, -> {where(appln_status: 'Review Done')}
  scope :under_site_visit, -> {where(appln_status: 'Under Site Visit')}
  scope :site_visit_done, -> {where(appln_status: 'Site Visit Done')}
  scope :pending_approval, -> {where(appln_status: 'Pending Approval')}
  scope :marked_for_approval, -> {where(appln_status: 'Ready for Approval')}
  scope :marked_for_denial, -> {where(appln_status: 'Ready for Denial')}
  scope :approved, -> {where(appln_status: ['Approved','Denied'])}
  scope :approved_appln, -> {where(appln_status: 'Approved')}
  scope :denied, -> {where(appln_status: ['Denied', 'Denied Certificate Sent'])}   
  scope :certified, -> {where(appln_status: ['Approved', 'Certified Certificate Sent'])}
  scope :certified_except, -> (v_id) {where("vob_id != ?",v_id).where(appln_status: ['Approved', 'Certified Certificate Sent'])}     
  scope :certified_sent, -> {where(appln_status: ['Certified Certificate Sent'])}   
  scope :certified_sent_except, -> (v_id) {where("vob_id != ?",v_id).where(appln_status: ['Certified Certificate Sent'])}   
  scope :company_info_missing, -> { joins(:company_info).where(:company_infos => { :company_name => nil }) }
  scope :accept_approved_denied, -> {where(appln_status: ['Submitted','Due Date Assigned','AA Pending Review','AA Review In Progress','AA Review Done','Under Site Visit','Site Visit Done','Pending Approval', 'Ready for Approval', 'Ready for Denial'])}
  scope :active, -> {where(appln_status: ['Submitted','Due Date Assigned','AA Pending Review','AA Review In Progress','AA Review Done','Under Site Visit','Site Visit Done','Pending Approval', 'Ready for Approval', 'Ready for Denial'])} 
  scope :archived, -> {where(archived: true)} 
  scope :by_veteran_id, -> (v_id) { where("vob_id = ?",v_id) }    
  scope :by_status_id, -> (s_id) { where("appln_status = ?",s_id) }   
  scope :by_submitted_date, -> (f_d,t_d) { where(appln_submitted_date: f_d.beginning_of_day..t_d.end_of_day) }  
  scope :ca_list, -> (u_id) { where(:ca_id => u_id) }
  scope :aa_list, -> (u_id) { where('aa_id=?',u_id) }
  scope :contractor_list, -> (u_id) { where('contractor_id=?',u_id) }  
  
  def is_active?  
     arr = ['Submitted','Due Date Assigned','AA Pending Review','AA Review In Progress','AA Review Done','Under Site Visit','Site Visit Done','Pending Approval', 'Ready for Approval', 'Ready for Denial']
     arr.include?(self.appln_status) 
  end  
  
  def review_link_active?  
     arr = ['Approved','Denied','Certified Certificate Sent','Denied Certificate Sent']
     arr.include?(self.appln_status) 
  end
  
  
  attr_accessor :dummy#, :certificate_doc_link_url 
  acts_as_commentable 


def self.veteran_dashboard_info(user)
  user.appln_info  
end

def self.application_pending_status_count(appln_type, appln_general_status, check_date, today_date, user_id)
 	
 	unless appln_type.nil?
 		if user_id.nil?
 			ApplnInfo.where('appln_type=? and appln_status=? and appln_start_date>=? and appln_start_date<=?', appln_type, appln_general_status,check_date, today_date).count
 		else
 			ApplnInfo.where('appln_type=? and appln_status=? and appln_start_date>=? and appln_start_date<=? and aa_id=?', appln_type, appln_general_status, check_date, today_date, user_id).count
 		end
 	else
 		if user_id.nil?
 		  ApplnInfo.where('appln_status=?  and appln_start_date>=? and appln_start_date<=?', appln_general_status, check_date, today_date).count
    else
    	ApplnInfo.where('appln_status=? and appln_start_date>=? and appln_start_date<=? and aa_id=?', appln_general_status, check_date, today_date, user_id).count
   	end
 	end
end

def self.application_sitevisit_status_count(appln_type, appln_general_status, check_date, today_date, user_id)  

  unless appln_type.nil?
    if user_id.nil?
      #ApplnInfo.where('appln_type=? and (appln_status=? ) and site_visit_ca_done>=? and site_visit_ca_done<=?', appln_type, appln_general_status, check_date, today_date).count

    undersit_visit_count = ApplnInfo.where('appln_type=? and appln_status=? and contractor_assigned_date>=? and contractor_assigned_date<=? ', appln_type, 'Under Site Visit', check_date, today_date).count
    aa_review_count =  ApplnInfo.where('appln_type=? and appln_status=?  and aa_review_actual_date>=? and aa_review_actual_date<=? ', appln_type, appln_general_status, check_date, today_date).count
    return undersit_visit_count + aa_review_count
    else
    undersit_visit_count = ApplnInfo.where('appln_type=? and appln_status=? and contractor_assigned_date>=? and contractor_assigned_date<=? and aa_id=?', appln_type, 'Under Site Visit', check_date, today_date, user_id).count
    aa_review_count =  ApplnInfo.where('appln_type=? and appln_status=? and aa_review_actual_date>=? and aa_review_actual_date<=? and aa_id=?', appln_type, appln_general_status, check_date, today_date, user_id).count
    return undersit_visit_count + aa_review_count
    end
  else
    if user_id.nil?
    undersit_visit_count = ApplnInfo.where('appln_status=? and contractor_assigned_date>=? and contractor_assigned_date<=?', 'Under Site Visit', check_date, today_date).count
    aa_review_count =  ApplnInfo.where('appln_status=? and aa_review_actual_date>=? and aa_review_actual_date<=?', appln_general_status, check_date, today_date).count
    return undersit_visit_count + aa_review_count
    else
    undersit_visit_count = ApplnInfo.where('appln_type=? and appln_status=? and contractor_assigned_date>=? and contractor_assigned_date<=? and aa_id=?', appln_type, 'Under Site Visit', check_date, today_date, user_id).count
    aa_review_count =  ApplnInfo.where('appln_type=? and appln_status=? and aa_review_actual_date>=? and aa_review_actual_date<=? and aa_id=?', appln_type, appln_general_status, check_date, today_date, user_id).count
    return undersit_visit_count + aa_review_count
    end
  end
 end

def self.application_approve_status_count(appln_type, appln_general_status, check_date, today_date, user_id)
 	
 	unless appln_type.nil?
 		if user_id.nil?
      ApplnInfo.where('appln_type=? and (appln_status=? or appln_status=?)  and certified_date>=? and certified_date<=?', appln_type, appln_general_status, "Certified Certificate Sent", check_date, today_date).count
 		else
 	    ApplnInfo.where('appln_type=? and (appln_status=? or appln_status=?)   and certified_date>=? and certified_date<=?  and aa_id=?', appln_type, appln_general_status, "Certified Certificate Sent", check_date, today_date, user_id).count
    end
  else
   	if user_id.nil?
      ApplnInfo.where('(appln_status=? or appln_status=?)  and certified_date>=? and certified_date<=?', appln_general_status, "Certified Certificate Sent", check_date, today_date).count
		else
	    ApplnInfo.where('(appln_status=? or appln_status=?)  and certified_date>=? and certified_date<=? and aa_id=?', appln_general_status, "Certified Certificate Sent", check_date, today_date, user_id).count
		end
	end
end

def self.application_denied_status_count(appln_type, appln_general_status, check_date, today_date, user_id)
  
  unless appln_type.nil?
    if user_id.nil?
     ApplnInfo.where('appln_type=? and (appln_status=? or appln_status=?) and certified_date>=? and certified_date<=?', appln_type, appln_general_status, "Denied Certificate Sent", check_date, today_date).count
    else
     ApplnInfo.where('appln_type=? and (appln_status=? or appln_status=?) and certified_date>=? and certified_date<=?  and aa_id=?', appln_type, appln_general_status, "Denied Certificate Sent", check_date, today_date, user_id).count
    end
  else
    if user_id.nil?
     ApplnInfo.where(' (appln_status=? or appln_status=?) and certified_date>=? and certified_date<=?', appln_general_status, "Denied Certificate Sent",  check_date, today_date).count
    else
     ApplnInfo.where(' (appln_status=? or appln_status=?) and certified_date>=? and certified_date<=? and aa_id=?', appln_general_status, "Denied Certificate Sent",  check_date, today_date, user_id).count
    end
  end
end


  def not_started  
    self.update_attribute("appln_status", "Not Started") 
  end 
  def in_progress 
     self.update_attribute("appln_status", "In Progress") 
  end 
  def submitted  
     self.update_attributes(appln_status: "Submitted", ca_id: User.certificate_admins.first.id, appln_submitted_date: Time.now.to_datetime) 
     Notification.ca_application_submitted(self) 
  end  
  def due_date_assign  
      self.update_attributes(appln_status: "Due Date Assigned") 
  end
  def pending_review 
     self.update_attributes( appln_status: "AA Pending Review", aa_assigned_date: Time.now.to_datetime) 
     Notification.aa_application_assigned(self) if UserNotificationLevel.aa_notification_level?(self.aa_id, AA_NOTIFICATION_LEVEL_1)
  end 

  def review_in_progress 
     self.update_attribute("appln_status", "AA Review In Progress")   
  end

  def review_done
     self.update_attributes(appln_status: "AA Review Done", aa_review_actual_date: Time.now.to_datetime) 
     Notification.ca_aa_review_completed(self) if UserNotificationLevel.ca_notification_level?(CA_NOTIFICATION_LEVEL_2)
  end

  def under_site_visit  
    self.update_attributes( contractor_assigned_date: Time.now, appln_status: UNDER_SITE_VISIT)
    Notification.co_application_assigned(self) if UserNotificationLevel.co_notification_level?(self.contractor_id, CO_NOTIFICATION_LEVEL_1)
  end  
  
  def contractor_assigned_date_assign 
    self.update_attributes(site_visit_shedule_count: schedule_count, contractor_assigned_date: Time.now.to_datetime ) 
    Notification.ca_schedule_site_visit(self)  
  end

  def schedule_site_visit(params=nil) 
    schedule_count = self.site_visit_shedule_count
    if schedule_count  
      schedule_count = schedule_count + 1
    else 
      schedule_count = 1
    end
    self.update_attribute("site_visit_shedule_count", schedule_count) 
    self.update_attribute("site_visit_shedule_date", Time.strptime(params[:site_visit_shedule_date],"%m/%d/%Y").to_date ) if !params[:site_visit_shedule_date].blank?
    Notification.ca_schedule_site_visit(self)  
  end 

  def reschedule_site_visit(params=nil, schedule_count)
    self.update_attribute("site_visit_shedule_date", Time.strptime(params[:site_visit_shedule_date],"%m/%d/%Y").to_date ) if !params[:site_visit_shedule_date].blank?
    self.update_attribute("site_visit_shedule_count", schedule_count ) 
    Notification.ca_reschedule_site_visit(self)  
  end 
  
  def site_visit_done 
     self.update_attribute("appln_status", "Site Visit Done")  
     self.update_attribute("site_visit_actual_date", Time.now.to_datetime)  
  end 
  def pending_approval 
     self.update_attributes("appln_status", "Pending Approval")    
  end  
  
  def approved   
     renewal_date = self.certification_date + 1.year
     self.update_attributes(appln_status: "Approved", certificate_assign_date: Time.now.to_datetime, certified_date: Time.now.to_datetime, appln_renewal_date: renewal_date ) 
     Notification.vob_approved(self) if UserNotificationLevel.vob_notification_level?(self.vob_id, VOB_NOTIFICATION_LEVEL_1)
  end 
  def denied 
     self.update_attributes(appln_status: "Denied", certificate_denied_date: Time.now.to_datetime, certified_date: Time.now.to_datetime )
     Notification.vob_denied(self) if UserNotificationLevel.vob_notification_level?(self.vob_id, VOB_NOTIFICATION_LEVEL_1)   
  end  
  
  def marked_for_approval 
     self.update_attribute("appln_status", "Ready for Approval") 
  end 
  def marked_for_denial 
     self.update_attribute("appln_status", "Ready for Denial")   
  end 

  def certificate_sent 
     self.update_attribute("appln_status", "Certified Certificate Sent")  
     ApplicationNotification.certificate(self).deliver   
  end 
  
  def certificate_denied_sent
      self.update_attribute("appln_status", "Denied Certificate Sent")  
      ApplicationNotification.certificate(self).deliver   
  end 
  
  
  def not_started?
    self.appln_status ==  "Not Started"
  end 
  def in_progress?
    self.appln_status ==  "In Progress"
  end
  def submitted?
    self.appln_status ==  "Submitted"
  end  
  def due_date_assign? 
    self.appln_status ==  "Due Date Assigned" 
  end
  def pending_review?
    self.appln_status ==  "AA Pending Review"
  end
  def review_in_progress?
    self.appln_status ==  "AA Review In Progress"
  end 
  def review_done?
    self.appln_status ==  "AA Review Done"
  end 
  def under_site_visit?
    self.appln_status ==  "Under Site Visit"
  end 
  def site_visit_done?
    self.appln_status ==  "Site Visit Done"
  end 
  def pending_approval?
    self.appln_status ==  "Pending Approval"
  end 
  def approved?
    self.appln_status ==  "Approved"
  end 
  def denied?
    self.appln_status ==  "Denied"
  end   
  def marked_for_approval?
    self.appln_status == "Ready for Approval"
  end 
  def marked_for_denial?
    self.appln_status == "Ready for Denial"
  end 
  def certificate_sent?
     self.appln_status ==  "Certified Certificate Sent"  
  end 
  
  def certificate_denied_sent?
      self.appln_status == "Denied Certificate Sent"
  end 

  def check_veteran_status_done 
    if self.appln_type == "fastrack" 
     return self.company_info_vob_done == true && self.identity_vob_done == true && self.business_profile_vob_done == true && self.declaration_vob_done == true && self.alternate_certification_vob_done == true 
    else
     return self.company_info_vob_done == true && self.identity_vob_done == true && self.business_profile_vob_done == true && self.business_structure_vob_done == true && self.business_relationship_vob_done == true && self.bank_detail_vob_done == true && self.legal_financial_vob_done == true && self.declaration_vob_done == true 
    end
  end 
  
  def check_veteran_status_review 
    if self.appln_type == "fastrack" 
     return self.company_info_vob_review == true && self.veteran_identity_vob_review == true && self.business_profile_vob_review == true && self.declaration_vob_review == true && self.alternate_certification_vob_review == true 
    else 
     return self.company_info_vob_review == true && self.veteran_identity_vob_review == true && self.business_profile_vob_review == true && self.business_structure_vob_review == true && self.business_relationship_vob_review == true && self.staff_responsibility_vob_review == true && self.bank_detail_vob_review == true && self.legal_financial_vob_review == true && self.declaration_vob_review == true     
    end
  end 
  
  def check_ca_status_review 
    if self.appln_type == "fastrack" 
     return self.company_info_ca_review == true && self.veteran_identity_ca_review == true && self.business_profile_ca_review == true && self.declaration_ca_review == true && self.alternate_certification_ca_review == true 
    else 
     return self.company_info_ca_review == true && self.veteran_identity_ca_review == true && self.business_profile_ca_review == true && self.business_structure_ca_review == true && self.business_relationship_ca_review == true && self.staff_responsibility_ca_review == true && self.bank_detail_ca_review == true && self.legal_financial_ca_review == true && self.declaration_ca_review == true && self.site_visit_ca_review == true    
    end
  end  
  
  def check_aa_status_review 
    if self.appln_type == "fastrack" 
     return self.company_info_aa_review == true && self.veteran_identity_aa_review == true && self.business_profile_aa_review == true && self.declaration_aa_review == true && self.alternate_certification_aa_review == true 
    else 
     return self.company_info_aa_review == true && self.veteran_identity_aa_review == true && self.business_profile_aa_review == true && self.business_structure_aa_review == true && self.business_relationship_aa_review == true && self.staff_responsibility_aa_review == true && self.bank_detail_aa_review == true && self.legal_financial_aa_review == true && self.declaration_aa_review == true     
    end
  end
  
  def company_info_vob_review_done  
    self.company_info_vob_review = true
    self.save
  end
  def company_info_ca_review_done
     self.company_info_ca_review = true
     self.save 
  end
  def company_info_aa_review_done 
     self.company_info_aa_review = true
      self.save 
  end
  def veteran_identity_vob_review_done 
     self.veteran_identity_vob_review = true
      self.save
  end
  def veteran_identity_ca_review_done
     self.veteran_identity_ca_review = true
      self.save 
  end
  def veteran_identity_aa_review_done
     self.veteran_identity_aa_review = true
      self.save
  end
  def business_profile_vob_review_done
     self.business_profile_vob_review = true
      self.save
  end 
  def business_profile_ca_review_done
     self.business_profile_ca_review = true
      self.save  
  end
  def business_profile_aa_review_done
     self.business_profile_aa_review = true
      self.save
  end
  def business_structure_vob_review_done
     self.business_structure_vob_review = true
      self.save
  end
  def business_structure_ca_review_done
     self.business_structure_ca_review = true
      self.save
  end
  def business_structure_aa_review_done
     self.business_structure_aa_review = true
      self.save
  end
  def business_relationship_vob_review_done 
     self.business_relationship_vob_review = true
      self.save
  end
  def business_relationship_ca_review_done
     self.business_relationship_ca_review = true
      self.save 
  end
  def business_relationship_aa_review_done
     self.business_relationship_aa_review = true
      self.save
  end
  def staff_responsibility_vob_review_done
     self.staff_responsibility_vob_review = true
     self.save 
  end
  def staff_responsibility_ca_review_done 
     self.staff_responsibility_ca_review = true
     self.save
  end
  def staff_responsibility_aa_review_done  
     self.staff_responsibility_aa_review = true
     self.save
  end
  def bank_detail_vob_review_done
     self.bank_detail_vob_review = true
     self.save
  end
  def bank_detail_ca_review_done
     self.bank_detail_ca_review = true
     self.save
  end
  def bank_detail_aa_review_done 
     self.bank_detail_aa_review = true
     self.save
  end
  def legal_financial_vob_review_done 
     self.legal_financial_vob_review = true
     self.save
  end
  def legal_financial_ca_review_done 
     self.legal_financial_ca_review = true
     self.save
  end
  def legal_financial_aa_review_done 
     self.legal_financial_aa_review = true
     self.save
  end
  def declaration_vob_review_done 
     self.declaration_vob_review = true
     self.save
  end 
  def declaration_ca_review_done 
     self.declaration_ca_review = true
     self.save
  end
  def declaration_aa_review_done 
     self.declaration_aa_review = true
     self.save
  end 
  
  def site_visit_aa_review_done 
     self.site_visit_aa_review = true
     self.save
  end
  def site_visit_ca_review_done 
     self.site_visit_ca_review = true
     self.save  
  end
  
  def alternate_certification_vob_review_done 
     self.alternate_certification_vob_review = true
     self.save
  end
  def alternate_certification_ca_review_done
     self.alternate_certification_ca_review = true
     self.save
  end
  def alternate_certification_aa_review_done
     self.alternate_certification_aa_review = true
     self.save
  end
  
 def self.users_application(user_id)
   ApplnInfo.where('contractor_id=?', user_id)
 end 
 
 def fast_track?  
   self.appln_type == "fastrack"
 end  
 def full_track?  
   self.appln_type == "full"
 end 
 
 def app_review_update(user, model_type)   
   
    if user.certificate_admin? 
      if model_type == "CompanyInfo"  
        self.company_info_ca_review = false  
      elsif model_type == "IdentityInfo"  
        self.veteran_identity_ca_review = false 
      elsif model_type == "BusinessProfileInfo"
        self.business_profile_ca_review = false    
      elsif model_type == "BankDetail"
          self.bank_detail_ca_review  = false 
      elsif model_type == "AlternateCertification"  
         self.alternate_certification_ca_review = false
      elsif model_type == "BusinessRelationshipInfo"
         self.business_relationship_ca_review = false 
      elsif model_type == "BusinessStructure" 
         self.business_structure_ca_review = false
      elsif model_type == "Declaration"   
         self.declaration_ca_review = false  
      elsif model_type == "LegalAndFinancialDocument"  
        self.legal_financial_ca_review = false 
      elsif model_type == "StaffAndResponsibility" 
          self.staff_responsibility_ca_review = false 
      elsif model_type == "SiteVisit" 
          self.site_visit_ca_review = false    
      end 
      self.save
      
    end
    if user.account_admin? 
       if model_type == "CompanyInfo"  
          self.company_info_aa_review = false  
        elsif model_type == "IdentityInfo"  
          self.veteran_identity_aa_review = false 
        elsif model_type == "BusinessProfileInfo"
          self.business_profile_aa_review = false    
        elsif model_type == "BankDetail"
            self.bank_detail_aa_review  = false 
        elsif model_type == "AlternateCertification"  
           self.alternate_certification_aa_review = false
        elsif model_type == "BusinessRelationshipInfo"  
           self.business_relationship_aa_review = false 
        elsif model_type == "BusinessStructure" 
           self.business_structure_aa_review = false
        elsif model_type == "Declaration"   
           self.declaration_ca_review = false  
        elsif model_type == "LegalAndFinancialDocument"  
          self.legal_financial_aa_review = false 
        elsif model_type == "StaffAndResponsibility" 
            self.staff_responsibility_aa_review = false 
        elsif model_type == "SiteVisit" 
            self.site_visit_aa_review = false    
        end  
        self.save 
    end  
    
  end

end
