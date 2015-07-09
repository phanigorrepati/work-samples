class AlternateCertificationsController < ApplicationController   
  before_filter :authenticate_user! 
  layout 'form' 
  before_action :set_appln_info
  before_action :set_alternate_certification, only: [:show, :edit, :update, :destroy]
  respond_to :html, :xml, :json, :js  
  def index
    @alternate_certifications = AlternateCertification.all
    respond_with(@alternate_certifications)
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
    @alternate_certification = AlternateCertification.new
    respond_with(@alternate_certification)
  end

  def edit
  end

  def create
    @alternate_certification = AlternateCertification.new(alternate_certification_params)
    flash[:notice] = 'Alternate Certification was successfully created.' if @alternate_certification.save
    respond_with(@alternate_certification)
  end

  def update  
    
    flash[:notice] = 'Alternate Certification was successfully updated.' if @alternate_certification.update(alternate_certification_params)
    @alternate_certification.appln_info.app_review_update(current_user, 'AlternateCertification')   
    if params[:back_url].present?    
      redirect_to edit_appln_info_alternate_certification_path(@appln_info,@alternate_certification, :back_url => true) 
    else 
      redirect_to edit_appln_info_alternate_certification_path(@appln_info,@alternate_certification)
    end 
  end

  def destroy
    @alternate_certification.destroy
    respond_with(@alternate_certification)
  end

  private
    def set_alternate_certification    
      @alternate_certification = AlternateCertification.find(params[:id]) 
    end

    def alternate_certification_params
      params.require(:alternate_certification).permit(:copy_of_fein_document, :copy_of_fein_document_link_url, :doc_link_url, :doc, :appln_info_id, :dummy)
    end
end
