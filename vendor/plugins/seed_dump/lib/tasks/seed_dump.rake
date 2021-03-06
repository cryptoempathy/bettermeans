namespace :db do
  namespace :seed  do
    desc "Dump records from the database into db/seeds.rb"
    task :dump => :environment do

      # config
      opts = {}
      opts['with_id'] = !ENV["WITH_ID"].nil?
      opts['no-data'] = !ENV['NO_DATA'].nil?
      opts['models']  = ENV['MODELS'] || (ENV['MODEL'] ? ENV['MODEL'] : "")
      opts['file']    = ENV['FILE'] || "#{Rails.root}/db/seeds.rb"
      opts['append']  = (!ENV['APPEND'].nil? && File.exists?(opts['file']) )
      ar_options      = ENV['LIMIT'].to_i > 0 ? { :limit => ENV['LIMIT'].to_i } : {}
      indent          = " " * (ENV['INDENT'].nil? ? 2 : ENV['INDENT'].to_i)

      models = opts['models'].split(',').collect {|x| x.underscore.singularize }

      new_line = "\n"

      puts "Appending seeds to #{opts['file']}." if opts['append']

      seed_rb = ""
      
      if models
        models.each do |model_name|
	        begin
            puts "Adding #{model_name.camelize} seeds."

	          create_hash = ""

	          model = model_name.camelize.constantize
	          arr = []
	          next unless defined? model.find
            seed_rb << "#{new_line}puts \"#{model_name.camelize}...\""
            seed_rb << "#{new_line}#{model_name.camelize}.delete_all" unless opts['append']
            
	          arr = model.find(:all, ar_options) unless opts['no-data'] 
        	  arr = arr.empty? ? [model.new] : arr
        	  arr.each_with_index { |r,i| 

              attr_s = [];

              r.attributes.each { |k,v|
  	            v = (v.class == Time || v.class == Date) ? "\"#{v}\"" : v.inspect
                attr_s.push("#{k.to_sym.inspect} => #{v}") unless k == 'id' && !opts['with_id']
              }

              create_hash << (i > 0 ? ",#{new_line}" : new_line) << indent << '{ ' << attr_s.join(', ') << ' }'
            } 

            seed_rb << "#{new_line}#{model_name.pluralize} = #{model_name.camelize}.create([#{create_hash}#{new_line}])#{new_line}"
          rescue Exception => e
            puts "Exception ignored....#{e.inspect}"
          end
        end
            # begin
            # 
            #               puts "Adding #{model_name.camelize} seeds..."
            # 
            #   create_hash = ""
            # 
            #   model = model_name.camelize.constantize
            #   arr = []
            #   next unless defined? model.find
            #               seed_rb << "#{new_line}puts \"#{model_name.camelize}\"..."
            #               seed_rb << "#{new_line}#{model_name.camelize}.delete_all" unless opts['append']
            #               seed_rb << "#{new_line}#{model_name.camelize}.protected_attributes.clear"
            #   
            #   arr = model.find(:all, ar_options) unless opts['no-data'] 
            #               arr = arr.empty? ? [model.new] : arr
            #               arr.each_with_index { |r,i| 
            #                 # puts r.id
            # 
            #                 attr_s = [];
            # 
            #                 r.attributes.each { |k,v|
            #                   v = (v.class == Time || v.class == Date) ? "\"#{v}\"" : v.inspect
            #                   attr_s.push("#{k.to_sym.inspect} => #{v}") unless k == 'id' && !opts['with_id']
            #                 }
            # 
            #                 create_hash << (i > 0 ? ",#{new_line}" : new_line) << indent << '{ ' << attr_s.join(', ') << ' }'
            #                 seed_rb << "#{new_line}@rec = #{model_name.camelize}.new(#{create_hash}#{new_line})"
            #                 seed_rb << "#{new_line}@rec.id = #{r.id}"
            #                 seed_rb << "#{new_line}@rec.save"
            #               } 
            # 
            #             rescue
            #               puts "Exception ignored...."
            #             end
      # else
      #   Dir['app/models/*.rb'].sort.each do |f|
      #             model_name  = File.basename(f, '.*')
      #             begin
      #       if models.include?(model_name) || models.empty? 
      # 
      #         puts "Adding #{model_name.camelize} seeds."
      # 
      #               create_hash = ""
      # 
      #               model = model_name.camelize.constantize
      #               arr = []
      #               next unless defined? model.find
      #               arr = model.find(:all, ar_options) unless opts['no-data'] 
      #         arr = arr.empty? ? [model.new] : arr
      #         arr.each_with_index { |r,i| 
      # 
      #           attr_s = [];
      # 
      #           r.attributes.each { |k,v|
      #                   v = (v.class == Time || v.class == Date) ? "\"#{v}\"" : v.inspect
      #             attr_s.push("#{k.to_sym.inspect} => #{v}") unless k == 'id' && !opts['with_id']
      #           }
      # 
      #           create_hash << (i > 0 ? ",#{new_line}" : new_line) << indent << '{ ' << attr_s.join(', ') << ' }'
      #         } 
      # 
      #         seed_rb << "#{new_line}#{model_name.pluralize} = #{model_name.camelize}.create([#{create_hash}#{new_line}])#{new_line}"
      #       end
      #       rescue
      #         puts "Exception ignored...."
      #       end
      #   end
      end

      File.open(opts['file'], (opts['append'] ? "a" : "w")) { |f|

      puts "Writing #{opts['file']}."

      unless opts['append']
          cont =<<HERE
# Autogenerated by the db:seed:dump task
# Do not hesitate to tweak this to your needs
HERE
          f << cont
        end

	cont =<<HERE
#{seed_rb}
HERE
      f << cont

      puts "Done."

}
    end
  end
end
