//
//  May 21, 2019
//  Dennis Stahlhofen | Stahlhofen Development | Force.com
//
//  Class DstRestCordeoBrandspot
//  Public URL (Acceptatie): https://acceptatie-hu.cs102.force.com/cordeo/services/apexrest/brandspot
//  Public URL (Production): https://hu.secure.force.com/cordeo/services/apexrest/brandspot
//
@RestResource(urlMapping = '/brandspot_old/*')
global without sharing class DstRestCordeoBrandspot {

  private final static String KEY = BrandspotSettings__c.getOrgDefaults().Key__c;
  private final static Boolean DEBUG = BrandspotSettings__c.getOrgDefaults().Debug__c;

  private static void log(String txt) {
    if (DEBUG) System.debug('##### - ' + txt);
  }

  @HttpPost
  global static void restBrandspotPost() {

    Integer statusCode = 403;
    RestRequest request = RestContext.request;
    String jsonString = request.requestBody.toString();

    String retVal = processBrandspotPost(jsonString);

    if (retVal != null) {
      statusCode = 200;
      RestContext.response.addHeader('Content-Type', 'application/json');
      RestContext.response.responseBody = Blob.valueOf(retVal);
    }

    RestContext.response.statusCode = statusCode;
  }

  private static String processBrandspotPost(String jsonString) {

    log('json: ' + jsonString);

    BrandspotType brandspotType = (BrandspotType) JSON.deserialize(jsonString, BrandspotType.class);

    if (brandspotType.api_key == null || brandspotType.api_key != KEY) {
      return null;
    }

    BrochureAanvraag__c bag;
    String brochureRequestId = brandspotType.owned_by;

    for (BrochureAanvraag__c b :[Select Id From BrochureAanvraag__c Where Id = :brochureRequestId And RecordType.Name = 'Initieel']) {
      bag = b;
    }

    if (bag == null) {
      return null;
    }

    if (brandspotType.documents != null && brandspotType.documents.isEmpty() == false) {

      bag.LastCordeoContact__c = System.now();
      bag.CordeoStatus__c = 'Brochure(s) ontvangen';

      for (DocumentType documentType :brandspotType.documents) {

        if (documentType.language == 'en-US') {
          bag.BrochureEN__c = documentType.url;

        } else if (documentType.language == 'nl-NL') {
          bag.BrochureNL__c = documentType.url;
        }
      }
      update bag;
    }
    return 'Message successfully received';
  }

  private class BrandspotType {
    String api_key;
    String owned_by;
    list < DocumentType > documents;
  }

  private class DocumentType {
    String name;
    String url;
    list < String > courses;
    String language;
  }
}