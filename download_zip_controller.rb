require 'fileutils'
class DownloadZipController < ApplicationController
  before_filter :authenticate_user! 
  def index
  end  
  def application_html 
    #@appln_info = ApplnInfo.find(params[:id])    
    #render :layout => false  
    render :nothing => true
  end  
  def application_html_fastrack 
  #  @appln_info = ApplnInfo.find(params[:id])    
  #  render :layout => false     
   render :nothing => true  
  end 
  def application_html_full
   # @appln_info = ApplnInfo.find(params[:id])    
   # render :layout => false 
    render :nothing => true   
  end

  def application_pdf  
    @appln_info = ApplnInfo.find(params[:id])
    pdf = render_to_string :pdf => "#{@appln_info.appln_number}.pdf", :template => "/download_zip/application_html.html.erb", :encoding => "UTF-8"
    save_path = Rails.root.join('pdfs',"#{@appln_info.appln_number}.pdf")
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
  end  

  def application_zip  
    render :nothing => true  
  end  
  
  def application_zip_vob  
    @appln_info = current_user.appln_info
    collect_application_record(@appln_info, 'veteran')
    send_file(
    "#{Rails.root}/zips/veterans_zip/#{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip",
    filename: "#{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip",
    type: "application/zip"
    )
  end   
  
  
  def application_zip_admin  
    
    @appln_info = ApplnInfo.find(params[:id])    
    collect_application_record(@appln_info, 'admin')
    send_file(
    "#{Rails.root}/zips/admin_zip/#{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip",
    filename: "#{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip",
    type: "application/zip"
    )
  end 
  
  


  def collect_application_record(appln_info, user_type) 
    files = {}  
    files_url = {} 
    if appln_info.identity_info 
      paths = []    
      url_paths = []
      if appln_info.identity_info.upload_dd_214_file_name.present? 
        details = []
        details[0] = appln_info.identity_info.upload_dd_214.path
        details[1] = "upload_dd_214"
        paths << details  
      elsif appln_info.identity_info.upload_dd_214_link_url.present?
        url_paths << appln_info.identity_info.upload_dd_214_link_url 
      end 
      if appln_info.identity_info.upload_dod_or_va_letter_file_name.present? 
         details = []
         details[0] = appln_info.identity_info.upload_dod_or_va_letter.path
         details[1] = "upload_dod_or_va_letter"
         paths << details
      elsif appln_info.identity_info.upload_dod_or_va_letter_link_url.present?
        url_paths << appln_info.identity_info.upload_dod_or_va_letter_link_url  
      end   
      if paths.size > 0
        files['veteran_identity_info'] = paths
      end 
      if url_paths.size > 0
        files_url['veteran_identity_info'] = url_paths
      end
    end  
    
    if appln_info.business_profile_info 
      paths = [] 
      url_paths = []  
      if appln_info.business_profile_info.basic_equipment_list_file_name.present? 
        details = []
        details[0] = appln_info.business_profile_info.basic_equipment_list.path
        details[1] = "basic_equipment_list"
        paths << details
      elsif appln_info.business_profile_info.basic_equipment_list_link_url.present? 
        url_paths << appln_info.business_profile_info.basic_equipment_list_link_url   
      end 
      if appln_info.business_profile_info.business_license_file_name.present? 
        details = []
        details[0] = appln_info.business_profile_info.business_license.path
        details[1] = "business_license"
        paths << details
      elsif appln_info.business_profile_info.business_license_link_url.present? 
        url_paths << appln_info.business_profile_info.business_license_link_url   
      end 
      if appln_info.business_profile_info.vehicle_list_file_name.present?  
        details = []
        details[0] = appln_info.business_profile_info.vehicle_list.path
        details[1] = "vehicle_list"
        paths << details
      elsif appln_info.business_profile_info.vehicle_list_link_url.present? 
        url_paths << appln_info.business_profile_info.vehicle_list_link_url   
      end
      if paths.size > 0 
        files['business_profile_info'] = paths 
      end 
      if url_paths.size > 0
        files_url['business_structure'] = url_paths
      end
    end
    
    if appln_info.business_structure 
      paths = [] 
      url_paths = []  
      if appln_info.business_structure.business_locations_file_name.present? 
        details = []
        details[0] = appln_info.business_structure.business_locations.path
        details[1] = "business_locations"
        paths << details
      elsif appln_info.business_structure.business_locations_link_url.present? 
        url_paths << appln_info.business_structure.business_locations_link_url   
      end 
      if paths.size > 0 
        files['business_structure'] = paths 
      end 
      if url_paths.size > 0
        files_url['business_structure'] = url_paths
      end
    end  
    if appln_info.business_relationship_info 
      paths = [] 
      url_paths = []
      if appln_info.business_relationship_info.list_file_name.present?
         details = []
         details[0] = appln_info.business_relationship_info.list.path  
         details[1] = "list"
         paths << details
      elsif appln_info.business_relationship_info.list_link_url.present?   
        url_paths << appln_info.business_relationship_info.list_link_url 
      end
      if appln_info.business_relationship_info.agreement_copy_file_name.present? 
        details = []
        details[0] = appln_info.business_relationship_info.agreement_copy.path  
        details[1] = "agreement_copy"
        paths << details 
      elsif appln_info.business_relationship_info.agreement_copy_link_url.present?  
         url_paths << appln_info.business_relationship_info.agreement_copy_link_url 
      end
      if appln_info.business_relationship_info.corporation_member_list_file_name.present? 
        details = []
        details[0] = appln_info.business_relationship_info.corporation_member_list.path  
        details[1] = "corporation_member_list"
        paths << details
      elsif appln_info.business_relationship_info.corporation_member_list_link_url.present?  
        url_paths << appln_info.business_relationship_info.corporation_member_list_link_url
      end
      if appln_info.business_relationship_info.owner_member_list_file_name.present?
        details = []
        details[0] = appln_info.business_relationship_info.owner_member_list.path  
        details[1] = "owner_member_list"
        paths << details 
      elsif appln_info.business_relationship_info.owner_member_list_link_url.present? 
        url_paths << appln_info.business_relationship_info.owner_member_list_link_url  
      end 
      if paths.size > 0 
        files['business_relationship_info'] = paths 
      end
      if url_paths.size > 0
         files_url['business_relationship_info'] = url_paths
      end
    end  
    if appln_info.bank_detail 
      paths = [] 
      url_paths = []  
      if appln_info.bank_detail.bank_singature_card_file_name.present?  
        details = []
        details[0] = appln_info.bank_detail.bank_singature_card.path 
        details[1] = "bank_singature_card"
        paths << details
      elsif appln_info.bank_detail.bank_singature_card_link_url.present? 
        url_paths << appln_info.bank_detail.bank_singature_card_link_url
      end
      if appln_info.bank_detail.banking_authority_file_name.present?  
        details = []
        details[0] = appln_info.bank_detail.banking_authority.path 
        details[1] = "banking_authority"
        paths << details 
      elsif appln_info.bank_detail.banking_authority_link_url.present? 
        url_paths << appln_info.bank_detail.banking_authority_link_url
      end  
      
      if appln_info.bank_detail.bank_cancel_check_file_name.present? 
        details = []
        details[0] = appln_info.bank_detail.bank_cancel_check.path 
        details[1] = "bank_cancel_check"
        paths << details  
      elsif appln_info.bank_detail.bank_cancel_check_link_url.present? 
        url_paths << appln_info.bank_detail.bank_cancel_check_link_url
      end
      if paths.size > 0 
        files['bank_detail'] = paths  
      end 
      if url_paths.size > 0
         files_url['bank_detail'] = url_paths
      end
    end  
    if appln_info.legal_and_financial_document 
      paths = []  
      url_paths = [] 
      if appln_info.legal_and_financial_document.articals_of_organization_file_name.present?  
        details = []
        details[0] = appln_info.legal_and_financial_document.articals_of_organization.path 
        details[1] = "articals_of_organization"
        paths << details
      elsif appln_info.legal_and_financial_document.articals_of_organization_link_url.present?
       url_paths << appln_info.legal_and_financial_document.articals_of_organization_link_url
      end 
      if appln_info.legal_and_financial_document.minutes_of_meeting_file_name.present?
        details = []
        details[0] = appln_info.legal_and_financial_document.minutes_of_meeting.path 
        details[1] = "minutes_of_meeting"
        paths << details
      elsif appln_info.legal_and_financial_document.minutes_of_meeting_link_url.present?
         url_paths << appln_info.legal_and_financial_document.minutes_of_meeting_link_url
      end
      if appln_info.legal_and_financial_document.stock_ledger_and_stock_transfer_file_name.present?
         details = []
         details[0] = appln_info.legal_and_financial_document.stock_ledger_and_stock_transfer.path 
         details[1] = "stock_ledger_and_stock_transfer"
         paths << details
      elsif appln_info.legal_and_financial_document.stock_ledger_and_stock_transfer_link_url.present?
        url_paths << appln_info.legal_and_financial_document.stock_ledger_and_stock_transfer_link_url
      end 
      if appln_info.legal_and_financial_document.management_agreement_file_name.present? 
        details = []
        details[0] = appln_info.legal_and_financial_document.management_agreement.path 
        details[1] = "management_agreement"
        paths << details
      elsif appln_info.legal_and_financial_document.management_agreement_link_url.present? 
        url_paths << appln_info.legal_and_financial_document.management_agreement_link_url
      end
      if appln_info.legal_and_financial_document.name_doucment_file_name.present?
        details = []
        details[0] = appln_info.legal_and_financial_document.name_doucment.path 
        details[1] = "name_doucment"
        paths << details
      elsif appln_info.legal_and_financial_document.name_doucment_link_url.present?
        url_paths << appln_info.legal_and_financial_document.name_doucment_link_url
      end
      if appln_info.legal_and_financial_document.fein_irs_file_name.present?  
        details = []
        details[0] = appln_info.legal_and_financial_document.fein_irs.path 
        details[1] = "fein_irs"
        paths << details
      elsif appln_info.legal_and_financial_document.fein_irs_link_url.present?
        url_paths << appln_info.legal_and_financial_document.fein_irs_link_url 
      end
      if appln_info.legal_and_financial_document.financial_statement_file_name.present? 
        details = []
        details[0] = appln_info.legal_and_financial_document.financial_statement.path 
        details[1] = "financial_statement"
        paths << details
      elsif appln_info.legal_and_financial_document.financial_statement_link_url.present?  
        url_paths << appln_info.legal_and_financial_document.financial_statement_link_url 
      end
      if appln_info.legal_and_financial_document.irs_tax_return_file_name.present? 
        details = []
        details[0] = appln_info.legal_and_financial_document.irs_tax_return.path 
        details[1] = "irs_tax_return"
        paths << details
      elsif appln_info.legal_and_financial_document.irs_tax_return_link_url.present?  
        url_paths <<  appln_info.legal_and_financial_document.irs_tax_return_link_url
      end
      if appln_info.legal_and_financial_document.debt_instruments_file_name.present? 
        details = []
        details[0] = appln_info.legal_and_financial_document.debt_instruments.path 
        details[1] = "debt_instruments"
        paths << details
      elsif appln_info.legal_and_financial_document.debt_instruments_link_url.present? 
        url_paths << appln_info.legal_and_financial_document.debt_instruments_link_url
      end
      if appln_info.legal_and_financial_document.shareholders_guarantees_any_debt_file_name.present? 
        details = []
        details[0] = appln_info.legal_and_financial_document.shareholders_guarantees_any_debt.path 
        details[1] = "shareholders_guarantees_any_debt"
        paths << details 
      elsif appln_info.legal_and_financial_document.shareholders_guarantees_any_debt_link_url.present? 
        url_paths <<  appln_info.legal_and_financial_document.shareholders_guarantees_any_debt_link_url
      end
      if appln_info.legal_and_financial_document.assets_purchage_agreement_file_name.present? 
        details = []
        details[0] = appln_info.legal_and_financial_document.assets_purchage_agreement.path 
        details[1] = "assets_purchage_agreement"
        paths << details
      elsif appln_info.legal_and_financial_document.assets_purchage_agreement_link_url.present?
        url_paths << appln_info.legal_and_financial_document.assets_purchage_agreement_link_url  
      end 
      if appln_info.legal_and_financial_document.copy_of_bond_certificate_file_name.present?  
        details = []
        details[0] = appln_info.legal_and_financial_document.copy_of_bond_certificate.path 
        details[1] = "copy_of_bond_certificate"
        paths << details
      elsif appln_info.legal_and_financial_document.copy_of_bond_certificate_link_url.present? 
        url_paths << appln_info.legal_and_financial_document.copy_of_bond_certificate_link_url
      end   
      if appln_info.legal_and_financial_document.copy_of_payroll_ledger_file_name.present?
        details = []
        details[0] = appln_info.legal_and_financial_document.copy_of_payroll_ledger.path 
        details[1] = "copy_of_payroll_ledger"
        paths << details
      elsif appln_info.legal_and_financial_document.copy_of_payroll_ledger_link_url.present?
        url_paths << appln_info.legal_and_financial_document.copy_of_payroll_ledger_link_url
      end  
      if paths.size > 0 
        files['legal_and_financial_document'] = paths
      end
      if url_paths.size > 0
           files_url['legal_and_financial_document'] = url_paths
       end
    end  
   
    if appln_info.staff_and_responsibility.staff_responsibilities_details  
      paths = []  
      url_paths = []  
      appln_info.staff_and_responsibility.staff_responsibilities_details.each do |d|  
        if (d.name.present? && d.resume?)  
          details = []
          details[0] = d.resume.path
          details[1] = d.name.gsub(/\s+/, "-").strip
          paths << details 
        elsif (d.name.present? && d.resume_link_url.present? )    
          url_paths << d.resume_link_url 
        end 
        if paths.size > 0   
          files['staff_and_responsibility'] = paths 
        end 
        if url_paths.size > 0
             files_url['staff_and_responsibility'] = url_paths
        end
      end 
    end
 
    if appln_info.declaration 
      paths = [] 
      url_paths = [] 
      if appln_info.declaration.doc.present?  
        details = []
        details[0] = appln_info.declaration.doc.path
        details[1] = 'doc'
        paths << details 
      elsif appln_info.declaration.doc_link_url.present?
        url_paths << appln_info.declaration.doc_link_url
      end  
      if paths.size > 0 
        files['declaration'] = paths 
      end
      if url_paths.size > 0
         files_url['declaration'] = url_paths
      end
    end  
    
    if appln_info.alternate_certification 
      paths = [] 
      url_paths = [] 
      if appln_info.alternate_certification.doc.present? 
        details = []
        details[0] = appln_info.alternate_certification.doc.path
        details[1] = 'doc'  
        paths << details
      elsif appln_info.alternate_certification.doc_link_url.present?
        url_paths << appln_info.alternate_certification.doc_link_url
      end  
      if paths.size > 0 
        files['alternate_certification'] = paths  
      end
      if url_paths.size > 0
         files_url['alternate_certification'] = url_paths
      end
    end  
     
    if user_type == 'admin'  
      
      if appln_info.site_visit 
        paths = [] 
        if appln_info.site_visit.contractor_site_visit_doc.present? 
          details = []
          details[0] = appln_info.site_visit.contractor_site_visit_doc.path  
          details[1] = 'contractor_site_visit_doc'
          paths << details 
        end  
        if paths.size > 0 
          files['site_visit'] = paths 
        end
      end
      
    if appln_info.appln_status == "Certified Certificate Sent" 
      paths = []
      if appln_info.certificate_doc_file_name.present? 
        details = []
        details[0] = appln_info.certificate_doc.path   
        details[1] = 'certificate_doc'
        paths << details
      end 
      if appln_info.certificate_denied_doc_file_name.present? 
        details = []
        details[0] = appln_info.certificate_denied_doc.path   
        details[1] = 'certificate_denied_doc'
        paths << details
      end 
      if paths.size > 0 
        files['application'] = paths  
      end
    end 
   end 
    pdf = ""
    if @appln_info.full_track? 
      pdf = render_to_string :pdf => "#{@appln_info.appln_number}.pdf", :template => "/download_zip/application_html_full.html.erb", :encoding => "UTF-8"
    else 
      pdf = render_to_string :pdf => "#{@appln_info.appln_number}.pdf", :template => "/download_zip/application_html_fastrack.html.erb", :encoding => "UTF-8"
    end 
    
    save_path = Rails.root.join('pdfs',"#{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.pdf")
    File.open(save_path, 'wb') do |file|
      file << pdf
    end 
     
    dir = "#{Rails.root}/zips/veterans_zip/#{appln_info.appln_number.to_s}#{Date.today.strftime('_%b_%Y')}"  
    if user_type == 'admin'  
      dir = "#{Rails.root}/zips/admin_zip/#{appln_info.appln_number.to_s}#{Date.today.strftime('_%b_%Y')}" 
    end 
  
    if File.directory?(dir) 
      FileUtils.rm_rf(dir)
    end
    FileUtils.mkdir_p(dir)  
   
    files.each do |key,value|  
     
      new_dir = dir+"/"+key
      FileUtils.mkdir_p(new_dir)  
      value.each do |f|  
        FileUtils.cp(f[0], "#{new_dir}/#{key}-#{f[1]}-#{f[0].split('/')[-1]}")
      end  
    end  

    if user_type == 'admin'  
      create_file_for_notes(dir,appln_info)
    end 
 
    FileUtils.cp(save_path,dir)   
    if user_type == 'admin' 
     path = "#{Rails.root}/zips/admin_zip/#{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip"  
     File.delete(path) if File.exist?(path) 
     system("cd #{Rails.root}/zips/admin_zip/ && zip -r #{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip  #{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}");
    else 
     path = "#{Rails.root}/zips/veterans_zip/#{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip"  
     File.delete(path) if File.exist?(path) 
     system("cd #{Rails.root}/zips/veterans_zip/ && zip -r #{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}.zip  #{@appln_info.appln_number}#{Date.today.strftime('_%b_%Y')}"); 
    end
  end  
  
  def create_file_for_urls(dir,urls) 
    path = dir+"/docurl#{Date.today.strftime('_%b_%Y')}.txt"
    content = "---------------Url---------------\n\n"   
    urls.each do |key,value| 
      content += "\n"
      content += "#{key}\n" 
      content += "---------------\n" 
      value.each do |f|   
        content += "Url: #{f}\n" 
      end
      content += "\n"   
    end
    File.open(path, "w+") do |f|
      f.write(content)
    end 

  end 
  
  def create_file_for_notes(dir,appln)  
    ca_admin_contant = ""
    aa_admin_contant = ""
    co_admin_contant = ""
    final_note = "" 
    if appln.account_admin   
      aa_admin_contant = appln.account_admin.name  if appln.account_admin
      aa_admin_contant += "\n-----------------------------\n"  if appln.account_admin 
      ca_admin_contant = appln.certification_admin.name if appln.certification_admin
      ca_admin_contant += "\n-----------------------------\n" if appln.certification_admin 
      co_admin_contant = appln.contractor.name  if appln.contractor
      co_admin_contant += "\n-----------------------------\n" if appln.contractor  
      final_note = "\nCertified Certificate Sent - Notes:\n"
      final_note +="#{appln.certificate_notes}"  
        
      path = dir+"/notes#{Date.today.strftime('_%b_%Y')}.txt"   
    
      if appln.comments.size > 0   
        ca_admin_contant += comment_add_ca(appln.comments.where(user_id: appln.ca_id), 'Appln Info')  
        aa_admin_contant += comment_add_aa(appln.comments.where(user_id: appln.aa_id), 'Appln Info') 
      end
      if appln.company_info.comments.size > 0  
        ca_admin_contant += comment_add_ca(appln.company_info.comments.where(user_id: appln.ca_id), 'Company Info')  
        comment_add_aa(appln.company_info.comments.where(user_id: appln.aa_id), 'Company Info')
      end   
      if appln.identity_info.comments.size  > 0 
        ca_admin_contant += comment_add_ca(appln.identity_info.comments.where(user_id: appln.ca_id),'Veteran Identity Info' )  
        aa_admin_contant += comment_add_aa(appln.identity_info.comments.where(user_id: appln.aa_id),'Veteran Identity Info')
      end   
      if appln.business_profile_info.comments.size > 0   
        ca_admin_contant += comment_add_ca(appln.business_profile_info.comments.where(user_id: appln.ca_id),'Business Profile Info' )  
        aa_admin_contant += comment_add_aa(appln.business_profile_info.comments.where(user_id: appln.aa_id),'Business Profile Info')
      end   
      if appln.business_structure.comments.size > 0 
        ca_admin_contant += comment_add_ca(appln.business_structure.comments.where(user_id: appln.ca_id),'Business Structure' )  
        aa_admin_contant += comment_add_aa(appln.business_structure.comments.where(user_id: appln.aa_id),'Business Structure')
      end   
      if appln.business_relationship_info.comments.size > 0 
        ca_admin_contant += comment_add_ca(appln.business_relationship_info.comments.where(user_id: appln.ca_id),'Business Relationship Info' )  
        aa_admin_contant += comment_add_aa(appln.business_relationship_info.comments.where(user_id: appln.aa_id),'Business Relationship Info')
      end   
      if appln.staff_and_responsibility.comments.size > 0  
        ca_admin_contant += comment_add_ca(appln.staff_and_responsibility.comments.where(user_id: appln.ca_id),'Staff and Responsibility' )  
        aa_admin_contant += comment_add_aa(appln.staff_and_responsibility.comments.where(user_id: appln.aa_id),'Staff and Responsibility')
      end   
      if appln.bank_detail.comments.size > 0 
        ca_admin_contant += comment_add_ca(appln.bank_detail.comments.where(user_id: appln.ca_id),'Bank detail' )  
        aa_admin_contant += comment_add_aa(appln.bank_detail.comments.where(user_id: appln.aa_id),'Bank detail')
      end   
      if appln.legal_and_financial_document.comments.size > 0 
        ca_admin_contant += comment_add_ca(appln.legal_and_financial_document.comments.where(user_id: appln.ca_id),'Legal and Financial Document' )  
        aa_admin_contant += comment_add_aa(appln.legal_and_financial_document.comments.where(user_id: appln.aa_id),'Legal and Financial Document')
      end   
      if appln.declaration.comments.size > 0  
        ca_admin_contant += comment_add_ca(appln.declaration.comments.where(user_id: appln.ca_id),'Declaration' )  
        aa_admin_contant += comment_add_aa(appln.declaration.comments.where(user_id: appln.aa_id),'Declaration')
      end  
      if appln.site_visit.comments.size > 0 
        ca_admin_contant += comment_add_ca(appln.site_visit.comments.where(user_id: appln.ca_id),'Site Visit' )  
        co_admin_contant += comment_add_co(appln.site_visit.comments.where(user_id: appln.aa_id),'Site Visit')
      end  
      if appln.alternate_certification.comments.size > 0  
        ca_admin_contant += comment_add_ca(appln.alternate_certification.comments.where(user_id: appln.ca_id),'Alternate Certification' )  
        aa_admin_contant += comment_add_aa(appln.alternate_certification.comments.where(user_id: appln.aa_id),'Alternate Certification')
      end   
    
    
      notes = ca_admin_contant + aa_admin_contant + co_admin_contant + final_note  
    
      File.open(path, "w+") do |f|
        f.write(notes)
      end  
    end 
 
  end 
  
  def comment_add_ca(comments, mod) 
     text = ""  
     if comments.size > 0  
        text = "\n #{mod} \n"  
       comments.each do |comment|
         text += comment.comment
         text += "\n"
         text += "                                   
         text += "\n" 
       end 
     end
     return text
  end  
  def comment_add_aa(comments, mod) 
      text = ""  
      if comments.size > 0  
         text = "\n #{mod} \n"  
        comments.each do |comment|
          text += comment.comment
          text += "\n"
          text += "                                  
          text += "\n" 
        end 
      end
      return text
   end  
   def comment_add_co(comments, mod) 
       text = ""  
       if comments.size > 0  
          text = "\n #{mod} \n"  
         comments.each do |comment|
           text += comment.comment
           text += "\n"
           text += "                                  
           text += "\n" 
         end 
       end
       return text
    end

end
