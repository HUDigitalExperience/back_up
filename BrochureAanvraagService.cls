public with sharing class BrochureAanvraagService {

	private static final Map<String, Schema.SObjectField> FIELDS_BY_LANGUAGE = new Map<String, Schema.SObjectField> {
		'en-US' => BrochureAanvraag__c.BrochureEN__c,
		'nl-NL' => BrochureAanvraag__c.BrochureNL__c
	};

	private static final String RECEIVED_STATUS = 'Brochure(s) ontvangen';

	public static void setDocumentUrls(List<BrochureReceived__e> events)
	{
		List<BrochureAanvraag__c> aanvragenToUpdate = new List<BrochureAanvraag__c>();

		for (BrochureReceived__e currentEvent : events)
		{
			Boolean urlSet = false;
			List<BrandspotService.DocumentType> documents = (List<BrandspotService.DocumentType>) JSON.deserialize(currentEvent.Documents__c, List<BrandspotService.DocumentType>.class);
			String aanvraagId = currentEvent.AanvraagId__c;

			BrochureAanvraag__c aanvraag = new BrochureAanvraag__c(Id = aanvraagId);

			for (BrandspotService.DocumentType document : documents)
			{
				String language = document.language;
				if (FIELDS_BY_LANGUAGE.keySet().contains(language))
				{
					aanvraag.put(FIELDS_BY_LANGUAGE.get(language), document.url);
					urlSet = true;
				}
				else
				{
					System.debug(String.format('Language not found:{0}', new List<Object>{language}));
				}
			}

			if (urlSet)
			{
				aanvraag.LastCordeoContact__c = System.now();
				aanvraag.CordeoStatus__c = RECEIVED_STATUS;
				aanvragenToUpdate.add(aanvraag);
			}
		}

		if (aanvragenToUpdate.size() > 0)
		{
			update aanvragenToUpdate;
		}
	}
}