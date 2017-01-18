xml.catRecord do
  xml.catRecordHeader :type => "soggetto produttore" do
    xml.id "SP-#{creator.id}"
    xml.lastUpdate creator.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
  end
  xml.catRecordBody do
    xml.tag! "eac-cpf", :xmlns => "http://san.mibac.it/eac-san/" do
      xml.control do
        xml.otherRecordId "SP-#{creator.id}", :localType => PROVIDER
        xml.maintenanceStatus "scheda pubblicata"
        xml.sources do
          xml.source :"xlink:href" => "#{CREATORS_URL}/#{creator.id}"
        end
      end

      types = {"C" => "corporateBody", "P" => "person", "F" => "family"}
      entityType = types[creator.creator_type]

      xml.cpfDescription do
        xml.identity do
          xml.entityType entityType
          xml.nameEntry do
            xml.part creator.preferred_name.name
          end

          # NOTA: non implementato 06: "Forma parallela nel caso di bilinguismo"
          creator.other_names.each do |other_name|
            xml.nameEntry :localType => "altradenominazione" do
              xml.part other_name.name
            end
          end
        end

        xml.description do
          xml.existDates do
            xml.dateSet do
              if creator.preferred_event.present?
                xml.date creator.preferred_event.full_display_date, {
                  :standardDate => [creator.preferred_event.start_date_from.strftime("%Y%m%d"), creator.preferred_event.end_date_to.strftime("%Y%m%d")].uniq.join("/"),
                  :localType => "date di esistenza"
                }
              else
                xml.date "non indicata", :standardDate => "00000101/99991231", :localType => "date di esistenza"
              end
            end
          end

          # TODO: Persone - indicare luoghi di nascita e morte ?
          if entityType == "corporateBody"
            xml.placeDates do
              xml.placeDate do
                xml.place creator.residence.present? ? creator.residence : "non indicata"
                xml.descriptiveNote "sede"
              end
            end
          end

          # TODO: Persone - indicare activities ?
          if entityType == "corporateBody" && creator.creator_corporate_type.present?
            xml.descriptiveEntries do
              xml.descriptiveEntry do
                xml.term creator.creator_corporate_type.corporate_type
                xml.descriptiveNote "tipologia ente"
              end
            end
          end

          if creator.abstract.present?
            xml.biogHist do
              xml.abstract textilize(creator.abstract)
            end
          end
        end

        related_fonds = creator.fonds.find(:all, :conditions => ["fond_id IN (?)", fond_ids])
        xml.relations do
          related_fonds.each do |fond|
            xml.resourceRelation :resourceRelationType => "creatorOf" do
              xml.relationEntry "CA-#{fond.id}"
            end
          end

          creator.rel_creator_creators.each do |rel|
            xml.cpfRelation :localType => rel.creator_association_type.association_type do
              xml.relationEntry "SP-#{rel.related_creator_id}"
            end
          end
        end

      end
    end
  end
end

