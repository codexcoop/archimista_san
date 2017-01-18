require File.join(File.dirname(__FILE__), "..", "config.rb")

namespace :san do

  def views_path
    File.join(File.dirname(__FILE__), "..", "views")
  end

  def set_fonds
    @fonds = Fond.roots.all(:order => "name")
  end

  def selected_fond_ids
    set_fonds
    fond_ids = @fonds.map(&:id)
  end

  def stream(records, fond_ids = [])
    if records.present?
      file = "#{records[0].class.name.tableize}.xml"
      view = ActionView::Base.new(views_path)
      stream = Rails.cache.write("cache_var", view.render(:file => "#{file}.builder",
        :locals => {:records => records, :fond_ids => fond_ids}))

      dest_file = File.join(DEST_DIR, file)
      File.open(dest_file, 'w') { |f| f.write(stream) }
      puts "=> #{dest_file}"
    else
      puts "Nessun risultato"
    end
  end

  desc "Genera metadati CAT-SAN relativi a: [fonds | creators | custodians | sources]"
  task :build_xml, [:records] => :environment do |t, args|
    case args[:records]

    when "fonds"
      set_fonds
      puts "Genero file CAT-SAN con #{@fonds.count} complessi archivistici ..."
      stream(@fonds)

    when "creators"
      @creators = Creator.all(:conditions => ["id IN (SELECT distinct creator_id FROM rel_creator_fonds WHERE fond_id IN (?))", selected_fond_ids])
      puts "Genero file CAT-SAN con #{@creators.count} soggetti produttori ..."
      stream(@creators, selected_fond_ids)

    when "custodians"
      @custodians = Custodian.all(:conditions => ["id IN (SELECT distinct custodian_id FROM rel_custodian_fonds WHERE fond_id IN (?))", selected_fond_ids])
      puts "Genero file CAT-SAN con #{@custodians.count} soggetti conservatori ..."
      stream(@custodians)

    when "sources"
      @sources = Source.all(:conditions => ["id IN (SELECT distinct source_id FROM rel_fond_sources WHERE fond_id IN (?))", selected_fond_ids])
      puts "Genero file CAT-SAN con #{@sources.count} fonti / strumenti di ricerca ..."
      stream(@sources, selected_fond_ids)

    else
      puts "Argomento non valido.\nScegli tra [fonds | creators | custodians | sources]"
    end
  end

  def stream_mets(records)
    if records.present?
      file = "digital_objects.xml"
      view = ActionView::Base.new(views_path)
      stream = Rails.cache.write("cache_var", view.render(:file => "#{file}.builder",
        :locals => {:records => records}))

      dest_file = File.join(DEST_DIR, file)
      File.open(dest_file, 'w') { |f| f.write(stream) }
      puts "=> #{dest_file}"
    else
      puts "Nessun risultato"
    end
  end

  desc "Genera metadati METS-SAN relativi a immagini di unità archivistiche, per singolo complesso di livello 1"
  task :build_mets, [:fond_id] => :environment do |t, args|

    if args[:fond_id].present?
      @fond = Fond.find(args.fond_id, :select => "id, name")
      puts "\n##{@fond.id} - #{@fond.name}"
      puts "\nParametri SAN:"
      puts "- sistema aderente: #{DL_SISTEMA_ADERENTE}"
      puts "- progetto digitalizzazione: #{DL_PROGETTO_DIGITALIZZAZIONE}"
      puts "- conservatore: #{DL_CONSERVATORE}"
      puts "- complesso: #{DL_COMPLESSO}"

      puts "\nConfermi? (s/n)"
        input = STDIN.gets.strip
        if input == 's'
          q = ["SELECT * FROM units
                WHERE id IN
                (SELECT distinct attachable_id FROM digital_objects WHERE attachable_type = 'Unit' AND asset_content_type LIKE 'image%')
                AND root_fond_id = ?
                ORDER BY sequence_number", args.fond_id]
          @units = Unit.find_by_sql(q)
          puts "Genero file METS-SAN con #{@units.count} unità ..."
          stream_mets(@units)
        else
          puts "Non faccio nulla"
        end
    else
      puts "Argomento non valido.\nSpecifica l'id del complesso archivistico di livello 1"
    end
  end

  # TODO: task pre_check ?
  # desc "Controlla conformità dei dati alle regole SAN, prima di generare i metadati"
  # task :pre_check, [:fond_id] => :environment do |t, args|
  # end

end
