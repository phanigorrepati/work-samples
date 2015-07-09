require 'roo'
require 'spreadsheet'
namespace :sci do

  desc "create data"
  task :populate_sci_data => :environment do    
   
    file_name = Dir.entries('lib/data/sic')   
        
        file_name.each do |data_file|
        if data_file.to_s.include?('toml')  
          file =  File.expand_path("lib/data/sic/"+data_file) 
          puts file.inspect
          toml_record = TOML.load_file(file)
          @name = toml_record["name"]
          #@correlations = toml_record["sic_correlations"]
          @correlations = toml_record["naics_correlations"]
          @sic = Sic.find_by_code(toml_record["code"]) 
          if @sic.nil?   
           unless toml_record["name"].nil?
             @sic = Sic.create(:code => toml_record["code"] , :name => toml_record["name"], :lower_name => toml_record["name"].downcase, :upper_name => toml_record["name"].upcase) 
           end
          end 
           unless @correlations.nil?
              @correlations.each do |da| 
                d = Naic.find_by_code(da)  
                if d
                  @datap = NaicsSic.find_by_sic_id_and_naic_id(@sic.id,d.id) 
                  if @datap.nil?
                     NaicsSic.create(:sic_id => @sic.id, :naic_id => d.id )  
                  end  
                end
              end
            end
       end  
     end

       file_name = Dir.entries('lib/data/naics')   
       file_name.each do |data_file|
       if data_file.to_s.include?('toml')  
         file =  File.expand_path("lib/data/naics/"+data_file) 
         puts file.inspect
         toml_record = TOML.load_file(file)
         @name = toml_record["name"]
         @correlations = toml_record["sic_correlations"]
         #@correlations = toml_record["naics_correlations"]
          @naisc = Naic.find_by_name(toml_record["name"]) 
          if @naisc.nil? 
             unless toml_record["name"].nil?     
               @naisc =  Naic.create(:code => toml_record["code"] , :name => toml_record["name"], :lower_name => toml_record["name"].downcase, :upper_name => toml_record["name"].upcase)
             end
          end 
          unless @correlations.nil?
            @correlations.each do |da| 
              d = Sic.find_by_code(da)  
              if d
                @datap = SicNaics.find_by_sic_id_and_naic_id(d.id,@naisc.id) 
                if @datap.nil?
                   SicNaics.create(:sic_id => d.id, :naic_id => @naisc.id )  
                end  
              end
            end
          end
       end 
      end
       
  xls = Roo::CSV.new("#{Rails.root}/lib/data/2012_NAICS_Index_File.csv")
   xls.each do |v|   
     if v[0].to_i > 0 
      naisc = Naic.find_by_name(v[1])
       if naisc.nil?  
          naisc =  Naic.create(:code => v[0] , :name => v[1], :lower_name => v[1].downcase, :upper_name => v[1].upcase)
       end  
      end
  end
  end 

end
