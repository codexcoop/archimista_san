xml.catRecord do
  xml.catRecordHeader :type => "soggetto conservatore" do
    xml.id "SC-#{custodian.id}"
    xml.lastUpdate custodian.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
  end
  xml.catRecordBody do
    xml.scons :xmlns => "http://san.mibac.it/scons-san/" do

      xml.formaautorizzata custodian.preferred_name.name
      # NOTA: non implementato 06: "Forma parallela nel caso di bilinguismo"

      acronimo = custodian.other_names.first(:conditions => "qualifier = 'AC'")
      xml.acronimo acronimo.name if acronimo.present?

      xml.identifier :href => "#{CUSTODIANS_URL}/#{custodian.id}" do
        xml.recordId "SC-#{custodian.id}"
        xml.sistemaId PROVIDER
      end

      tipologia = custodian.custodian_type.present? ? custodian.custodian_type.custodian_type : "non indicata"
      xml.tipologia tipologia

      # OPTIMIZE: schiacciare localizzazioni doppie ?
      # Oppure considerare solo "sede legale" (custodian_headquarter) ? ma non sempre è compilato...
      custodian.custodian_buildings.each do |building|
        city = building.city.chomp(')').split('(')
        xml.tag! "localizzazione", :paese => building.country, :provincia => city[1], :comune => city[0].strip, :cap => building.postcode
      end

      custodian.custodian_urls.each do |url|
        xml.sitoweb :href => url.url
      end

      xml.servizi textilize(custodian.services) if custodian.services.present?
      xml.descrizione textilize(custodian.history) if custodian.history.present?

      # FIXME: il campo SAN "altroaccesso" (come "orario") ha come limite 1024 caratteri. Archimista non ha limite.
      # Il superamento del limite blocca l'importazione in SAN, d'altra parte non conviene troncare l'html.
      # SELECT id, char_length(accessibility) FROM custodians ORDER BY char_length(accessibility) desc;
      # Che fare ? Per ora non si rileva il dato.
      xml.altroaccesso "" # textilize(custodian.accessibility)
      xml.consultazione ""

    end
  end
end