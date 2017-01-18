xml.catRecord do
  xml.catRecordHeader :type => "complesso archivistico" do
    xml.id "CA-#{fond.id}"
    xml.lastUpdate fond.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
  end
  xml.catRecordBody do
    xml.ead :xmlns => "http://san.mibac.it/ead-san/" do
      xml.archdesc :level => "otherlevel", :otherlevel => fond.fond_type do
        xml.did do
          xml.unitid "CA-#{fond.id}", :type => PROVIDER, :identifier => "#{FONDS_URL}/#{fond.id}"
          xml.unittitle fond.name, :type => "principale"

          if fond.other_names.present?
            fond.other_names.each do |other_name|
              xml.unittitle other_name.name
            end
          end
          if fond.preferred_event.present?
            xml.unitdate fond.preferred_event.full_display_date, {
              :normal => [fond.preferred_event.start_date_from.strftime("%Y%m%d"), fond.preferred_event.end_date_to.strftime("%Y%m%d")].uniq.join("/"),
              :datechar => "principale"
            }
          else
            xml.unitdate "non indicata", :normal => "00000101", :datechar => "non indicata"
          end

          xml.physdesc do
            tmp_string = ""
            tmp_string += "Metri lineari: #{fond.length}. " if fond.length.present?
            tmp_string += fond.extent.squish if fond.extent.present?
            extent = tmp_string.present? ? tmp_string : "non indicata"
            xml.extent extent
          end

          if fond.abstract.present?
            xml.abstract textilize(fond.abstract), :langcode => "it_IT"
          end

          if fond.creators.present?
            fond.creators.each do |creator|
              xml.origination "SP-#{creator.id}"
            end
          end

          # OPTIMIZE: fare controllo preliminare su custodian: Fond.roots.unassigned_to_custodian
          custodians = fond.root.custodians
          if custodians.present?
            xml.repository custodians[0].preferred_name.name, :id => "SC-#{custodians[0].id}", :label => PROVIDER
          end
        end

        xml.processinfo "scheda pubblicata"

        xml.relatedmaterial do
          xml.archref "CA-#{fond.root.id}"
        end

        if fond.sources.present?
          fond.sources.each do |source|
            xml.otherfindaid do
              xml.extref "SR-#{source.id}"
            end
          end
        end

      end
    end
  end
end
