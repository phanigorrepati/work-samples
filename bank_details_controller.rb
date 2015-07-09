class BankDetailsController < ApplicationController 
  before_filter :authenticate_user! 
  layout 'form' 
  before_action :set_appln_info 
  before_action :set_bank_detail, only: [:show, :edit, :update, :destroy]
  respond_to :html, :xml, :json, :js  
  def index
    @bank_details = BankDetail.all
    respond_with(@bank_details)
  end

  def show   
    if params[:review].present?
      @show_ok = true
    end
    respond_to do |format|
      format.html{ render action: :edit } 
      format.js{ render action: :show }
    end
  end

  def new
    @bank_detail = BankDetail.new
    respond_with(@bank_detail)
  end

  def edit
  end

  def create
    @bank_detail = BankDetail.new(bank_detail_params)
    @bank_detail.save
    respond_with(@bank_detail)
  end

  def update     
      
    @bank_detail.update(bank_detail_params) 
    
    if params[:bank_details_cancel_check].present?   
       if params[:bank_details_cancel_check][:doc].present?  
          params[:bank_details_cancel_check][:doc].each do |key,value|  
            check_docs = @bank_detail.bank_details_cancel_checks.where(:order => key.to_i ).first
            if check_docs.nil?
               @bank_detail.bank_details_cancel_checks.create(:doc =>value, :order => key.to_i )
            else
               check_docs.update_attributes(:doc =>value, :order => key.to_i )  
            end
          end 
       end  
       if params[:bank_details_cancel_check][:doc_link_url].present?  
           params[:bank_details_cancel_check][:doc_link_url].each do |key,value|  
             check_docs = @bank_detail.bank_details_cancel_checks.where(:order => key.to_i ).first
             if check_docs.nil?
                @bank_detail.bank_details_cancel_checks.create(:doc_link_url =>value, :order => key.to_i )
             else
                check_docs.update_attributes(:doc_link_url =>value, :order => key.to_i )  
             end
           end 
        end
    end
     
    @bank_detail.appln_info.app_review_update(current_user, 'BankDetail')  
    flash[:notice] = "Bank Details saved successfully."  
    if params[:back_url].present?    
      redirect_to edit_appln_info_bank_detail_path(@appln_info,@bank_detail, :back_url => true)
    else 
      redirect_to edit_appln_info_bank_detail_path(@appln_info,@bank_detail)
    end  
  end

  def destroy
    @bank_detail.destroy
    respond_with(@bank_detail)
  end

  private
    def set_bank_detail
      @bank_detail = BankDetail.find(params[:id])
    end

    def bank_detail_params
      params.require(:bank_detail).permit(:bank_cancel_check, :bank_cancel_check_link_url, :banking_authority_link_url, :bank_singature_card_link_url, :bank_singature_card, :banking_authority,:name_of_institution, :address, :city, :state, :postal_code, :type_of_account, :credit_line, :bank_contact_name, :bank_contact_title, :bank_contact_phone)
    end
end
