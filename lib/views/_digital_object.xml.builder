xml.tag! "envelope:record" do

xml.tag! "envelope:recordHeader", :DIRECTIVE => "UPSERT" do
  xml.tag! "envelope:recordIdentifier", "mets-#{PROVIDER}-UA-#{unit.id}"
  xml.tag! "envelope:recordDatestamp", Time.now.strftime("%Y-%m-%dT%H:%M:%S")
end

xml.tag! "envelope:recordBody" do
  xml.tag! "mets:mets" do

    custodians = unit.fond.root.custodians

    xml.tag! "mets:metsHdr", {
      :CREATEDATE   => Time.now.strftime("%Y-%m-%dT%H:%M:%S"),
      :LASTMODDATE  => Time.now.strftime("%Y-%m-%dT%H:%M:%S"),
      :RECORDSTATUS => "Complete"
    } do

      xml.tag! "mets:agent", :ROLE => "CREATOR", :TYPE => "ORGANIZATION" do
        xml.tag! "mets:name", PROVIDER
      end

      xml.tag! "mets:agent", :ROLE => "IPOWNER", :TYPE => "ORGANIZATION" do
        xml.tag! "mets:name", custodians.present? ? custodians[0].preferred_name.name : PROVIDER
      end

      xml.tag! "mets:altRecordID", "#{PROVIDER}:UA-#{unit.id}", :TYPE => PROVIDER

    end

    xml.tag! "mets:dmdSec", :ID => "ead-context-001", :GROUPID => "desc" do
      xml.tag! "mets:mdWrap", :LABEL => "Contesto", :MDTYPE => "EAD", :MDTYPEVERSION => "Arch", :MIMETYPE => "text/xml" do
        xml.tag! "mets:xmlData" do
          xml.tag! "ead-context:ead" do
            xml.tag! "ead-context:archdesc" do
              xml.tag! "ead-context:did" do
                xml.tag! "ead-context:unitid", "#{PROVIDER}:CA-#{unit.fond.root.id}"
                xml.tag! "ead-context:unittitle", unit.fond.root.name
                if custodians.present?
                  xml.tag! "ead-context:repository", :id => "#{PROVIDER}:SC-#{custodians[0].id}" do
                    xml.tag! "ead-context:corpname", custodians[0].preferred_name.name
                    xml.tag! "ead-context:abbr", "#{PROVIDER}:SC-#{custodians[0].id}"
                  end
                end
              end
            end
          end
        end
      end
    end

    xml.tag! "mets:dmdSec", :ID => "ead-desc-001", :GROUPID => "desc" do
      xml.tag! "mets:mdWrap", :LABEL => "Descrizione oggetto", :MDTYPE => "EAD", :MDTYPEVERSION => "Arch", :MIMETYPE => "text/xml" do
        xml.tag! "mets:xmlData" do
          xml.tag! "ead:c" do
            xml.tag! "ead:did" do
              xml.tag! "ead:unitid", "#{PROVIDER}:UA-#{unit.id}"
              xml.tag! "ead:unittitle", unit.title
              if unit.preferred_event.present?
                xml.tag! "ead:unitdate", unit.preferred_event.full_display_date, {
                  :normal => [unit.preferred_event.start_date_from.strftime("%Y%m%d"), unit.preferred_event.end_date_to.strftime("%Y%m%d")].uniq.join("/"),
                  :datechar => "principale"
                }
              else
                xml.tag! "ead:unitdate", "non indicata", :normal => "00000101", :datechar => "non indicata"
              end
              xml.tag! "ead:physdesc" do
                xml.tag! "ead:genreform", unit.unit_type, :type => "tipologie documentarie"
              end
            end
            xml.tag! "ead:dao", :"xlink:href" => "#{FONDS_URL}/#{unit.fond.id}/units/#{unit.id}"
          end
        end
      end
    end

    xml.tag! "mets:dmdSec", :ID => "rel" do
      xml.tag! "mets:mdWrap", :LABEL => "Relazioni SAN", :MDTYPE => "OTHER", :OTHERMDTYPE => "RDF", :MIMETYPE => "text/xml" do
        xml.tag! "mets:xmlData" do
          xml.tag! "rdf:RDF" do
            xml.tag! "rdf:Description", :"rdf:about" => "#{PROVIDER}:UA-#{unit.id}" do
              xml.tag! "san-dl:haSistemaAderente", :"rdf:resource" => DL_SISTEMA_ADERENTE
              xml.tag! "san-dl:haProgettoDigitalizzazione", :"rdf:resource" => DL_PROGETTO_DIGITALIZZAZIONE
              xml.tag! "san-dl:haConservatore", :"rdf:resource" => DL_CONSERVATORE
              xml.tag! "san-dl:haComplesso", :"rdf:resource" => DL_COMPLESSO
            end
          end
        end
      end
    end

    xml.tag! "mets:amdSec" do
      xml.tag! "mets:rightsMD", :ID => "amdRD001" do
        xml.tag! "mets:mdWrap", :LABEL => "Diritti oggetto digitale", :MDTYPE => "METSRIGHTS", :MIMETYPE => "text/xml" do
          xml.tag! "mets:xmlData" do
            xml.tag! "metsrights:RightsDeclarationMD", :RIGHTSCATEGORY => "COPYRIGHTED" do
              xml.tag! "metsrights:RightsHolder" do
                xml.tag! "metsrights:RightsHolderName", custodians.present? ? custodians[0].preferred_name.name : PROVIDER
              end
            end
          end
        end
      end

      xml.tag! "mets:rightsMD", :ID => "amdRA001" do
        xml.tag! "mets:mdWrap", :LABEL => "Diritti oggetto analogico", :MDTYPE => "METSRIGHTS", :MIMETYPE => "text/xml" do
          xml.tag! "mets:xmlData" do
            xml.tag! "metsrights:RightsDeclarationMD", :RIGHTSCATEGORY => "COPYRIGHTED" do
              xml.tag! "metsrights:RightsHolder" do
                xml.tag! "metsrights:RightsHolderName", custodians.present? ? custodians[0].preferred_name.name : PROVIDER
              end
            end
          end
        end
      end
    end

    xml.tag! "mets:fileSec" do
      xml.tag! "mets:fileGrp", :USE => "thumbnail image" do
        dob = unit.digital_objects.all(:order => "position").first
        xml.tag! "mets:file", :ID => "OD-#{dob.id}", :MIMETYPE => "image/jpeg" do
          xml.tag! "mets:FLocat", :LOCTYPE => "URL",
          :"xlink:href" => "#{DIGITAL_OBJECTS_URL}/#{dob.access_token}/medium.jpg"
        end
      end
    end
  end
end

end