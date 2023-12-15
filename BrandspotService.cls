//  Public URL (Acceptatie): https://acceptatie-hu.cs102.force.com/cordeo/services/apexrest/brandspot
//  Public URL (Production): https://hu.secure.force.com/cordeo/services/apexrest/brandspot
@RestResource(urlMapping = '/brandspot/*')
global with sharing class BrandspotService {

	private final static String KEY = BrandspotSettings__c.getOrgDefaults().Key__c;
	private final static Boolean DEBUG = BrandspotSettings__c.getOrgDefaults().Debug__c;
	private final static String SUCCES_MESSAGE = 'Message successfully received';

	private static void log(String txt) {
	  if (DEBUG) System.debug('##### - ' + txt);
	}
  
	@HttpPost
	global static void doPost() {

		Integer statusCode = 403;
		RestRequest request = RestContext.request;
		String requestBody = request.requestBody.toString();
		BrandspotType payload = (BrandspotType) JSON.deserialize(requestBody, BrandspotType.class);

		if (isValidRequest(payload)) 
		{
			Eventbus.publish(getEvent(payload));
			statusCode = 200;
			RestContext.response.addHeader('Content-Type', 'application/json');
			RestContext.response.responseBody = Blob.valueOf(SUCCES_MESSAGE);
		} 

		RestContext.response.statusCode = statusCode;
	}

	private static Boolean isValidRequest(BrandspotType requestBody) 
	{
		if (requestBody?.api_key != KEY) {
			return false;
		}

		String aanvraagId = requestBody.owned_by;

		BrochureAanvraag__c aanvraag = [SELECT Id FROM BrochureAanvraag__c WHERE Id = :aanvraagId AND RecordType.Developername = 'Initieel' LIMIT 1];

		if (null == aanvraag || true == requestBody.documents?.isEmpty())
		{
			return false;
		}

		return true;
	}

	private static BrochureReceived__e getEvent(BrandspotType request)
	{
		BrochureReceived__e event = new BrochureReceived__e();
		event.AanvraagId__c = request.owned_by;
		event.Documents__c = JSON.serialize(request.documents);
		return event;
	}

	public class BrandspotType
	{
		public String api_key;
		public String owned_by;
		public List<DocumentType> documents;
	}
  
	public class DocumentType
	{
		public String name;
		public String url;
		public List<String> courses;
		public String language;
	}

}